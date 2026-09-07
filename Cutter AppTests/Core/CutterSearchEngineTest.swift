//
//  CutterSearchEngineTests.swift
//  Cutter App Tests
//
//  Created by Tyron on 9/7/26.
//

import XCTest
@testable import Cutter_App

final class CutterSearchEngineTests: XCTestCase {
    
    private var sampleData: [CutterData]!
    
    override func setUp() {
        super.setUp()
        
        // Sorted mock dataset representing typical Cutter table entries
        sampleData = [
            CutterData(name: "A", code: "11"),
            CutterData(name: "Is", code: "73"),
            CutterData(name: "Isab", code: "74"),
            CutterData(name: "Isam", code: "75"),
            CutterData(name: "Isar", code: "76"),
            CutterData(name: "Isc", code: "77"),
            CutterData(name: "Ise", code: "78"),
            CutterData(name: "Ish", code: "79"),
            CutterData(name: "Isi", code: "81"),
            CutterData(name: "Isl", code: "82"),
            CutterData(name: "Ism", code: "83"),
            CutterData(name: "Isn", code: "84"),
            CutterData(name: "Iso", code: "85"),
            CutterData(name: "Iss", code: "86"),
            CutterData(name: "MacDonald", code: "135"),
            CutterData(name: "Smith", code: "642"),
            CutterData(name: "Smith, John", code: "643"),
            CutterData(name: "Smith, William", code: "644"),
            CutterData(name: "Z", code: "99")
        ]
    }
    
    override func tearDown() {
        sampleData = nil
        super.tearDown()
    }
    
    // MARK: - Basic Edge Cases
    
    func testSearch_withEmptyData_returnsNil() {
        let settings = MockAppSettings()
        let options = CutterSearchOptions(settings: settings)
        
        let result = CutterSearchEngine.search(
            queryName: "John",
            queryLastName: "Smith",
            in: [],
            options: options
        )
        
        XCTAssertNil(result)
    }
    
    // MARK: - Search Behavior & Binary Search
    
    func testSearch_exactMatch_returnsCorrectDataAndOption() {
        let settings = MockAppSettings(dontSeparateName: false)
        let options = CutterSearchOptions(settings: settings, dontSeparateName: false)
        
        let result = CutterSearchEngine.search(
            queryName: "John",
            queryLastName: "Smith",
            in: sampleData,
            options: options
        )
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.code, "643")
        XCTAssertFalse(result?.dontSeparateName ?? true)
    }
    
    func testSearch_fallbackToClosestPriorMatch() {
        let settings = MockAppSettings()
        let options = CutterSearchOptions(settings: settings)
        
        // "Smith, Robert" falls between "Smith, John" (643) and "Smith, William" (644)
        let result = CutterSearchEngine.search(
            queryName: "Robert",
            queryLastName: "Smith",
            in: sampleData,
            options: options
        )
        
        XCTAssertEqual(result?.code, "643")
    }
    
    func testSearch_truncatedQuery_returnsClosesMatch() {
        let settings = MockAppSettings()
        let options = CutterSearchOptions(settings: settings)
        
        // Searching for "Issacson" must match entry "Iss" (86) rather than falling back to "Is" (73)
        let result = CutterSearchEngine.search(
            queryName: "Walter",
            queryLastName: "Issacson",
            in: sampleData,
            options: options
        )
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.code, "86")
        XCTAssertEqual(result?.name, "Iss")
    }
    
    // MARK: - Options & Flag Tests
    
    func testSearch_dontSeparateNameOption_formatsQueryCorrectly() {
        let settings = MockAppSettings(dontSeparateName: true)
        let options = CutterSearchOptions(settings: settings)
        
        // Formats query as "John Smith" instead of "Smith, John"
        let data = [
            CutterData(name: "Jane Smith", code: "100"),
            CutterData(name: "John Smith", code: "101")
        ]
        
        let result = CutterSearchEngine.search(
            queryName: "John",
            queryLastName: "Smith",
            in: data,
            options: options
        )
        
        XCTAssertEqual(result?.code, "101")
        XCTAssertTrue(result?.dontSeparateName ?? false)
    }
    
    func testSearch_useFormatMacOption_convertsMcPrefix() {
        let settings = MockAppSettings(useFormatMac: true)
        let options = CutterSearchOptions(settings: settings)
        
        // "McDonald" should convert to "MacDonald" via regex and match "MacDonald"
        let result = CutterSearchEngine.search(
            queryName: "",
            queryLastName: "McDonald",
            in: sampleData,
            options: options
        )
        
        XCTAssertEqual(result?.code, "135")
    }
    
    func testSearch_useFormatMacOption_dontConvertsMcPrefix() {
        let settings = MockAppSettings(useFormatMac: true)
        let options = CutterSearchOptions(settings: settings)
        
        // "DonaldMc" should not convert to "DonaldMac"
        let result = CutterSearchEngine.search(
            queryName: "",
            queryLastName: "DonaldMc",
            in: sampleData,
            options: options
        )
        
        XCTAssertEqual(result?.name, "A")
        XCTAssertEqual(result?.code, "11")
    }
    
    func testSearch_ignoreArticlesOption_stripsLeadingArticle() {
        let settings = MockAppSettings(ignoreArticles: true)
        let options = CutterSearchOptions(settings: settings)
        
        let data = [
            CutterData(name: "Smith, John", code: "643")
        ]
        
        // "The Smith" -> Strips "The " -> "Smith, John"
        let result = CutterSearchEngine.search(
            queryName: "John",
            queryLastName: "The Smith",
            in: data,
            options: options
        )
        
        XCTAssertEqual(result?.code, "643")
    }
    
    // MARK: - Whitespace & Case Insensitivity
    
    func testSearch_trimsWhitespacesAndIgnoresCase() {
        let settings = MockAppSettings()
        let options = CutterSearchOptions(settings: settings)
        
        let result = CutterSearchEngine.search(
            queryName: "   john  ",
            queryLastName: "   SMITH ",
            in: sampleData,
            options: options
        )
        
        XCTAssertEqual(result?.code, "643")
    }
}
