//
//  AddNewCutterTableView.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import SwiftUI

struct AddNewCutterTableView : View {
    @Environment(AppSharedData.self) private var sharedData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isImporting = false
    @State private var importError = false
    @State private var newCutterName = ""
    @State private var newCutterDescription = ""
    @State private var setSelected = false
    @State private var isImportSuccessful = false
    @State private var includesHeader = false;

    var body: some View {
        Form {
            Section("Upload Custom Cutter Table") {
                TextField("Table Name", text: $newCutterName)
                TextField("Description (Optional)", text: $newCutterDescription)
                Toggle("CSV file has headers", isOn: $includesHeader)
            }
            
            Section {
                Toggle("Set as current table", isOn: $setSelected)
            }
            
            Section (footer: Text("The csv file needs to follow the format \"<name>;<number>\" for example: Zac;15. If the file has headers please use set ON the option above.")) {
                Button("Import custom Cutter CSV") {
                    isImporting = true
                }
                .disabled(newCutterName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                let success = sharedData.importCustomCSV(
                    from: url,
                    name: newCutterName,
                    description: newCutterDescription,
                    context: viewContext,
                    setSelected: setSelected,
                    hasHeaders: includesHeader
                )
                if success {
                    isImportSuccessful = true
                } else {
                    importError = true
                }
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
                importError = true
            }
        }
        .alert("Import Error", isPresented: $importError) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Failed to parse or save the selected CSV file. Please check the file formatting.")
        }
        .alert("New table added successfully", isPresented: $isImportSuccessful){
            Button("Close", role: .close) {
                dismiss()
            }
        } message: {
            Text("Cutter table \"\(newCutterName)\" added. You can select a different table in the settings screen.")
        }
        .navigationTitle("Add Cutter Table")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddNewCutterTableView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(AppSharedData())
}

