//
//  CSVVersion.swift
//  Cutter App
//
//  Created by Tyron on 8/9/26.
//

import Foundation

enum CSVVersion: String, Codable, CaseIterable {
    // Make sure the cases matches the raw .csv file name
    case sanborn = "cutter_normal"
    case pha = "pha"
    
    var name: String {
        switch self{
        case .sanborn: return String(localized: "title_sanborn")
        case .pha: return String(localized: "title_pha")
        }
    }
    
    var description: String {
        switch self{
        case .sanborn: return String(localized: "description_sanborn")
        case .pha: return String(localized: "description_pha")
        }
    }
}
