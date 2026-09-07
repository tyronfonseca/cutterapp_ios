//
//  CSVFile.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVFile: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var initialURL: URL?

    init(url: URL?) {
        self.initialURL = url
    }

    init(configuration: ReadConfiguration) throws {
        self.initialURL = nil
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        if let initialURL = initialURL {
            return try FileWrapper(url: initialURL, options: .immediate)
        }
        return FileWrapper(regularFileWithContents: Data())
    }
}
