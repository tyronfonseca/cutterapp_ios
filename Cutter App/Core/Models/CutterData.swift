//
//  CutterData.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 1/9/26.
//

import Foundation

struct CutterData : Identifiable {
    let id = UUID()
    let name: String
    let code: String
    var searchValue: String = ""
    var isbn: String = ""
    var bookName: String = ""
    var ddc: String = ""
    
    var number: String {
        guard let firstLetter = name.first else {
            return code
        }
        return "\(firstLetter)\(code)".uppercased()
    }
    var cutterUsed: String {
        return "\(name):\(code)".uppercased()
    }
}
