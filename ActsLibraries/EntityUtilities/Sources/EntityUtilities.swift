//
//  EntityUtilities.swift
//  
//
//  Created by Paul Fechner on 4/1/20.
//

import Foundation
import CoreData

/// Extension of Identifiable with the additional info needed by a database
public protocol IdentifiableEntity: Identifiable {
    static var idPropertyName: String { get }
}

/// Type erased definition of a storage driver
public protocol EntityStorageDriver { }

/// A Type that can be updated with another Type
public protocol ModelUpdatable {
    associatedtype Model
    func update(from model: Model)
}

/// An IdentifiableEntity that can be fully updated/created from another Type
/// The intended use case is for a Database Model that's created from a Networking Model
public protocol ModelBuildingEntity: IdentifiableEntity & ModelUpdatable where Model: Identifiable, Model.ID == Self.ID {
    
    associatedtype StorageDriver: EntityStorageDriver
    static func getOrMake(from model: Model, in driver: StorageDriver) throws -> Self
}

/// An extension of ModelBuildingEntity for Entities that also have relationships to update.
public protocol RelationalEntity: ModelBuildingEntity {
    func updateRelationships(from model: Model, in driver: StorageDriver) throws
}

/// A Type that can be initialized using only another Type.
public protocol TypeInitable {
    associatedtype Model
    init(with model: Model)
}
