//
//  SearchViewModel.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var capturedText: [CutterData] = []
    @Published var isSearchingISBN: Bool = false
    @Published var errorMessage: String = ""
    @Published var showErrorAlert: Bool = false
    
    private let cutterGetter = CutterGetter.shared
    
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
        let cutterResult: CutterData?
        var formattedSearchText = text
        
        if let lastSpaceIndex = text.range(of: " ", options: .backwards)?.lowerBound {
            let firstPart = String(text[..<lastSpaceIndex])
            let lastPart = String(text[text.index(after: lastSpaceIndex)...])
            
            cutterResult = cutterGetter.search(name: firstPart, lastName: lastPart)
            formattedSearchText = "\(lastPart), \(firstPart)"
        } else {
            cutterResult = cutterGetter.search(name: "", lastName: text)
        }
        
        if var cutter = cutterResult {
            cutter.searchValue = formattedSearchText
            return cutter
        }
        
        return nil
    }
    
    private func fetchBookByISBN(_ isbn: String) async throws -> BookDoc? {
        let urlString = "https://openlibrary.org/search.json?q=isbn:\(isbn)&fields=title,author_name,ddc"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Build URLRequest with required User-Agent and Contact Info headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("CutterApp/1.0 (contactfonsecasoftware@gmail.com)", forHTTPHeaderField: "User-Agent")
        request.setValue("contactfonsecasoftware@gmail.com.", forHTTPHeaderField: "From")
        
        // Configure URLCache (20MB Memory, 100MB Disk)
        let cache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "OpenLibraryCache")
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .useProtocolCachePolicy
        let session = URLSession(configuration: config)
        
        // Perform network request using configured session and request
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
                    let ddc = book.primaryDDC
                    
                    if var cutter = getCutter(author.isEmpty ? title : author) {
                        cutter.bookName = title
                        cutter.ddc = ddc
                        cutter.isbn = isbn
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
    
    func exportToCSV() -> URL? {
        guard !capturedText.isEmpty else { return nil }
        
        var csvString = "Search Input,Name,Code,Number,ISBN,Book Name,DDC\n"
        
        for item in capturedText {
            let cleanSearch = item.searchValue.replacingOccurrences(of: "\"", with: "\"\"")
            let cleanName = item.name.replacingOccurrences(of: "\"", with: "\"\"")
            let cleanBookName = item.bookName.replacingOccurrences(of: "\"", with: "\"\"")
            
            let row = "\"\(cleanSearch)\",\"\(cleanName)\",\"\(item.code)\",\"\(item.number)\",\"\(item.isbn)\",\"\(cleanBookName)\",\"\(item.ddc)\"\n"
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
