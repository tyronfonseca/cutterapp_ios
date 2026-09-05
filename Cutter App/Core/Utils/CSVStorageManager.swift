//
//  CSVStorageManager.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import Foundation

final class CSVStorageManager {
    static let shared = CSVStorageManager()
    private init() {}

    func copyToApplicationSupport(sourceURL: URL, targetFilename: String) -> URL? {
        let fileManager = FileManager.default
        guard let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }

        if !fileManager.fileExists(atPath: appSupportDirectory.path) {
            try? fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        }

        let destinationURL = appSupportDirectory.appendingPathComponent(targetFilename)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Error saving custom CSV: \(error.localizedDescription)")
            return nil
        }
    }

    func getURL(for filename: String) -> URL? {
        let fileManager = FileManager.default
        
        guard let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        if !fileManager.fileExists(atPath: appSupportDirectory.path) {
            try? fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        }
        
        let cleanFilename = (filename as NSString).lastPathComponent
        let url = appSupportDirectory.appendingPathComponent(cleanFilename)
        
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    func deleteFile(filename: String) {
        if let url = getURL(for: filename) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
