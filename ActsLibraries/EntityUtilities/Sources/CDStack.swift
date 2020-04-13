//
//  CDStack.swift
//  
//
//  Created by Paul Fechner on 4/1/20.
//
#if canImport(CoreData)
import CoreData
import Foundation

/// A class to manage the boilerplate for a CoreData database
public class CDStack
{
    // MARK: - public needed info -
    /// Injected settings to use for the instance.
    public let settings: Settings

    private var _context: NSManagedObjectContext!

    /// Primary context.Can only be accessed from the main thread. Use makeBackgroundContext for background access.
    public var context: NSManagedObjectContext {
        precondition(Thread.isMainThread, "Can only be accessed from the main thread. Use makeBackgroundContext instead")
        return _context
    }

    /// Returns a child context from the main thread context. This context resolves merge issues by favoring what's in memory, so whatever you change in this context will win even if a different context has saved something else.
    public func makeBackgroundContext() -> NSManagedObjectContext {
        let parent = context
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = parent
        let mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        childContext.mergePolicy = mergePolicy
        return childContext
    }

    /// Completely reset the database to an empty state
    public func resetDatabase() {
        deleteExistingDatabase()

        model = settings.createModel()
        _context = settings.createContext(coordinator: coordinator)
        coordinator = createCoordinator(model: model)
    }

    // MARK: - Internal Instance Methods -

    private var coordinator: NSPersistentStoreCoordinator!
    private var model: NSManagedObjectModel

    /// Primary entry point
    /// Setup required to be done on the main thread.
    public init(settings: Settings) {
        precondition(Thread.isMainThread, "Must intialize context on the main thread.")
        self.settings = settings
        model = settings.createModel()
        coordinator = createCoordinator(model: model)
        _context = settings.createContext(coordinator: coordinator)
        registerForNotifications()
    }

    private func deleteExistingDatabase() {

        do {
            try FileManager.default.removeItem(at: settings.storeUrl)
        } catch (let error) {
            print(error)
            assertionFailure("Could not delete existing database.")
        }

        // Not always using these, so don't assert
        let _ = try? FileManager.default.removeItem(at: settings.writeAheadLogUrl)
        let _ = try? FileManager.default.removeItem(at: settings.indexUrl)
    }

    /// Creates the managed object context for the main thread and registers for notifications so that changes on background contexts are merged when appropriate. Must be run on the main thread.
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CDStack.saveNotification(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    @objc private func saveNotification(_ notification: Notification) {
        guard let callContext = notification.object as? NSManagedObjectContext  else {
            assertionFailure("Notification has no context: \(notification)")
            return
        }

        let checkAndMergeBlock = { [weak self] in
            guard let self = self else { return }
            if !callContext.isEqual(self.context) { // Don't need to merge changes from our own context
                self.context.mergeChanges(fromContextDidSave: notification)
            }
        }

        if Thread.isMainThread {
            checkAndMergeBlock()
        } else {
            DispatchQueue.main.sync(execute: {
                checkAndMergeBlock()
            })
        }
    }

    private func createCoordinator(model: NSManagedObjectModel) -> NSPersistentStoreCoordinator {
        let fileManager = FileManager()

        // Seed database if requested and there is no existing database
        if settings.shouldSeed && !fileManager.fileExists(atPath: settings.storeUrl.path) {
            guard let seedUrl = settings.databaseBundle.url(forResource: settings.databaseModelName, withExtension: "sqlite") else {
                fatalError("Seed database \(settings.databaseModelName).sqlite not in bundle.")
            }

            do {
                try fileManager.copyItem(at: seedUrl, to: settings.storeUrl)
            } catch (let error) {
                print(error)
                fatalError("Could not move seed database \(seedUrl.path) into place at \(settings.storeUrl.path).")
            }
        }

        // Perform automatic migration if possible, infering whatever it can, secure this data, but only until the user unlocks their phone for the first time after turning on (more secure data would mean that we couldn't do some stuff in the background), and don't use journaling mode.
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true,
                       FileAttributeKey.protectionKey:FileProtectionType.completeUntilFirstUserAuthentication
            , NSSQLitePragmasOption:["journal_mode":"DELETE"] ] as [AnyHashable : Any]

        let coordin = NSPersistentStoreCoordinator(managedObjectModel: model)

        // Add the persistent store (the database file) to the coordinator
        do {
            try coordin.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: settings.storeUrl, options: options as [AnyHashable: Any])
            return coordin
        } catch (let error) {
            print(error)
        }

        // If we get here, then we failed to set the persistent store for the database, most likely because of a migration issue where the saved database had different properties, objects, associations, etc.
        guard settings.deleteDatabaseOnMigrationFailure else {
            fatalError("Could not create a persistent store coordinator. Try setting deleteDatabaseOnMigrationFailure to true or write/fix the migration.")
        }

        deleteExistingDatabase()
        do {
            try coordin.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: settings.storeUrl, options: options as [AnyHashable: Any])
            return coordin
        } catch (let error) {
            print(error)
            fatalError("Could not create a persistent store coordinator even after deleting the existing database.")
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

extension CDStack {
    public struct Settings {
        /// The default database name. Used for tracking the sqlite file, write ahead log, seed database, and Xcode model file (xcdatamodeld). The title must match for all these files.
        public let databaseModelName: String
        /// On first load, which to seed the database. Requires a {coreDataModelName}.sqlite file in the bundle.
        public let shouldSeed: Bool

        /// The Bundle where the database momd is found
        public let databaseBundle: Bundle

        /// If we cannot migrate the database on model changes, then this completely deletes the old database and starts from scratch
        public let deleteDatabaseOnMigrationFailure: Bool

        public init(databaseModelName: String, shouldSeed: Bool, databaseBundle: Bundle, deleteDatabaseOnMigrationFailure: Bool = true) {
            self.databaseModelName = databaseModelName
            self.shouldSeed = shouldSeed
            self.databaseBundle = databaseBundle
            self.deleteDatabaseOnMigrationFailure = deleteDatabaseOnMigrationFailure
        }
    }
}

//MARK: private info
private extension CDStack.Settings {

    // Create a documents directory in the library folder. Do this because sometimes apps allow iTunes sharing in the main documents directory, and we probably don't want the user looking at the sqlite database.
    private var documentsDirectory: URL {
        guard let libraryDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {  fatalError() }
        let documentsDir = (libraryDir as NSString).appendingPathComponent("Documents")
        do {
            try FileManager.default.createDirectory(atPath: documentsDir, withIntermediateDirectories: true, attributes: nil)
        } catch (let error) {
            print(error)
            fatalError()
        }
        return Foundation.URL(fileURLWithPath: documentsDir)
    }

    //MARK: -  Internal URLS -

    var storeUrl: URL { documentsDirectory.appendingPathComponent(databaseModelName + ".sqlite") }
    var writeAheadLogUrl: URL { documentsDirectory.appendingPathComponent(databaseModelName + ".sqlite-wal") }
    var indexUrl: URL { documentsDirectory.appendingPathComponent(databaseModelName + ".sqlite-shm") }
    var momdUrl: URL { databaseBundle.url(forResource: databaseModelName, withExtension: "momd")! }

    // MARK: Creation methods
    func createModel() -> NSManagedObjectModel {
        return NSManagedObjectModel(contentsOf: momdUrl)!
    }

    func createContext(coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        // Goes property by property, if different, the saved one in the store wins (vs the in-memory version)
        mainContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        mainContext.persistentStoreCoordinator = coordinator
        return mainContext
    }
}
#endif

