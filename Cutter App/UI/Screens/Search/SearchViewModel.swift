//
//  SearchViewModel.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI
import Foundation

private func localizedError(_ key: String, _ args: CVarArg...) -> String {
    String(format: NSLocalizedString(key, comment: "Error message"), arguments: args)
}

@Observable
final class SearchViewModel {
    var searchText: String = ""
    var capturedText: [CutterData] = []
    var isSearchingISBN: Bool = false
    var errorMessage: String = ""
    var showErrorAlert: Bool = false
    var showScanner: Bool = false
    var isExporting: Bool = false
    var exportDocument: CSVFile?
    var showOnlyNeedsReview: Bool = false
    var showExportAlert: Bool = false
    var showDeleteAllAlert: Bool = false
    
    let sharedData: AppSharedData
    private let repository: CutterDataRepositoryProtocol
    
    init(sharedData: AppSharedData, repository: CutterDataRepositoryProtocol) {
        self.sharedData = sharedData
        self.repository = repository
        self.loadCapturedText()
    }
    
    // MARK: - Persistence Operations
    
    func loadCapturedText() {
        self.capturedText = repository.fetchAll()
    }
    
    func deleteItem(at ids: Set<UUID>) {
        for id in ids {
            repository.delete(id: id)
        }
        
        // Remove matching items from main array by ID
        capturedText.removeAll { ids.contains($0.id) }
        
        //Reset filter state if needed
        if showOnlyNeedsReview && !capturedText.contains(where: \.needsReview) {
            showOnlyNeedsReview = false
        }
    }
    
    func deleteItem(_ item: CutterData) {
        deleteItem(at: [item.id])
    }
    
    func update(_ item: CutterData) {
        repository.update(item)
    }
    
    func reset() {
        repository.deleteAll()
        capturedText.removeAll()
        searchText = ""
        errorMessage = ""
        showErrorAlert = false
    }
    
    // MARK: - Search Operations
    
    func search() {
        let text = self.searchText.trimmingCharacters(in: .whitespaces)
        if text.isEmpty { return }
        
        if let isbn = text.extractISBNs().first {
            authorByISBN(isbn)
            return
        }
        
        if let cutter = getCutter(text) {
            capturedText.append(cutter)
            repository.save(cutter)
            searchText = ""
        } else {
            presentError(localizedError("error_no_cutter_match", text))
        }
    }
    
    private func presentError(_ message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
    
    private func getCutter(_ text: String) -> CutterData? {
        let parsed = CutterSearchEngine.splitText(text: text)
        let options = CutterSearchOptions(settings: sharedData.settings)
        
        if let cutter = sharedData.search(name: parsed.authorName, lastName: parsed.authorSurname, options: options) {
            var updatedCutter = cutter
            updatedCutter.id = UUID()
            updatedCutter.authorName = parsed.authorName
            updatedCutter.authorSurname = parsed.authorSurname
            return updatedCutter
        }
        
        return nil
    }
    
    private func fetchBookByISBN(_ isbn: String) async throws -> BookDoc? {
        let urlString = "https://openlibrary.org/search.json?q=isbn:\(isbn)&fields=title,author_name,ddc"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("CutterApp/1.0 (contactfonsecasoftware@gmail.com)", forHTTPHeaderField: "User-Agent")
        request.setValue("contactfonsecasoftware@gmail.com", forHTTPHeaderField: "From")
        
        let cache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "OpenLibraryCache")
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .useProtocolCachePolicy
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(OpenLibraryResponse.self, from: data)
        return decodedResponse.docs.first
    }
    
    private func authorByISBN(_ isbn: String) {
        Task {
            isSearchingISBN = true
            defer { isSearchingISBN = false }
            
            do {
                if let book = try await fetchBookByISBN(isbn) {
                    let title = book.title ?? "Unknown Title"
                    let author = book.authorName?.first ?? ""
                    let ddc = book.ddc ?? []
                    
                    if var cutter = getCutter(author.isEmpty ? title : author) {
                        cutter.bookName = title
                        cutter.ddcs = ddc
                        cutter.isbn = isbn
                        cutter.needsReview = true
                        
                        capturedText.append(cutter)
                        repository.save(cutter)
                        searchText = ""
                    } else {
                        presentError(localizedError("error_cutter_code_generation", title))
                    }
                } else {
                    presentError(localizedError("error_no_book_found", isbn))
                }
            } catch {
                presentError(localizedError("error_network", error.localizedDescription))
            }
        }
    }
    
    func checkAndExport(_ url: URL) {
        let itemsNeedingReview = capturedText.filter { $0.needsReview }
        
        if !itemsNeedingReview.isEmpty {
            showExportAlert = true
        } else {
            proceedWithExport(url)
        }
    }
    
    func proceedWithExport(_ url: URL) {
        exportDocument = CSVFile(url: url)
        isExporting = true
    }
    
    func exportToCSV(items: [CutterData]) -> URL? {
        return CSVHelper.exportToCSV(with: items, settings: sharedData.settings)
    }
}

