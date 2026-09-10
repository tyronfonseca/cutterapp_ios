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
        guard let activeEntity = repository.ensureDefaultTablesExist(context: context),
              let filename = activeEntity.filename else {
            self.currentCutterData = []
            self.currentTableSelected = nil
            return
        }

        let rawData: [CutterData]

        // Try external/custom directory URL
        if let customURL = storage.getURL(for: filename),
           FileManager.default.fileExists(atPath: customURL.path) {
            rawData = CSVHelper.getCSVData(from: customURL, hasHeaders: activeEntity.hasHeaders)
        }
        // Fall back to main bundle using the filename string
        else {
            rawData = CSVHelper.getCSVData(filename: filename, hasHeaders: true)
        }

        self.currentCutterData = rawData
        self.currentTableSelected = activeEntity
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
        
    func saveImportedCSV(
        from fileURL: URL,
        context: NSManagedObjectContext,
        name: String,
        description: String,
        setSelected: Bool,
        hasHeaders: Bool
    ) -> Bool {
        let accessGranted = fileURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted { fileURL.stopAccessingSecurityScopedResource() }
        }
        
        // Generate unique filename on save
        let sanitizeName = name.replacingOccurrences(of: " ", with: "_").lowercased()
        let uniqueFilename = "\(sanitizeName)_\(UUID().uuidString.prefix(8)).csv"
        
        // Copy file to Application Support
        guard storage.copyToApplicationSupport(sourceURL: fileURL, targetFilename: uniqueFilename) != nil else {
            return false
        }
        
        // Save metadata in Core Data
        let displayName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "No name" : name
        let savedEntity = repository.saveCustomTableMetadata(
            name: displayName,
            description: description,
            uniqueFilename: uniqueFilename,
            context: context,
            hasHeaders: hasHeaders
        )
        
        // Roll back copied file if Core Data save fails
        guard let entity = savedEntity else {
            storage.deleteFile(filename: uniqueFilename)
            return false
        }
        
        if setSelected {
            selectActiveTable(entity, context: context)
        }
        
        return true
    }
}
