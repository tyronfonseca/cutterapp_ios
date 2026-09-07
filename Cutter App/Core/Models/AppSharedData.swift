//
//  AppSharedData.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import SwiftUI
import CoreData

@Observable
final class AppSharedData {
    /// Current cutter table selected
    var currentTableSelected : CutterTableEntity?
    /// Cutter table data used across the app
    var currentCutterData : [CutterData] = []
    /// User settings instance
    var settings = AppSettings()
    
    @ObservationIgnored private let storage = CSVStorageManager.shared
    @ObservationIgnored private let repository = CutterTableRepository()
    
    // MARK: - Orchestration Logic
    
    func loadActiveTable(context: NSManagedObjectContext) {
        let activeEntity = repository.ensureDefaultTableExists(context: context)
        
        guard let filename = activeEntity?.filename else {
            self.currentCutterData = CSVHelper.getCSVData()
            return
        }
        
        if let customURL = storage.getURL(for: filename) {
            let parsed = CSVHelper.getCSVData(from: customURL)
            self.currentCutterData = parsed.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        } else {
            self.currentCutterData = CSVHelper.getCSVData()
        }
        
        currentTableSelected = activeEntity
    }
    
    func selectActiveTable(_ entity: CutterTableEntity, context: NSManagedObjectContext) {
        repository.setActiveTable(entity, context: context)
        loadActiveTable(context: context)
    }
    
    func search(
        name: String,
        lastName: String,
        options: CutterSearchOptions
    ) -> CutterData? {
        return CutterSearchEngine.search(
            queryName: name,
            queryLastName: lastName,
            in: currentCutterData,
            options: options
        )
    }
    
    @discardableResult
    func importCustomCSV(
        from fileURL: URL,
        name: String,
        description: String,
        context: NSManagedObjectContext,
        setSelected: Bool = false,
        hasHeaders: Bool = false
    ) -> Bool {
        let accessGranted = fileURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted { fileURL.stopAccessingSecurityScopedResource() }
        }
        
        let sanitizeName = name.replacingOccurrences(of: " ", with: "_").lowercased()
        let uniqueFilename = "\(sanitizeName)_\(UUID().uuidString.prefix(8)).csv"
        
        guard let destinationURL = storage.copyToApplicationSupport(sourceURL: fileURL, targetFilename: uniqueFilename) else {
            return false
        }
        
        let parsedData = CSVHelper.getCSVData(from: destinationURL, hasHeaders: hasHeaders)
        guard !parsedData.isEmpty else {
            storage.deleteFile(filename: uniqueFilename)
            return false
        }
        
        let displayName = name.trimmingCharacters(in: .whitespaces).isEmpty ? fileURL.deletingPathExtension().lastPathComponent : name
        
        let savedEntity = repository.saveCustomTableMetadata(
            name: displayName,
            description: description,
            uniqueFilename: uniqueFilename,
            context: context
        )
        
        if let entity = savedEntity {
            if setSelected {
                selectActiveTable(entity, context: context)
            }
        }
        
        return savedEntity != nil
    }
}
