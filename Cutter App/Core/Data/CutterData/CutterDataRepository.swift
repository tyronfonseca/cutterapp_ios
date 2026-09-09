//
//  CutterDataRepository.swift
//  Cutter App
//
//  Created by Tyron on 9/9/26.
//

import Foundation
import CoreData

protocol CutterDataRepositoryProtocol {
    func fetchAll() -> [CutterData]
    func save(_ item: CutterData)
    func saveBatch(_ items: [CutterData])
    func delete(id: UUID)
    func deleteAll()
    func update(_ item: CutterData)
}

final class CutterDataRepository: CutterDataRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Fetch all saved CutterData items sorted by creation/id
    func fetchAll() -> [CutterData] {
        let request: NSFetchRequest<CutterDataEntity> = CutterDataEntity.fetchRequest() as! NSFetchRequest<CutterDataEntity>
        
        do {
            let entities = try context.fetch(request)
            let result = entities.map { $0.toStruct() }
            return result
        } catch {
            print("CoreData Fetch Error: \(error.localizedDescription)")
            return []
        }
    }

    /// Persist a single item
    func save(_ item: CutterData) {
        _ = CutterDataEntity(from: item, context: context)
        saveContext()
    }

    /// Batch save multiple items efficiently
    func saveBatch(_ items: [CutterData]) {
        items.forEach { _ = CutterDataEntity(from: $0, context: context) }
        saveContext()
    }

    /// Delete a record by UUID
    func delete(id: UUID) {
        let request: NSFetchRequest<CutterDataEntity> = CutterDataEntity.fetchRequest() as! NSFetchRequest<CutterDataEntity>
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                saveContext()
            }
        } catch {
            print("CoreData Delete Error: \(error.localizedDescription)")
        }
    }

    /// Update an existing entity by UUID
    func update(_ item: CutterData) {
        let request: NSFetchRequest<CutterDataEntity> = CutterDataEntity.fetchRequest() as! NSFetchRequest<CutterDataEntity>
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

        do {
            if let entity = try context.fetch(request).first {
                entity.name = item.name
                entity.code = item.code
                entity.authorName = item.authorName
                entity.authorSurname = item._authorSurname
                entity.isbn = item.isbn
                entity.bookName = item.bookName
                entity.ddcs = item.ddcs
                entity.ddcSelected = item.ddcSelected
                entity.needsReview = item.needsReview
                entity.dontSeparateName = item.dontSeparateName
                
                saveContext()
            } else {
                // Fallback to saving if not found
                save(item)
            }
        } catch {
            print("CoreData Update Error: \(error.localizedDescription)")
        }
    }

    /// Clear all CutterData records from store
    func deleteAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = CutterDataEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("CoreData Batch Delete Error: \(error.localizedDescription)")
        }
    }

    // MARK: - CoreData Helpers

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData Save Context Error: \(error.localizedDescription)")
        }
    }
}
