//
//  SearchView.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI
import Foundation

struct SearchView: View {
    @State private var viewModel: SearchViewModel
    
    init(sharedData: AppSharedData) {
        self._viewModel = State(wrappedValue: SearchViewModel(sharedData: sharedData))
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            VStack(
                alignment: .center,
                spacing: 0
            ) {
                Image(.longLogo)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .foregroundStyle(.logo)
                    .accessibilityLabel(Text("logo_description"))
                    .accessibilityAddTraits(.isImage)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        TextField("Enter author name or scan text", text: $viewModel.searchText)
                            .padding(14)
                            .glassEffect()
                            .onSubmit {
                                viewModel.search()
                            }
                            
                        HStack {
                            
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\"Name Surname\", \"Name\", \"Surname, Name\" or ISBN to search online")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                    
                    HStack(spacing: 8) {
                        if !ProcessInfo.processInfo.isiOSAppOnMac {
                            Button(action: { viewModel.showScanner = true }) {
                                Label("Scan", systemImage: "document.viewfinder")
                            }
                            .sheet(isPresented: $viewModel.showScanner) {
                                OCRCameraView(searchText: $viewModel.searchText)
                            }
                            .buttonStyle(.glass)
                        }
                        
                        Spacer()
                        
                        if viewModel.isSearchingISBN {
                            ProgressView()
                                .padding(.horizontal, 8)
                        } else {
                            Button(action: {
                                viewModel.search()
                            }) {
                                Label("Search", systemImage: "magnifyingglass")
                            }
                            .buttonStyle(.glassProminent)
                            .disabled(viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                Divider()
                
                VStack(alignment: .leading) {
                    if viewModel.capturedText.isEmpty {
                        ContentUnavailableView(
                            "No entries yet",
                            systemImage: "book.closed.fill",
                            description: Text("Add a entry by scanning or entering an author name or ISBN")
                        )
                    } else {
                        // Filter toggle
                        if viewModel.capturedText.contains(where: { $0.needsReview }) {
                            HStack {
                                Text("Show only needing review")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                
                                Button(action: {
                                    viewModel.showOnlyNeedsReview.toggle()
                                }) {
                                    Image(systemName: viewModel.showOnlyNeedsReview ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                }
                                .controlSize(.regular)
                                .buttonStyle(.glass)
                            }
                            .accessibilityHint("Filter items that need review")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        
                        var displayedItems: [CutterData] {
                            let items = viewModel.showOnlyNeedsReview
                            ? viewModel.capturedText.filter { $0.needsReview }
                            : viewModel.capturedText
                            return items.reversed()
                        }
                        
                        List {
                            ForEach(displayedItems) { item in
                                NavigationLink {
                                    EditSearchItemView(
                                        item: Binding(
                                            get: {
                                                viewModel.capturedText.first(where: { $0.id == item.id }) ?? item
                                            },
                                            set: { newValue in
                                                if let index = viewModel.capturedText.firstIndex(where: { $0.id == item.id }) {
                                                    viewModel.capturedText[index] = newValue
                                                }
                                            }
                                        ),
                                        onDelete: {
                                            viewModel.capturedText.removeAll(where: { $0.id == item.id })
                                            // Auto-switch back if no items need review anymore
                                            if viewModel.showOnlyNeedsReview && !viewModel.capturedText.contains(where: \.needsReview) {
                                                viewModel.showOnlyNeedsReview = false
                                            }
                                        }
                                    )
                                } label: {
                                    SearchItemView(item: item)
                                }
                            }
                            .onDelete { indexSet in
                                let itemsToDelete = indexSet.map { displayedItems[$0] }
                                let idsToDelete = Set(itemsToDelete.map(\.id))
                                
                                viewModel.capturedText.removeAll(where: { idsToDelete.contains($0.id) })
                                
                                // Auto-switch back if no items need review anymore
                                if viewModel.showOnlyNeedsReview && !viewModel.capturedText.contains(where: \.needsReview) {
                                    viewModel.showOnlyNeedsReview = false
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .alert("Search Error", isPresented: $viewModel.showErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage)
                }
                
                Spacer()
                Divider()
                
                HStack {
                    Button( action:  {
                        viewModel.reset()
                    }) {
                        Label("Reset", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .disabled(viewModel.capturedText.isEmpty)
                    
                    Spacer()
                    Group {
                        if let csvURL = viewModel.exportToCSV() {
                            Button(action: {
                                viewModel.checkAndExport(csvURL)
                            }) {
                                Label("Save CSV", systemImage: "arrow.down.document")
                            }
                            .buttonStyle(.glassProminent)
                            .controlSize(.large)
                            
                        } else {
                            Button("Save CSV", systemImage: "arrow.down.document") {}
                                .buttonStyle(.glassProminent)
                                .controlSize(.large)
                                .disabled(true)
                        }
                    }
                    .fileExporter(
                        isPresented: $viewModel.isExporting,
                        document: viewModel.exportDocument,
                        contentType: .commaSeparatedText,
                        defaultFilename: "Export-\(Date().formatted(.iso8601.year().month().day())).csv"
                    ) { result in
                        switch result {
                        case .success(let destinationURL):
                            #if DEBUG
                            print("CSV saved directly to: \(destinationURL.path)")
                            #endif
                        case .failure(let error):
                            print("Failed to save CSV: \(error.localizedDescription)")
                        }
                    }
                    .alert("Items Need Review", isPresented: $viewModel.showExportAlert) {
                        Button("Export Anyway", role: .confirm) {
                            if let csvURL = viewModel.exportToCSV() {
                                viewModel.proceedWithExport(csvURL)
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        let count = viewModel.capturedText.filter { $0.needsReview }.count
                        Text("\(count) item\(count == 1 ? "" : "s") \(count == 1 ? "has" : "have") been marked as needing review. Export anyway?")
                    }
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(16)
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveShortcutSearch)) { notification in
            if let query = notification.userInfo?["query"] as? String {
                viewModel.searchText = query
                viewModel.search()
            }
        }
    }
}

#Preview {
    SearchView(sharedData: AppSharedData())
}
