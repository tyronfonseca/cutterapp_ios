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
    
    // MARK: - getCutterQuery Unit Tests
    
    func testGetCutterQuery_standardFormatting_returnsLastNameFirst() {
        let settings = MockAppSettings(dontSeparateName: false)
        let options = CutterSearchOptions(settings: settings)
        
        let query = CutterSearchEngine.getCutterQuery(name: "John", lastName: "Smith", options: options)
        XCTAssertEqual(query, "SMITH, JOHN")
    }
    
    func testGetCutterQuery_dontSeparateName_returnsFirstNameFirst() {
        let settings = MockAppSettings(dontSeparateName: true)
        let options = CutterSearchOptions(settings: settings)
        
        let query = CutterSearchEngine.getCutterQuery(name: "John", lastName: "Smith", options: options)
        XCTAssertEqual(query, "JOHN SMITH")
    }
    
    func testGetCutterQuery_trimsWhitespace() {
        let settings = MockAppSettings()
        let options = CutterSearchOptions(settings: settings)
        
        let query = CutterSearchEngine.getCutterQuery(name: "  John  ", lastName: "  Smith ", options: options)
        XCTAssertEqual(query, "SMITH, JOHN")
    }
    
    func testGetCutterQuery_diacriticsAndAccents_removesAccents() {
        let settings = MockAppSettings()
        let options = CutterSearchOptions(settings: settings)
        
        let query = CutterSearchEngine.getCutterQuery(name: "René", lastName: "García", options: options)
        XCTAssertEqual(query, "GARCIA, RENE")
    }
    
    func testGetCutterQuery_formatMac_convertsMcAndMQuotePrefixes() {
        let settings = MockAppSettings(useFormatMac: true)
        let options = CutterSearchOptions(settings: settings)
        
        let mcQuery = CutterSearchEngine.getCutterQuery(name: "John", lastName: "McDonald", options: options)
        XCTAssertEqual(mcQuery, "MACDONALD, JOHN")
        
        let mQuoteQuery = CutterSearchEngine.getCutterQuery(name: "John", lastName: "M'Donald", options: options)
        XCTAssertEqual(mQuoteQuery, "MACDONALD, JOHN")
        
        let mcDotQuery = CutterSearchEngine.getCutterQuery(name: "John", lastName: "Mc.Donald", options: options)
        XCTAssertEqual(mcDotQuery, "MACDONALD, JOHN")
    }
    
    func testGetCutterQuery_formatMac_ignoresMidStringMc() {
        let settings = MockAppSettings(useFormatMac: true)
        let options = CutterSearchOptions(settings: settings)
        
        let query = CutterSearchEngine.getCutterQuery(name: "John", lastName: "DonaldMc", options: options)
        XCTAssertEqual(query, "DONALDMC, JOHN")
    }
    
    func testGetCutterQuery_ignoreArticles_stripsLeadingArticle() {
        let settings = MockAppSettings(ignoreArticles: true)
        let options = CutterSearchOptions(settings: settings)
        
        // Assuming leadingArticleRange strips leading articles like "The "
        let query = CutterSearchEngine.getCutterQuery(name: "John", lastName: "The Smith", options: options)
        XCTAssertEqual(query, "SMITH, JOHN")
    }
    
    
    // MARK: - search() Method Tests
    
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
    
    func testSearch_exactMatch_returnsCorrectDataAndMutatesOption() {
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
    
    func testSearch_truncatedQuery_returnsClosestMatch() {
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
    
    func testSearch_caseAndDiacriticInsensitive_matchesCorrectly() {
        let settings = MockAppSettings()
        let options = CutterSearchOptions(settings: settings)
        
        let result = CutterSearchEngine.search(
            queryName: "  john ",
            queryLastName: " SMITH ",
            in: sampleData,
            options: options
        )
        
        XCTAssertEqual(result?.code, "643")
    }
    
    // MARK: - SplitText Unit Tests

    func testSplitText_standardFormat_splitsCorrectly() {
        let result = CutterSearchEngine.splitText(text: "Smith, John")
        
        XCTAssertEqual(result.authorName, "John")
        XCTAssertEqual(result.authorSurname, "Smith")
    }
    
    func testSplitText_spaceSeparated_splitsLastWordAsSurname() {
        let result = CutterSearchEngine.splitText(text: "John Smith")
        XCTAssertEqual(result.authorName, "John")
        XCTAssertEqual(result.authorSurname, "Smith")
    }
    
    func testSplitText_multipleGivenNamesSpaceSeparated_splitsLastWordAsSurname() {
        let result = CutterSearchEngine.splitText(text: "Jean Luc Piccard")
        XCTAssertEqual(result.authorName, "Jean Luc")
        XCTAssertEqual(result.authorSurname, "Piccard")
    }

    func testSplitText_compoundLastName_splitsCorrectly() {
        let result = CutterSearchEngine.splitText(text: "De Santos, Rivaldo")
        
        XCTAssertEqual(result.authorName, "Rivaldo")
        XCTAssertEqual(result.authorSurname, "De Santos")
    }

    func testSplitText_accentsAndDiacritics_splitsCorrectly() {
        let result = CutterSearchEngine.splitText(text: "García, René")
        
        XCTAssertEqual(result.authorName, "René")
        XCTAssertEqual(result.authorSurname, "García")
    }

    func testSplitText_hyphensAndApostrophes_splitsCorrectly() {
        let result = CutterSearchEngine.splitText(text: "O'Brien, Jean-Luc")
        
        XCTAssertEqual(result.authorName, "Jean-Luc")
        XCTAssertEqual(result.authorSurname, "O'Brien")
    }

    func testSplitText_multipleGivenNames_splitsCorrectly() {
        let result = CutterSearchEngine.splitText(text: "Tolkien, John Ronald Reuel")
        
        XCTAssertEqual(result.authorName, "John Ronald Reuel")
        XCTAssertEqual(result.authorSurname, "Tolkien")
    }

    func testSplitText_singleNameWithoutComma_returnsEntireTextAsSurname() {
        let result = CutterSearchEngine.splitText(text: "Shakespeare")
        
        XCTAssertEqual(result.authorName, "")
        XCTAssertEqual(result.authorSurname, "Shakespeare")
    }
    
    func testSplitText_singleNameWithoutCommaAndSpaces_returnsEntireTextAsSurname() {
        let result = CutterSearchEngine.splitText(text: " Shakespeare ")
        
        XCTAssertEqual(result.authorName, "")
        XCTAssertEqual(result.authorSurname, "Shakespeare")
    }

    func testSplitText_missingSpaceAfterComma_SplitsCorrectly() {
        // Fails regex because there is no space after the comma
        let result = CutterSearchEngine.splitText(text: "Smith,John")
        
        XCTAssertEqual(result.authorName, "John")
        XCTAssertEqual(result.authorSurname, "Smith")
    }

    func testSplitText_emptyString_returnsEmptyStrings() {
        let result = CutterSearchEngine.splitText(text: "")
        
        XCTAssertEqual(result.authorName, "")
        XCTAssertEqual(result.authorSurname, "")
    }

}
