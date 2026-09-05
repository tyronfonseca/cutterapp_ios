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

    var body: some View {
        Form {
            Section("Upload Custom Cutter Table") {
                TextField("Table Name", text: $newCutterName)
                TextField("Description (Optional)", text: $newCutterDescription)
            }
            
            Section {
                Toggle("Set as current table", isOn: $setSelected)
            }
            
            Section {
                Button("Upload Custom Cutter CSV") {
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
                    setSelected: setSelected
                )
                if success {
                    dismiss()
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
        .navigationTitle("Add Cutter Table")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddNewCutterTableView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(AppSharedData())
}

