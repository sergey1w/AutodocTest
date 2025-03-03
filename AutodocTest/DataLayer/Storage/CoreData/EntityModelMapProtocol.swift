//
//  EntityModelMapProtocol.swift
//  AutodocTest
//
//  Created by sergey on 26.02.2025.
//

import CoreData.NSManagedObject

protocol EntityModelMapProtocol {
    associatedtype EntityType: NSManagedObject
    func mapToEntity(_ managedObject: EntityType)
    static func mapFromEntity(_ entity: EntityType) -> Self
}
