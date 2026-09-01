//
//  CutterData+Ext.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

// For unit testing purposes
extension CutterData : Equatable {
    static func == (lhs: CutterData, rhs: CutterData) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
}
