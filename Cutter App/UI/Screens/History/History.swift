import SwiftUI
import CoreData

struct SearchHistory: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HistoryViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: HistoryViewModel())
    }
    
    var body: some View {
        Group {
            if viewModel.searchHistory.isEmpty {
                ContentUnavailableView(
                    "history_empty",
                    systemImage: "book.closed.fill",
                    description: Text("history_empty_description")
                )
            } else if viewModel.filteredSearchHistory.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                List(selection: $viewModel.selectedItems) {
                    ForEach(viewModel.filteredSearchHistory) { result in
                        SearchResultItem(result: result)
                    }
                    .onDelete(perform: { offsets in
                        viewModel.deleteItem(at: offsets, from: viewModel.filteredSearchHistory)
                    })
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.toggleEditMode()
                    } label: {
                        Label(
                            viewModel.editMode.isEditing ? "Done Selecting" : "Select Items",
                            systemImage: viewModel.editMode.isEditing ? "checkmark.circle" : "checkmark.circle.fill"
                        )
                    }
                    
                    Divider()
                    
                    Button {
                        if viewModel.editMode.isEditing && !viewModel.selectedItems.isEmpty {
                            viewModel.exportSelectedToCSV()
                        } else {
                            viewModel.exportAllToCSV()
                        }
                    } label: {
                        Label(
                            viewModel.editMode.isEditing && !viewModel.selectedItems.isEmpty
                            ? "Export Selected (\(viewModel.selectedItems.count))"
                            : "Export All CSV",
                            systemImage: "square.and.arrow.down"
                        )
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        viewModel.showingDeleteConfirmation = true
                    } label: {
                        Label(
                            viewModel.editMode.isEditing && !viewModel.selectedItems.isEmpty
                            ? "Delete Selected (\(viewModel.selectedItems.count))"
                            : "Delete All History",
                            systemImage: "trash"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .disabled(viewModel.searchHistory.isEmpty)
            }
        }
        .navigationTitle("search_history_title")
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Search history")
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .environment(\.editMode, $viewModel.editMode)
        .alert(
            viewModel.deleteAlertTitle(selectedCount: viewModel.selectedItems.count),
            isPresented: $viewModel.showingDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                if viewModel.editMode.isEditing && !viewModel.selectedItems.isEmpty {
                    viewModel.deleteSelected(from: viewModel.filteredSearchHistory)
                } else {
                    viewModel.deleteAllHistory()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear {viewModel.setContext(viewContext)}
    }
}
