//
//  CutterGetterTests.swift
//  Cutter AppTests
//
//  Created by Tyron Fonseca on 7/5/24.
//

import XCTest
@testable import Cutter_App

final class CutterGetterTests: XCTestCase {
    private let expected = [CutterData(name: "Andrade", value: "254")
                            , CutterData(name: "Fons, X", value: "24")
                            , CutterData(name: "Zamora", value: "10")]
    
    func test_search_exact(){
        // act
        let result = CutterGetter.shared.search(name: "x", lastName: "fons", _data: expected)
        // assert
        XCTAssertEqual(expected[1], result)
    }
    
    func test_search_close(){
        // act
        let result = CutterGetter.shared.search(name: "x", lastName: "fonsec", _data: expected)
        // assert
        XCTAssertEqual(expected[1], result)
    }
    
    func test_search_before(){
        // act
        let result = CutterGetter.shared.search(name: "x", lastName: "barrantes", _data: expected)
        // assert
        XCTAssertEqual(expected[0], result)
    }
    
    func test_search_after(){
        // act
        let result = CutterGetter.shared.search(name: "M", lastName: "ZZZZ", _data: expected)
        // assert
        XCTAssertEqual(expected[2], result)
    }
    
    
}
