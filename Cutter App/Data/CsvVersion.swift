//
//  CsvVersion.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/5/24.
//

import Foundation

enum CsvVersion: String, Codable, CaseIterable {
    case normal = "cutter_normal"
    case old = "cutter_old"
    
    var description: String {
        switch self{
        case .old: return String(localized: "abc_old")
        case .normal: return String(localized: "abc_normal")
        }
    }
}
