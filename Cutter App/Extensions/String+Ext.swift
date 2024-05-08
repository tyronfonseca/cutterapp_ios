//
//  String+Ext.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> Character {
        let index = self.index(startIndex, offsetBy: offset)
        return self[index]
    }
    
    func compareToInsen(rightStr: String) -> Bool {
        self.lowercased() == rightStr.lowercased()
    }
}
