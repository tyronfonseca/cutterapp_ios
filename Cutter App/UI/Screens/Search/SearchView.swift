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
                                TextField("search_placeholder", text: bindableViewModel.searchText)
                                    .padding(14)
                                    .glassEffect()
                                    .onSubmit {
                                        viewModel.search()
                                    }
                                    .accessibilityIdentifier("search_main_textfield")
                                
                                HStack {
                                    Image(systemName: "info.circle")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("search_examples")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityIdentifier("search_textfield_hint")
                            }
                            
                            HStack(spacing: 8) {
                                if !ProcessInfo.processInfo.isiOSAppOnMac {
                                    Button(action: { viewModel.showScanner = true }) {
                                        Label("scan", systemImage: "document.viewfinder")
                                    }
                                    .sheet(isPresented: bindableViewModel.showScanner) {
                                        OCRCameraView(searchText: bindableViewModel.searchText)
                                    }
                                    .buttonStyle(.glass)
                                    .accessibilityIdentifier("search_scan_button")
                                }
                                
                                Spacer()
                                
                                if viewModel.isSearchingISBN {
                                    ProgressView()
                                        .padding(.horizontal, 8)
                                        .accessibilityIdentifier("search_isbn_progress")
                                } else {
                                    Button(action: { viewModel.search() }) {
                                        Label("search", systemImage: "magnifyingglass")
                                    }
                                    .accessibilityIdentifier("search_button")
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
                            SearchMenuPicker(
                                iconName: "arrow.up.arrow.down",
                                titleKey: "search_sort_by",
                                iconAccessibilityID: "search_sort_by_icon",
                                pickerAccessibilityID: "search_sort_by_picker",
                                selection: $selectedSort
                            )
                            
                            Spacer()
                            // Filter Control
                            SearchMenuPicker(
                                iconName: "line.3.horizontal.decrease.circle",
                                titleKey: "search_filter_by",
                                iconAccessibilityID: "search_filter_by_icon",
                                pickerAccessibilityID: "search_filter_by_picker",
                                selection: $selectedFilter
                            )
                           
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - List View
                    Group {
                        if viewModel.capturedText.isEmpty {
                            ContentUnavailableView(
                                "search_no_entries",
                                systemImage: "book.closed.fill",
                                description: Text("search_no_entries_description")
                            )
                            .accessibilityIdentifier("search_no_entries_view")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if displayedItems.isEmpty {
                            ContentUnavailableView(
                                "search_no_mathcing_items",
                                systemImage: "line.3.horizontal.decrease.circle",
                                description: Text("search_no_mathcing_items_description")
                            )
                            .accessibilityIdentifier("search_no_matching_items_view")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // Conditionally pass selection binding only during active multi-select
                            List(selection: isSelecting ? $selectedItemIDs : nil) {
                                ForEach(Array(displayedItems.enumerated()), id: \.element.id) { index, item in
                                    NavigationLink {
                                        EditSearchItemView(
                                            item: binding(for: item),
                                            onDelete: { viewModel.deleteItem(item) },
                                            onEdit: { updatedItem in viewModel.update(updatedItem) }
                                        )
                                    } label: {
                                        SearchItemView(item: item)
                                            .accessibilityIdentifier("search_result_item-\(index)")
                                    }
                                    .tag(item.id)
                                }
                                .onDelete { indexSet in
                                    let itemsToDelete = indexSet.map { displayedItems[$0] }
                                    let idsToDelete = Set(itemsToDelete.map(\.id))
                                    viewModel.deleteItem(at: idsToDelete)
                                }
                            }
                            .accessibilityIdentifier("search_results_list")
                            .listStyle(.plain)
                            .environment(\.editMode, $editMode)
                            .contentMargins(.bottom, isSelecting ? 16 : 88, for: .scrollContent)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .layoutPriority(1)
                    .alert("search_error", isPresented: bindableViewModel.showErrorAlert) {
                        Button("ok", role: .cancel) { }
                            .accessibilityIdentifier("search_error_alert")
                    } message: {
                        Text(viewModel.errorMessage)
                            .accessibilityIdentifier("search_error_message")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // MARK: - Floating Single Export Button (Normal Mode Only)
                if !isSelecting {
                    Button(action: {
                        exportItems(displayedItems)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityLabel(Text("export_to_csv"))
                            .accessibilityIdentifier("export_button_image")
                            .font(.title2)
                    }
                    .accessibilityIdentifier("export_button")
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
            .alert("search_export_alert_title", isPresented: bindableViewModel.showExportAlert) {
                Button("search_export_alert_btn", role: .confirm) {
                    if let url = pendingCSVURL {
                        viewModel.proceedWithExport(url)
                    }
                }.accessibilityIdentifier("search_export_alert_btn")
                Button("cancel", role: .cancel) { }
                    .accessibilityIdentifier("search_export_alert_cancel")
            } message: {
                let count = viewModel.capturedText.filter { $0.needsReview }.count
                Text(.searchExportConfirmation(count, count == 1 ? "" : "s", count == 1 ? "has" : "have"))
                    .accessibilityIdentifier("search_export_alert_message")
            }
            
            // MARK: - Bottom Action Bar (Select Mode Only)
            .toolbar {
                if isSelecting {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button(role: .destructive) {
                                viewModel.showDeleteAllAlert = true
                            } label: {
                                Label(.searchDeleteCount(selectedItemIDs.count), systemImage: "trash")
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
                                Text(selectedItemIDs.count == displayedItems.count ? String(localized: "deselect_all") : String(localized:"select_all"))
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
                        .accessibilityIdentifier("search_app_logo")
                }
                
                // MARK: - Navigation Bar Menu
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelecting {
                        Button("done") {
                            withAnimation {
                                editMode = .inactive
                                selectedItemIDs.removeAll()
                            }
                        }
                        .accessibilityIdentifier("search_edit_done")
                        .fontWeight(.bold)
                    } else {
                        Menu {
                            Button {
                                withAnimation { editMode = .active }
                            } label: {
                                Label("select_items", systemImage: "checkmark.circle")
                            }
                            .accessibilityIdentifier("search_select_items")
                            .disabled(viewModel.capturedText.isEmpty)
                            
                            Button(role: .destructive) {
                                viewModel.showDeleteAllAlert = true
                            } label: {
                                Label("delete_all", systemImage: "trash.circle")
                            }
                            .accessibilityIdentifier("search_delete_all")
                            .disabled(viewModel.capturedText.isEmpty)
                            
                        }  label: {
                            Label("more_actions", systemImage: "ellipsis")
                        }
                        .accessibilityIdentifier("search_more_actions")
                    }
                }
            }
            .alert(.searchDeleteConfirmation("All"), isPresented: $viewModel.showDeleteAllAlert) {
                Button("delete_all", role: .destructive) {
                    if selectedItemIDs.isEmpty {
                        viewModel.reset()
                    } else {
                        viewModel.deleteItem(at: selectedItemIDs)
                        selectedItemIDs.removeAll()
                        withAnimation { editMode = .inactive }
                    }
                    
                }
                .accessibilityIdentifier("search_delete_all_confirm")
                
                Button("cancel", role: .cancel) { }
                    .accessibilityIdentifier("search_delete_all_cancel")
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
