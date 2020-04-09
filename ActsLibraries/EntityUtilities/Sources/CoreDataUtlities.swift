//
//  File.swift
//  
//
//  Created by Paul Fechner on 4/2/20.
//


#if canImport(CoreData)
import CoreData

public protocol CoreDataEntity: NSManagedObject & IdentifiableEntity where ID: CVarArg {}
/// CoreData specific definitions for an EntityDriver
public protocol CoreDataStorageDriver: EntityStorageDriver {

    /// Returns
    func findObject<T: CoreDataEntity>(for identifier: T.ID?) throws -> T
    func findObjects<T: CoreDataEntity>(for identifiers: [T.ID]?) throws -> [T]

    func allObjects<T: NSManagedObject>(of type: T.Type) throws -> [T]
}

public extension NSManagedObject {
    /// Convenience property to get the entity's name
    @objc static var entityName: String { return String(describing: self) }
}

public extension NSManagedObjectContext {

}

extension NSManagedObjectContext: CoreDataStorageDriver { }

/// Default implementation for CoreDataStorageDriver (separated from adherance definition so we only need to declare one `public`)
public extension NSManagedObjectContext {

    enum EntityError: Error {
        case itemNotFound
        case noIdentifier
        case couldNotCreateNewEntity
    }

    func findObject<T: CoreDataEntity>(for identifier: T.ID?) throws -> T {
        guard let identifier = identifier else { throw EntityError.noIdentifier }
        let predicate = NSPredicate(format: "\(T.idPropertyName) = %@", identifier)
        let request = NSFetchRequest<T>(entityName:T.entityName)
        request.predicate = predicate;

        let results = try fetch(request)
        assert(results.count <= 1, "Never should find more than one item!")
        if let object = results.first {
            return object
        }
        else {
            throw EntityError.itemNotFound
        }
    }

    func findObjects<T: CoreDataEntity>(for identifiers: [T.ID]?) throws -> [T] {
        guard let identifiers = identifiers else { throw EntityError.noIdentifier }
        let request = NSFetchRequest<T>.init(entityName: T.entityName)
        request.predicate = NSPredicate(format: "\(T.idPropertyName) IN %@", identifiers)
        return try fetch(request)
    }

    func allObjects<T: NSManagedObject>(of type: T.Type) throws -> [T] {
        try self.fetch(NSFetchRequest<T>(entityName: T.entityName))
    }
}

/// Default implementation of ModelBuildingEntity for NSManagedObject
public extension ModelBuildingEntity where StorageDriver: CoreDataStorageDriver, Self: CoreDataEntity {

    static func getOrMake(from model: Model, in driver: NSManagedObjectContext) throws -> Self {
        let item: Self = try {
            if let foundItem: Self = try? driver.findObject(for: model.id) {
                return foundItem
            }
            else if let newItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: driver) as? Self {
                return newItem
            }
            else {
                throw NSManagedObjectContext.EntityError.couldNotCreateNewEntity
            }
        }()
        item.update(from: model)
        return item
    }
}

/// Default implementation of ModelBuildingEntity for NSManagedObject that also has relationships.
public extension RelationalEntity where StorageDriver: NSManagedObjectContext, Self: CoreDataEntity, Self: ModelUpdatable {

    static func getOrMake(from model: Model, in driver: StorageDriver) throws -> Self {
        let item: Self = try {
            if let foundItem: Self = try? driver.findObject(for: model.id) {
                return foundItem
            }
            else if let newItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: driver) as? Self {
                return newItem
            }
            else {
                throw NSManagedObjectContext.EntityError.couldNotCreateNewEntity
            }
        }()
        item.update(from: model)
        try item.updateRelationships(from: model, in: driver)
        return item
    }
}

#endif
