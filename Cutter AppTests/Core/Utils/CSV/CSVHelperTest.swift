//
//  CSVHelperTest.swift
//  Cutter App
//
//  Created by Tyron on 7/9/26.
//

import XCTest
@testable import Cutter_App

final class CSVHelperTests: XCTestCase {

    private var temporaryFileURLs: [URL] = []

    override func tearDown() {
        // Cleanup temporary files generated during tests
        for url in temporaryFileURLs {
            try? FileManager.default.removeItem(at: url)
        }
        temporaryFileURLs.removeAll()
        super.tearDown()
    }

    // MARK: - Parsing String Tests

    func testParse_withHeaders_removesHeaderRow() {
        let csvContent = """
        Name,Code
        "Smith, John","S643"
        "MacDonald","M135"
        """

        let result = CSVHelper.parse(csvString: csvContent, hasHeaders: true)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.name, "Smith, John")
        XCTAssertEqual(result.first?.code, "S643")
        XCTAssertEqual(result.last?.name, "MacDonald")
        XCTAssertEqual(result.last?.code, "M135")
    }

    func testParse_withoutHeaders_includesFirstRow() {
        let csvContent = """
        Smith, S642
        Jones, J643
        """

        let result = CSVHelper.parse(csvString: csvContent, hasHeaders: false)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.name, "Smith")
        XCTAssertEqual(result.first?.code, "S642")
    }

    func testParse_handlesQuotedFieldsWithCommas() {
        let csvContent = "\"Smith, John\",S643"

        let result = CSVHelper.parse(csvString: csvContent, hasHeaders: false)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Smith, John")
        XCTAssertEqual(result.first?.code, "S643")
    }

    func testParse_skipsInvalidOrEmptyRows() {
        let csvContent = """
        OnlyOneField
        ,,
        
        Valid,V100
        """

        let result = CSVHelper.parse(csvString: csvContent, hasHeaders: false)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Valid")
        XCTAssertEqual(result.first?.code, "V100")
    }

    // MARK: - File URL Parsing Tests

    func testGetCSVDataFromURL_readsFileCorrectly() throws {
        let csvString = "Header1,Header2\nTest,T100"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID().uuidString).csv")
        try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
        temporaryFileURLs.append(tempURL)

        let result = CSVHelper.getCSVData(from: tempURL, hasHeaders: true)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Test")
        XCTAssertEqual(result.first?.code, "T100")
    }

    func testGetCSVDataFromURL_invalidURL_returnsEmptyArray() {
        let nonexistentURL = URL(fileURLWithPath: "/invalid/path/file.csv")

        let result = CSVHelper.getCSVData(from: nonexistentURL, hasHeaders: false)

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Export Tests

    func testExportToCSV_emptyData_returnsNil() {
        let result = CSVHelper.exportToCSV(with: [])

        XCTAssertNil(result)
    }

    func testExportToCSV_withoutExtras_generatesValidCSVFile() throws {
        let mockData = [
            CutterData(name: "John Smith", code: "S643")
        ]

        guard let exportURL = CSVHelper.exportToCSV(with: mockData, addExtras: false) else {
            XCTFail("Export URL should not be nil")
            return
        }
        temporaryFileURLs.append(exportURL)

        let fileContent = try String(contentsOf: exportURL, encoding: .utf8)

        XCTAssertTrue(fileContent.contains("Author,Name,Code,Number\n"))
        XCTAssertTrue(fileContent.contains("\"John Smith\",\"S643\""))
        XCTAssertFalse(fileContent.contains("ISBN,Book Name,DDC"))
    }

    func testExportToCSV_withExtras_includesExtraHeadersAndFields() throws {
        var item = CutterData(name: "John Smith", code: "S643")
        item.isbn = "1234567890"
        item.bookName = "A Great Book"
        item.ddcSelected = "800"

        guard let exportURL = CSVHelper.exportToCSV(with: [item], addExtras: true) else {
            XCTFail("Export URL should not be nil")
            return
        }
        temporaryFileURLs.append(exportURL)

        let fileContent = try String(contentsOf: exportURL, encoding: .utf8)

        XCTAssertTrue(fileContent.contains("Author,Name,Code,Number,ISBN,Book Name,DDC\n"))
        XCTAssertTrue(fileContent.contains("\"1234567890\",\"A Great Book\",\"800\""))
    }
}
