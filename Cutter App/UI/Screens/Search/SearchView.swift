//
//  SearchView.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI
import Foundation
import CoreData

enum SearchFilterOption: String, CaseIterable, Identifiable {
    case all = "All"
    case needsReview = "Needs Review"
    case reviewed = "Reviewed"
    
    var id: String { rawValue }
}

enum SearchSortOption: String, CaseIterable, Identifiable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case author = "Author (A-Z)"
    
    var id: String { rawValue }
}

struct SearchView: View {
    @Environment(AppSharedData.self) private var sharedData
    
    @State private var viewModel: SearchViewModel
    @State private var pendingCSVURL: URL?
    
    // MARK: - Filter & Sort State
    @State private var selectedFilter: SearchFilterOption = .all
    @State private var selectedSort: SearchSortOption = .newest
    
    // MARK: - Selection & Edit State
    @State private var editMode: EditMode = .inactive
    @State private var selectedItemIDs: Set<CutterData.ID> = []
    
    init(sharedData: AppSharedData, context: NSManagedObjectContext) {
        let repository = CutterDataRepository(context: context)
        self._viewModel = State(wrappedValue: SearchViewModel(sharedData: sharedData, repository: repository))
    }
    
    // MARK: - Computed Properties
    private var displayedItems: [CutterData] {
        // Filter by Review Status
        let filteredItems: [CutterData]
        switch selectedFilter {
        case .all:
            filteredItems = viewModel.capturedText
        case .needsReview:
            filteredItems = viewModel.capturedText.filter { $0.needsReview }
        case .reviewed:
            filteredItems = viewModel.capturedText.filter { $0.needsReview == false }
        }
        
        // Sort Items
        switch selectedSort {
        case .newest:
            return filteredItems.reversed()
        case .oldest:
            return filteredItems
        case .author:
            return filteredItems.sorted { $0.authorSurname.localizedCaseInsensitiveCompare($1.authorSurname) == .orderedAscending }
        }
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
                                    Text("Try: 'John Smith', 'John', 'Smith, John' or ISBN")
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
                    
                    // MARK: - Filter & Sort Bar Card
                    if !viewModel.capturedText.isEmpty {
                        HStack(spacing: 12) {
                            // Sort Control
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Picker("Sort Option", selection: $selectedSort) {
                                    ForEach(SearchSortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                            .tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .buttonStyle(.glass)
                                
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            
                            Spacer()
                            // Filter Control
                            HStack(spacing: 4) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Picker("Filter Option", selection: $selectedFilter) {
                                    ForEach(SearchFilterOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .buttonStyle(.glass)
                                
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                            
                        }
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
                        } else if displayedItems.isEmpty {
                            ContentUnavailableView(
                                "No Matching Items",
                                systemImage: "line.3.horizontal.decrease.circle",
                                description: Text("No entries match the selected filter criteria.")
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // Conditionally pass selection binding only during active multi-select
                            List(selection: isSelecting ? $selectedItemIDs : nil) {
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
                            .contentMargins(.bottom, isSelecting ? 16 : 88, for: .scrollContent)
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
                    } else {
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
