//
//  HistoryViewModel.swift
//  Cutter App
//
//  Created by Tyron on 3/9/26.
//

import SwiftUI
import CoreData

class HistoryViewModel: NSObject, ObservableObject {
    @Published var searchHistory: [SearchResult] = []
    @Published var searchText: String = ""
    @Published var selectedItems: Set<SearchResult.ID> = []
    @Published var editMode: EditMode = .inactive
    @Published var showingDeleteConfirmation: Bool = false
    
    private var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController<SearchResult>?
    
    override init() {
        super.init()
    }
    
    func setContext(_ context: NSManagedObjectContext) {
        self.context = context
        setupFetchedResultsController()
        fetchSearchHistory()
    }
    
    private func setupFetchedResultsController() {
        guard let context = context else { return }
        
        let request = SearchesCD.fetchAllSearchResults()
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        self.fetchedResultsController = frc
    }
    
    func fetchSearchHistory() {
        guard let frc = fetchedResultsController else { return }
        do {
            try frc.performFetch()
            searchHistory = frc.fetchedObjects ?? []
        } catch {
            print("Failed to fetch: \(error.localizedDescription)")
        }
    }
    
    var filteredSearchHistory: [SearchResult] {
        filteredResults(by: searchText)
    }
    
    // MARK: - Computed Properties
    
    func deleteAlertTitle(selectedCount: Int) -> String {
        if editMode.isEditing && selectedCount > 0 {
            return "Delete \(selectedCount) selected item\(selectedCount > 1 ? "s" : "")?"
        }
        return "Delete all history?"
    }
    
    // MARK: - Filtering
    
    func filteredResults(by searchText: String) -> [SearchResult] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return searchHistory }
        
        return searchHistory.filter { item in
            let matchesLastName = item.last_name?.localizedCaseInsensitiveContains(trimmed) ?? false
            let matchesName     = item.name?.localizedCaseInsensitiveContains(trimmed) ?? false
            let matchesNumber   = item.calling_number?.localizedCaseInsensitiveContains(trimmed) ?? false
            
            return matchesLastName || matchesName || matchesNumber
        }
    }
    
    // MARK: - Delete Operations
    
    private func saveContext() {
        guard ((context?.hasChanges) != nil) else { return }
        do {
            try context?.save()
            fetchSearchHistory() // Refresh after save
        } catch {
            print("Failed to save: \(error.localizedDescription)")
        }
    }
    
    func deleteItem(at offsets: IndexSet, from filtered: [SearchResult]) {
        for index in offsets {
            let item = filtered[index]
            context?.delete(item)
        }
        saveContext()
    }
    
    func deleteSelected(from filtered: [SearchResult]) {
        let itemsToDelete = filtered.filter { selectedItems.contains($0.id) }
        for item in itemsToDelete {
            context?.delete(item)
        }
        saveContext()
        
        selectedItems.removeAll()
        editMode = .inactive
    }
    
    func deleteAllHistory() {
        searchHistory.forEach { context?.delete($0) }
        saveContext()
        
        selectedItems.removeAll()
        editMode = .inactive
    }
    
    // MARK: - Export
    
    func exportSelectedToCSV() {
        let selectedRecords = searchHistory.filter { selectedItems.contains($0.id) }
        print("Exporting \(selectedRecords.count) items to CSV")
        // TODO: Implement CSV export
    }
    
    func exportAllToCSV() {
        print("Exporting all \(searchHistory.count) items to CSV")
        // TODO: Implement CSV export
    }
    
    // MARK: - UI Helpers
    
    func toggleEditMode() {
        withAnimation {
            editMode = editMode.isEditing ? .inactive : .active
            if !editMode.isEditing {
                selectedItems.removeAll()
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension HistoryViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.searchHistory = controller.fetchedObjects as? [SearchResult] ?? []
        }
    }
}
