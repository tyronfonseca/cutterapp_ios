//
//  SearchViewModel.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI
import Foundation

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
    var showEditItem: Bool = false
    var showOnlyNeedsReview: Bool = false
    var showExportAlert: Bool = false
    
    let sharedData: AppSharedData
    
    private let pattern = "^([a-zA-Z]+),\\s([a-zA-Z]+)$"
    private var cutterRegex : NSRegularExpression?

    init(sharedData: AppSharedData) {
        self.sharedData = sharedData
        cutterRegex = try? NSRegularExpression(pattern: pattern)
    }
    
    func reset() {
        capturedText.removeAll()
        searchText = ""
        errorMessage = ""
        showErrorAlert = false
    }
    
    func search() {
        let text = self.searchText.trimmingCharacters(in: .whitespaces)
        if text.isEmpty { return }
        
        if let isbn = text.extractISBNs().first {
            authorByISBN(isbn)
            return
        }
        
        if let cutter = getCutter(text) {
            capturedText.append(cutter)
            searchText = ""
        } else {
            presentError("No Cutter match found for '\(text)'")
        }
    }
    
    private func presentError(_ message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
    
    private func getCutter(_ text: String) -> CutterData? {
        let range = NSRange(text.startIndex..., in: text)
        let matchesRegex = cutterRegex?.firstMatch(in: text, range: range) != nil
        
        let dontSeparateName = sharedData.dontSeparateName
        let authorName: String
        let authorSurname: String
        
        if !dontSeparateName, !matchesRegex, let lastSpaceIndex = text.range(of: " ", options: .backwards)?.lowerBound {
            authorName = String(text[..<lastSpaceIndex])
            authorSurname = String(text[text.index(after: lastSpaceIndex)...])
        } else {
            authorName = ""
            authorSurname = text
        }
        
        if var cutter = sharedData.search(name: authorName, lastName: authorSurname, dontSeparateName: dontSeparateName) {
            var updatedCutter = cutter
            updatedCutter.id = UUID()
            updatedCutter.authorName = authorName
            updatedCutter.authorSurname = authorSurname
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
        request.setValue("contactfonsecasoftware@gmail.com.", forHTTPHeaderField: "From")
        
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
            
            defer {
                isSearchingISBN = false
            }
            
            do {
                if let book = try await fetchBookByISBN(isbn) {
                    let title = book.title ?? "Unknown Title"
                    let author = book.authorName?.first ?? ""
                    let ddc = book.ddc ?? []
                    
                    if var cutter = getCutter(author.isEmpty ? title : author) {
                        cutter.bookName = title
                        cutter.ddc = ddc
                        cutter.isbn = isbn
                        cutter.needsReview = true
                        capturedText.append(cutter)
                        searchText = ""
                    } else {
                        presentError("Found book '\(title)', but couldn't generate Cutter code for author.")
                    }
                } else {
                    presentError("No book found for ISBN: \(isbn)")
                }
            } catch {
                presentError("Network error: \(error.localizedDescription)")
                print("Failed to fetch or parse JSON: \(error.localizedDescription)")
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
    
    func exportToCSV() -> URL? {
        guard !capturedText.isEmpty else { return nil }
        
        var csvString = "Author Name,Author Surname,Name,Code,Number,ISBN,Book Name,DDC\n"
        
        for item in capturedText {
            let cleanName = item.name.replacingOccurrences(of: "\"", with: "\"\"")
            let cleanBookName = item.bookName.replacingOccurrences(of: "\"", with: "\"\"")
            
            let row = "\"\(item.authorName)\",\"\(item.authorSurname)\",\"\(cleanName)\",\"\(item.code)\",\"\(item.number)\",\"\(item.isbn)\",\"\(cleanBookName)\",\"\(item.ddc)\"\n"
            csvString.append(row)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        
        let fileName = "CutterApp_\(dateString).csv"
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempFileURL, atomically: true, encoding: .utf8)
            return tempFileURL
        } catch {
            print("Failed to save temporary CSV file: \(error.localizedDescription)")
            return nil
        }
    }
}
