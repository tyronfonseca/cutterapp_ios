//
//  SearchView.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI
import Foundation

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var showScanner: Bool = false
    @State private var isExporting = false
    @State private var exportDocument: CSVFile?
    
    init() {
        self._viewModel = StateObject(wrappedValue: SearchViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack (
                alignment: .center,
                spacing: 0
            ){
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
                        Text("Author Name (or Name Lastname) or ISBN")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("Enter author name or scan text", text: $viewModel.searchText)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    HStack(spacing: 8) {
                        if !ProcessInfo.processInfo.isiOSAppOnMac {
                            Button(action: { showScanner = true }) {
                                Label("Scan", systemImage: "document.viewfinder")
                            }
                            .sheet(isPresented: $showScanner) {
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
                                Text("Add")
                                    .bold()
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
                
                VStack (
                    alignment: .leading,
                ) {
                    if viewModel.capturedText.isEmpty {
                        ContentUnavailableView(
                            "No captures yet",
                            systemImage: "book.closed.fill",
                            description: Text("Add a capture by scanning or entering an author name or ISBN")
                        )
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.capturedText) { cutter in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(cutter.searchValue)
                                                .font(.body)
                                                .fontWeight(.medium)
                                            HStack {
                                                Text(cutter.cutterUsed)
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                
                                                if(!cutter.isbn.isEmpty) {
                                                    Text("ISBN: \(cutter.isbn)")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Cutter Value Badge
                                        VStack {
                                            Text(cutter.number)
                                                .font(.callout)
                                                .fontDesign(.monospaced)
                                                .fontWeight(.semibold)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.12))
                                                .foregroundColor(.blue)
                                                .clipShape(Capsule())
                                            if !cutter.ddc.isEmpty {
                                                Text("DDC: \(cutter.ddc)")
                                                    .font(.caption)
                                                    .fontDesign(.monospaced)
                                                    .fontWeight(.semibold)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.12))
                                                    .foregroundColor(.green)
                                                    .clipShape(Capsule())
                                            }
                                            
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .alert("Search Error", isPresented: $viewModel.showErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage)
                }
                
                Spacer()
                Divider()
                
                HStack{
                    Button("Reset") {
                        viewModel.reset()
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .disabled(viewModel.capturedText.isEmpty)
                    
                    Spacer()
                    Group {
                        if let csvURL = viewModel.exportToCSV() {
                            if ProcessInfo.processInfo.isiOSAppOnMac {
                                Button(action: {
                                    exportDocument = CSVFile(url: csvURL)
                                    isExporting = true
                                }) {
                                    Label("Save CSV", systemImage: "doc.badge.plus")
                                }
                                .buttonStyle(.glassProminent)
                                .controlSize(.large)
                            } else {
                                ShareLink(
                                    item: csvURL,
                                    preview: SharePreview(
                                        "Export to CSV (\(viewModel.capturedText.count) items)",
                                        image: Image(systemName: "doc.text")
                                    )
                                ) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .buttonStyle(.glassProminent)
                                .controlSize(.large)
                            }
                        } else {
                            Button("Share", systemImage: "square.and.arrow.up") {}
                                .buttonStyle(.glassProminent)
                                .controlSize(.large)
                                .disabled(true)
                        }
                    }
                    .fileExporter(
                        isPresented: $isExporting,
                        document: exportDocument,
                        contentType: .commaSeparatedText,
                        defaultFilename: "Export-\(Date().formatted(.iso8601.year().month().day())).csv"
                    ) { result in
                        switch result {
                        case .success(let destinationURL):
                            print("CSV saved directly to: \(destinationURL.path)")
                        case .failure(let error):
                            print("Failed to save CSV: \(error.localizedDescription)")
                        }
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
    SearchView()
}
