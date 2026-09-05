import SwiftUI

struct SelectCutterTableView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(AppSharedData.self) private var sharedData
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CutterTableEntity.createdAt, ascending: false)],
        animation: .default
    )
    private var customTables: FetchedResults<CutterTableEntity>
    
    var body: some View {
        Form {
            Section("Available Tables") {
                if customTables.isEmpty {
                    Text("No tables available.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(customTables) { table in
                        CutterTableRowView(table: table) {
                            selectCutterTable(table)
                        }
                        .swipeActions(edge: .trailing) {
                            if !table.cannotDelete {
                                Button(role: .destructive) {
                                    if let index = customTables.firstIndex(where: { $0.id == table.id }) {
                                        deleteCutterTables(offsets: IndexSet([index]))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select cutter table")
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
        
        if wasActiveTableDeleted {
            sharedData.loadActiveTable(context: viewContext)
        }
    }
}

// MARK: - Row Subview for Reactive Observation

private struct CutterTableRowView: View {
    @ObservedObject var table: CutterTableEntity
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(table.name ?? "Untitled Table")
                    .font(.headline)
                if let desc = table.tableDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            
            if table.isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}
