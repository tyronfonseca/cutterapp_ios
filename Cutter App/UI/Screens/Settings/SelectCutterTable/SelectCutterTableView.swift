//
//  SelectCutterTableView.swift
//  Cutter App
//
//  Created by Tyron on 10/9/26.
//

import SwiftUI
import CoreData

struct SelectCutterTableView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(AppSharedData.self) private var sharedData
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CutterTableEntity.createdAt, ascending: false)],
        animation: .default
    )
    private var customTables: FetchedResults<CutterTableEntity>
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        Form {
            Section("select_cutter_table_available") {
                if customTables.isEmpty {
                    Text("select_cutter_table_no_available")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(customTables) { table in
                        CutterTableRowView(table: table) {
                            selectCutterTable(table)
                        }
                        .deleteDisabled(table.cannotDelete)
                        .swipeActions(edge: .trailing) {
                            if !table.cannotDelete {
                                Button(role: .destructive) {
                                    if let index = customTables.firstIndex(where: { $0.id == table.id }) {
                                        deleteCutterTables(offsets: IndexSet([index]))
                                    }
                                } label: {
                                    Label("delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteCutterTables)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if customTables.allSatisfy(\.cannotDelete) {
                    EmptyView()
                } else {
                    EditButton()
                }
            }
        }
        .environment(\.editMode, $editMode)
        .navigationTitle("cuttertable_set_current_table")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sharedData.loadActiveTable(context: viewContext)
        }
    }
    
    // MARK: - Actions
    
    private func selectCutterTable(_ selectedTable: CutterTableEntity) {
        sharedData.selectActiveTable(selectedTable, context: viewContext)
    }
    
    private func deleteCutterTables(offsets: IndexSet) {
        var wasActiveTableDeleted = false
        
        for index in offsets {
            let table = customTables[index]
            
            guard !table.cannotDelete else { continue }
            
            if table.isSelected {
                wasActiveTableDeleted = true
            }
            
            if let filename = table.filename {
                CSVStorageManager.shared.deleteFile(filename: filename)
            }
            viewContext.delete(table)
        }
        
        try? viewContext.save()
        
        // Default to Cutter Sanborn if the deleted is active
        if wasActiveTableDeleted {
            if let newTable = customTables.first(where: { $0.name == CSVVersion.sanborn.name }) {
                selectCutterTable(newTable)
            } else {
                sharedData.loadActiveTable(context: viewContext)
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    //Delete all existing entities in the preview context
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CutterTableEntity.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    _ = try? context.execute(deleteRequest)
    context.reset() // Clears remaining managed objects from memory
    
    let table1 = CutterTableEntity(context: context)
    table1.id = UUID()
    table1.createdAt = Date()
    table1.name = "Standard Table"
    table1.tableDescription = "Default cutter"
    table1.isSelected = true
    table1.cannotDelete = true
    
    let table2 = CutterTableEntity(context: context)
    table2.id = UUID()
    table2.createdAt = Date().addingTimeInterval(-3600)
    table2.name = "Custom Cutter"
    table2.isSelected = false
    table2.cannotDelete = false
    
    try? context.save()
    
    return NavigationStack {
        SelectCutterTableView()
            .environment(\.managedObjectContext, context)
            .environment(AppSharedData())
    }
}
