//
//  CsvVersion.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/5/24.
//

import Foundation

enum CsvVersion: String, Codable, CaseIterable {
    case normal = "cutter_normal"
    case ucr = "cutter_ucr"
    
    var description: String {
        switch self{
        case .ucr: return String(localized: "abc_old")
        case .normal: return String(localized: "abc_normal")
        }
    }
}
