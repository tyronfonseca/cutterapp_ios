//
//  SearchItem.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import SwiftUI

struct SearchItemView: View {
    let item: CutterData
    @Environment(AppSettings.self) private var settings
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.searchValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if !item.bookName.isEmpty {
                    HStack {
                        Text(item.bookName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            HStack {
                // Cutter Value Badge
                Text(item.fullCallNumber(using: settings))
                    .font(.callout)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                
                if item.needsReview {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.15))
                        .clipShape(Capsule())
                        .accessibilityLabel("Requires review")
                        .accessibilityHint("The author name needs manual verification.")
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SearchItemView(item: CutterData(name: "Test, prueba", code: "251", authorName: "Test", bookName: "Sample Book Title"))
        
        SearchItemView(item: CutterData(name: "Test, prueba", code: "251", authorName: "Test", needsReview: true))
        
        SearchItemView(item: CutterData(name: "Test, prueba", code: "251", authorName: "Test", bookName: "Another Book", needsReview: true))
    }
    .padding()
    .environment(AppSettings())
}
