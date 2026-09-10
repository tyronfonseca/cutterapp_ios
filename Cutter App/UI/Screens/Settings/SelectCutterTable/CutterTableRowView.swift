//
//  CutterTableRowView.swift
//  Cutter App
//
//  Created by Tyron on 10/9/26.
//

import SwiftUI
import CoreData

struct CutterTableRowView: View {
    @ObservedObject var table: CutterTableEntity
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(table.name ?? "select_cutter_table_untitled")
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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Delete all existing entities in the preview context
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CutterTableEntity.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    _ = try? context.execute(deleteRequest)
    context.reset() // Clears remaining managed objects from memory
    
    let sampleTable = CutterTableEntity(context: context)
    sampleTable.name = "Table 1"
    sampleTable.tableDescription = "This is a table"
    sampleTable.isSelected = true
    
    return CutterTableRowView(table: sampleTable, onSelect: {})
}
