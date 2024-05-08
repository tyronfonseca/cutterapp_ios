//
//  CutterData.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

struct CutterData {
    let name: String
    let value: String
}

// For unit testing purpouses
extension CutterData : Equatable {
    static func == (lhs: CutterData, rhs: CutterData) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
}
