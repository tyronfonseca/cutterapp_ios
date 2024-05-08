//
//  MainScreenData.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

struct MainScreenData : Codable {
    var result = String(localized: "empty_text")
    var dataUsed = String(localized: "empty_text_2")
    var versionSelected = CsvVersion.normal
}
