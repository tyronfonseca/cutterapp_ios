//
//  AddNewCutterTableView.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import SwiftUI

struct AddNewCutterTableView: View {
    @Environment(AppSharedData.self) private var sharedData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var viewModel: AddNewCutterTableViewModel = .init()
    
    var body: some View {
        Form {
            Section("Load Custom Cutter Table") {
                TextField("Table Name", text: $viewModel.newCutterName)
                TextField("Description (Optional)", text: $viewModel.newCutterDescription)
                Toggle("CSV file has headers", isOn: $viewModel.includesHeader)
            }
            
            Section {
                Toggle("Set as current table", isOn: $viewModel.setSelected)
            }
            
            Section(footer: Text("The csv file needs to follow the format \"<name>\",\"<number>\" for example: \"Zac\",\"15\". If the file has headers please set ON the option above.")) {
                Button("Select CSV file") {
                    viewModel.isImporting = true
                }
                .disabled(viewModel.newCutterName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            if !viewModel.previewData.isEmpty {
                Section(header: Text("CSV Preview (First 5 Rows)")) {
                    TableHeaderView()
                    
                    ForEach(viewModel.previewData) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.code)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        // Automatically re-parse when the header toggle changes
        .onChange(of: viewModel.includesHeader) { _, newValue in
            viewModel.reloadCSVData(hasHeaders: newValue)
        }
        .fileImporter(
            isPresented: $viewModel.isImporting,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                // Save the URL for reloading later
                viewModel.selectedURL = url
                viewModel.reloadCSVData()
                
            case .failure(let error):
                print("Import failed: \(error.localizedDescription)")
                viewModel.importError = true
            }
        }
        .alert("Import Error", isPresented: $viewModel.importError) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("Failed to parse or save the selected CSV file. Please check the file formatting.")
        }
        .alert("New table added successfully", isPresented: $viewModel.isImportSuccessful) {
            Button("Close") { dismiss() }
        } message: {
            Text("Cutter table \"\(viewModel.newCutterName)\" added.")
        }
        .navigationTitle("Add Cutter Table")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewModel.previewData.isEmpty {
                    Button("Save") {
                        viewModel.saveCSV(viewContext: viewContext, sharedData: sharedData)
                    }
                }
            }
        }
    }
}

private struct TableHeaderView : View {
    var body: some View {
        HStack {
            Text("Name")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Spacer()
            Text("Code")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AddNewCutterTableView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(AppSharedData())
}
