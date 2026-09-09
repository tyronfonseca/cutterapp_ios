//
//  SearchView.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI
import Foundation
import CoreData

struct SearchView: View {
    @Environment(AppSharedData.self) private var sharedData
    
    @State private var viewModel: SearchViewModel
    @State private var pendingCSVURL: URL?
    
    // MARK: - Selection & Edit State
    @State private var editMode: EditMode = .inactive
    @State private var selectedItemIDs: Set<CutterData.ID> = []
    
    init(sharedData: AppSharedData, context: NSManagedObjectContext) {
        let repository = CutterDataRepository(context: context)
        self._viewModel = State(wrappedValue: SearchViewModel(sharedData: sharedData, repository: repository))
    }
    
    // MARK: - Computed Properties
    private var displayedItems: [CutterData] {
        let items = viewModel.showOnlyNeedsReview
        ? viewModel.capturedText.filter { $0.needsReview }
        : viewModel.capturedText
        return items.reversed()
    }
    
    private var isSelecting: Bool {
        editMode.isEditing
    }
    
    var body: some View {
        let bindableViewModel = Bindable(viewModel)
        
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // MARK: - Main Content Layer
                VStack(alignment: .center, spacing: 0) {
                    // Search Input Card (Hidden during Selection)
                    if !isSelecting {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Enter author name or scan text", text: bindableViewModel.searchText)
                                    .padding(14)
                                    .glassEffect()
                                    .onSubmit {
                                        viewModel.search()
                                    }
                                
                                HStack {
                                    Image(systemName: "info.circle")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\"Name Surname\", \"Name\", \"Surname, Name\" or ISBN.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            HStack(spacing: 8) {
                                if !ProcessInfo.processInfo.isiOSAppOnMac {
                                    Button(action: { viewModel.showScanner = true }) {
                                        Label("Scan", systemImage: "document.viewfinder")
                                    }
                                    .sheet(isPresented: bindableViewModel.showScanner) {
                                        OCRCameraView(searchText: bindableViewModel.searchText)
                                    }
                                    .buttonStyle(.glass)
                                }
                                
                                Spacer()
                                
                                if viewModel.isSearchingISBN {
                                    ProgressView()
                                        .padding(.horizontal, 8)
                                } else {
                                    Button(action: { viewModel.search() }) {
                                        Label("Search", systemImage: "magnifyingglass")
                                    }
                                    .buttonStyle(.glassProminent)
                                    .disabled(viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                            }
                        }
                        .padding()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Divider()
                    }
                    
                    // Filter Bar
                    if !viewModel.capturedText.isEmpty && viewModel.capturedText.contains(where: { $0.needsReview }) {
                        HStack {
                            Text("Show only needing review")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
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
                    
                    // MARK: - List View
                    Group {
                        if viewModel.capturedText.isEmpty {
                            ContentUnavailableView(
                                "No entries yet",
                                systemImage: "book.closed.fill",
                                description: Text("Add an entry by scanning or entering an author name or ISBN")
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(selection: $selectedItemIDs) {
                                ForEach(displayedItems) { item in
                                    NavigationLink {
                                        EditSearchItemView(
                                            item: binding(for: item),
                                            onDelete: { viewModel.deleteItem(item) },
                                            onEdit: { updatedItem in viewModel.update(updatedItem) }
                                        )
                                    } label: {
                                        SearchItemView(item: item)
                                    }
                                    .tag(item.id)
                                }
                                .onDelete { indexSet in
                                    let itemsToDelete = indexSet.map { displayedItems[$0] }
                                    let idsToDelete = Set(itemsToDelete.map(\.id))
                                    viewModel.deleteItem(at: idsToDelete)
                                }
                            }
                            .listStyle(.plain)
                            .environment(\.editMode, $editMode)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .layoutPriority(1)
                    .alert("Search Error", isPresented: bindableViewModel.showErrorAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(viewModel.errorMessage)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // MARK: - Floating Single Export Button (Normal Mode Only)
                if !isSelecting {
                    Button(action: {
                        exportItems(displayedItems)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.extraLarge)
                    .disabled(displayedItems.isEmpty)
                    .clipShape(Circle())
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: editMode)
            .fileExporter(
                isPresented: bindableViewModel.isExporting,
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
            .alert("Items Need Review", isPresented: bindableViewModel.showExportAlert) {
                Button("Export Anyway", role: .confirm) {
                    if let url = pendingCSVURL {
                        viewModel.proceedWithExport(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                let count = viewModel.capturedText.filter { $0.needsReview }.count
                Text("\(count) item\(count == 1 ? "" : "s") \(count == 1 ? "has" : "have") been marked as needing review. Export anyway?")
            }
            
            // MARK: - Bottom Action Bar (Select Mode Only)
            .toolbar {
                if isSelecting {
                    
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(role: .destructive) {
                                viewModel.showDeleteAllAlert = true
                            } label: {
                                Label("Delete (\(selectedItemIDs.count))", systemImage: "trash")
                            }
                            .disabled(selectedItemIDs.isEmpty)
                            
                            Spacer()
                            
                            Button {
                                if selectedItemIDs.count == displayedItems.count {
                                    selectedItemIDs.removeAll()
                                } else {
                                    selectedItemIDs = Set(displayedItems.map(\.id))
                                }
                            } label: {
                                Text(selectedItemIDs.count == displayedItems.count ? "Deselect All" : "Select All")
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .title) {
                    Image(.longLogo)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                        .foregroundStyle(.logo)
                        .accessibilityLabel(Text("logo_description"))
                        .accessibilityAddTraits(.isImage)
                }
                
                // MARK: - Navigation Bar Menu
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelecting {
                        Button("Done") {
                            withAnimation {
                                editMode = .inactive
                                selectedItemIDs.removeAll()
                            }
                        }
                        .fontWeight(.bold)
                    } else {
                        Menu {
                            Button {
                                withAnimation { editMode = .active }
                            } label: {
                                Label("Select Items", systemImage: "checkmark.circle")
                            }
                            .disabled(viewModel.capturedText.isEmpty)
                            
                            Button(role: .destructive) {
                                viewModel.showDeleteAllAlert = true
                            } label: {
                                Label("Delete All", systemImage: "trash.circle")
                            }
                            .disabled(viewModel.capturedText.isEmpty)
                            
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
            }
            .alert("Are you sure you want to delete \(selectedItemIDs.isEmpty ? "all": "the selected \(selectedItemIDs.count) items")?", isPresented: $viewModel.showDeleteAllAlert) {
                Button("Delete All", role: .destructive) {
                    if selectedItemIDs.isEmpty {
                        viewModel.reset()
                    }else {
                        viewModel.deleteItem(at: selectedItemIDs)
                        selectedItemIDs.removeAll()
                        withAnimation { editMode = .inactive }
                    }
                    
                }
                Button("Cancel", role: .cancel) { }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar(editMode.isEditing ? .hidden : .visible, for: .tabBar)
        .animation(.easeInOut(duration: 0.2), value: editMode)
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveShortcutSearch)) { notification in
            if let query = notification.userInfo?["query"] as? String {
                viewModel.searchText = query
                viewModel.search()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func exportItems(_ items: [CutterData]) {
        if let csvURL = viewModel.exportToCSV(items: items) {
            pendingCSVURL = csvURL
            viewModel.checkAndExport(csvURL)
        }
    }
    
    private func binding(for item: CutterData) -> Binding<CutterData> {
        Binding(
            get: {
                viewModel.capturedText.first(where: { $0.id == item.id }) ?? item
            },
            set: { newValue in
                if let index = viewModel.capturedText.firstIndex(where: { $0.id == item.id }) {
                    viewModel.capturedText[index] = newValue
                }
            }
        )
    }
}

#Preview {
    let container = NSPersistentContainer(name: "CutterApp")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores { _, error in
        if let error = error {
            fatalError("Failed to load in-memory Core Data: \(error)")
        }
    }
    
    let context = container.viewContext
    let sharedData = AppSharedData()
    
    return SearchView(sharedData: sharedData, context: context)
        .environment(sharedData)
}
