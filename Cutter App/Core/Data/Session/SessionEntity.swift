//
//  SessionEntity.swift
//  Cutter App
//
//  Created by Tyron on 8/9/26.
//

import Foundation
import CoreData

@objc(SessionEntity)
public class SessionEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var sessionDescription: String? // Avoid reserved 'description'
    @NSManaged public var created_at: Date?
    @NSManaged public var updated_at: Date?
    
    // To-Many Relationship
    @NSManaged public var cutters: NSSet?
    
    // MARK: - Swift Set Helper
    public var cutterArray: [CutterDataEntity] {
        let set = cutters as? Set<CutterDataEntity> ?? []
        return set.sorted { ($0.name) < ($1.name) }
    }
}

// MARK: - Generated Accessors for Cutters
extension SessionEntity {
    @objc(addCuttersObject:)
    @NSManaged public func addToCutters(_ value: CutterDataEntity)

    @objc(removeCuttersObject:)
    @NSManaged public func removeFromCutters(_ value: CutterDataEntity)

    @objc(addCutters:)
    @NSManaged public func addToCutters(_ values: NSSet)

    @objc(removeCutters:)
    @NSManaged public func removeFromCutters(_ values: NSSet)
}
