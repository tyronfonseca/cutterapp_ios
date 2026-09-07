//
//  CutterTableRepository.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import Foundation
import CoreData

final class CutterTableRepository {
    
    /// Fetches all stored Cutter tables from Core Data
    func fetchAllTables(context: NSManagedObjectContext) -> [CutterTableEntity] {
        let fetchRequest: NSFetchRequest<CutterTableEntity> = CutterTableEntity.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }

    /// Seeds default table metadata if database is empty, returning current active entity
    func ensureDefaultTableExists(context: NSManagedObjectContext) -> CutterTableEntity? {
        let tables = fetchAllTables(context: context)
        
        if tables.isEmpty {
            let defaultTable = CutterTableEntity(context: context)
            defaultTable.id = UUID()
            defaultTable.name = "Sanborn 3-Digit Table"
            defaultTable.tableDescription = "Cutter-Sanborn classification table. Swanson-Swift Revision (1969)"
            defaultTable.filename = "cutter_normal.csv"
            defaultTable.isSelected = true
            defaultTable.cannotDelete = true
            defaultTable.createdAt = Date()
            
            try? context.save()
            return defaultTable
        }
        
        return tables.first(where: { $0.isSelected }) ?? tables.first
    }

    /// Persists custom uploaded CSV metadata to Core Data
    func saveCustomTableMetadata(
        name: String,
        description: String,
        uniqueFilename: String,
        context: NSManagedObjectContext
    ) -> CutterTableEntity? {
        let newTable = CutterTableEntity(context: context)
        newTable.id = UUID()
        newTable.name = name
        newTable.tableDescription = description
        newTable.filename = uniqueFilename
        newTable.isSelected = false
        newTable.cannotDelete = false
        newTable.createdAt = Date()

        do {
            try context.save()
            return newTable
        } catch {
            print("Error persisting CutterTableEntity: \(error.localizedDescription)")
            context.delete(newTable)
            return nil
        }
    }

    /// Updates active selection state across all stored tables
    func setActiveTable(_ selectedEntity: CutterTableEntity, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CutterTableEntity> = CutterTableEntity.fetchRequest()
        
        do {
            let allTables = try context.fetch(fetchRequest)
            for table in allTables {
                let shouldBeSelected = (table.objectID == selectedEntity.objectID)
                if table.isSelected != shouldBeSelected {
                    table.isSelected = shouldBeSelected
                }
            }
            
            if context.hasChanges {
                try context.save()
                // Force context to notify subscribers of object changes
                context.refreshAllObjects()
            }
        } catch {
            print("Failed to set active table: \(error.localizedDescription)")
        }
    }
}
