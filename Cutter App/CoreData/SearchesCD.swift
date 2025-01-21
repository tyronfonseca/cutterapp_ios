//
//  SearchesCDStack.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 21/1/25.
//

import CoreData

class SearchesCD : ObservableObject {
    static let shared = SearchesCD()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Searches")
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error.localizedDescription), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    /// Needed for SwiftUi preview only
    init(inMemory: Bool = false) {
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error.localizedDescription), \(error.userInfo)")
            }
        })
    }
    
    func save() {
        // Only save if there is changes
        guard persistentContainer.viewContext.hasChanges else { return }
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save context:", error.localizedDescription)
        }
    }
    
    // MARK: SearchResult operations
    
    static func fetchAllSearchResults() -> NSFetchRequest<SearchResult> {
        let result = SearchResult.fetchRequest()
        result.sortDescriptors = [NSSortDescriptor(keyPath: \SearchResult.last_searched, ascending: false)]
        
        return result
    }
    
    func insertOrUpdate(firstName: String, lastName: String, result: MainScreenData) {
        do {            
            let fetchRequest : NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND last_name == %@", firstName, lastName)
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let entity = results.first {
                entity.last_searched = Date()
            } else {
                let newSearchResult = SearchResult(context: persistentContainer.viewContext)
                newSearchResult.name = firstName
                newSearchResult.last_name = lastName
                newSearchResult.name_selected = result.dataUsed
                newSearchResult.calling_number = result.result
                newSearchResult.last_searched = Date()
            }
            save()
        } catch {
            print("Failed to fetch:", error.localizedDescription)
        }
    }
    
    func delete(search: SearchResult) {
        persistentContainer.viewContext.delete(search)
        save()
    }
}
