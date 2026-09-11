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
            Section("add_cutter_table_load_table") {
                TextField("add_cutter_table_name", text: $viewModel.newCutterName)
                    .accessibilityIdentifier("add_cutter_table_name_input")
                TextField("add_cutter_table_description", text: $viewModel.newCutterDescription)
                    .accessibilityIdentifier("add_cutter_table_description_input")
                Toggle("add_cutter_table_csv_headers", isOn: $viewModel.includesHeader)
                    .accessibilityIdentifier("add_cutter_table_csv_headers_toggle")
            }
            
            Section {
                Toggle("add_cutter_table_set_current", isOn: $viewModel.setSelected)
                    .accessibilityIdentifier("add_cutter_table_set_current_toggle")
            }
            
            Section(footer: Text("add_cutter_table_footer")) {
                Button("add_cutter_table_select_csv") {
                    viewModel.isImporting = true
                }
                .disabled(viewModel.newCutterName.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityIdentifier("add_cutter_table_select_csv_button")
            }
            
            if !viewModel.previewData.isEmpty {
                Section(header: Text("add_cutter_table_preview")) {
                    TableHeaderView()
                        .accessibilityIdentifier("add_cutter_table_preview_header")
                    
                    ForEach(viewModel.previewData) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text(item.code)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityIdentifier("add_cutter_table_preview_row_\(item.code)")
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
        .alert("add_cutter_table_error_import", isPresented: $viewModel.importError) {
            Button("ok", role: .cancel) { dismiss() }
                .accessibilityIdentifier("add_cutter_table_error_ok_button")
        } message: {
            Text("add_cutter_table_error_import_description")
        }
        .alert("add_cutter_table_successful", isPresented: $viewModel.isImportSuccessful) {
            Button("close") { dismiss() }
                .accessibilityIdentifier("add_cutter_table_success_close_button")
        } message: {
            Text(.addCutterTableAdded(viewModel.newCutterName))
        }
        .navigationTitle("add_cutter_table_title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewModel.previewData.isEmpty {
                    Button("save") {
                        viewModel.saveCSV(viewContext: viewContext, sharedData: sharedData)
                    }
                    .accessibilityIdentifier("add_cutter_table_save_button")
                }
            }
        }
    }
}

private struct TableHeaderView : View {
    var body: some View {
        HStack {
            Text("name")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Spacer()
            Text("code")
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
