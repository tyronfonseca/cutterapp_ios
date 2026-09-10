//
//  AddNewCutterTableViewModel.swift
//  Cutter App
//
//  Created by Tyron on 10/9/26.
//

import SwiftUI
import Foundation
import CoreData

@Observable
final class AddNewCutterTableViewModel {
    
    var isImporting = false
    var importError = false
    var newCutterName = ""
    var newCutterDescription = ""
    var setSelected = false
    var isImportSuccessful = false
    var includesHeader = false
    var previewData: [CutterData] = []
    var uniqueFileName: String = ""
    var selectedURL: URL?
    
    private func importCustomCSV(
        from fileURL: URL,
        hasHeaders: Bool = false
    ) -> [CutterData]? {
        let accessGranted = fileURL.startAccessingSecurityScopedResource()
        defer {
            if accessGranted { fileURL.stopAccessingSecurityScopedResource() }
        }
        
        let parsedData = CSVHelper.getCSVData(from: fileURL, hasHeaders: hasHeaders)
        return parsedData.isEmpty ? nil : parsedData
    }
    
    func reloadCSVData(hasHeaders: Bool? = nil) {
        guard let url = selectedURL else { return }
        
        if let parsedData = importCustomCSV(
            from: url,
            hasHeaders: hasHeaders ?? includesHeader
        ) {
            previewData = Array(parsedData.prefix(5))
        } else {
            importError = true
        }
    }
    
    func saveCSV(viewContext: NSManagedObjectContext, sharedData: AppSharedData) {
        guard let url = selectedURL else {
            importError = true
            return
        }
        
        let success = sharedData.saveImportedCSV(
            from: url,
            context: viewContext,
            name: newCutterName,
            description: newCutterDescription,
            setSelected: setSelected,
            hasHeaders: includesHeader
        )
        
        if success {
            isImportSuccessful = true
        } else {
            importError = true
        }
    }
}
