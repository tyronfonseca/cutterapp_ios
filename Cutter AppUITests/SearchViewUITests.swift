//
//  SearchViewUITests.swift
//  Cutter AppUITests
//
//  Created by Tyron on 11/9/26.
//

import XCTest

final class SearchViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Pass a custom flag to the target app
        app.launchArguments.append("-resetData")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSearchCutter_Empty() throws {
        let more_actions = app.buttons["search_more_actions"]
        XCTAssertTrue(more_actions.exists)
        more_actions.tap()
        
        //MARK: - Toolbar
    
        // Logo
        XCTAssert(app.images["search_app_logo"].exists)
        
        //More Actions
        let search_select_items = app.buttons["search_select_items"]
        XCTAssertTrue(search_select_items.exists)
        XCTAssertFalse(search_select_items.isEnabled)
        let search_delete_all = app.buttons["search_delete_all"]
        XCTAssertTrue(search_delete_all.exists)
        XCTAssertFalse(search_delete_all.isEnabled)
        
        
        //MARK: - Search actions
        let search_main_textfield = app.textFields["search_main_textfield"]
        XCTAssert(search_main_textfield.exists)
        
        // Check if value is empty or nil
        let textValue = search_main_textfield.value as? String
        XCTAssertTrue(textValue?.isEmpty ?? true, "Text field should be empty")
        XCTAssertTrue(app.staticTexts["search_textfield_hint"].exists)
        
        // Buttons
        let search_scan_button = app.buttons["search_scan_button"]
        XCTAssertTrue(search_scan_button.exists)
        XCTAssertTrue(search_scan_button.isEnabled)
        
        let search_button = app.buttons["search_button"]
        XCTAssertTrue(search_button.exists)
        XCTAssertFalse(search_button.isEnabled)
        
        //MARK: - Cutter list (Empty by default)
        XCTAssertTrue(app.staticTexts["search_no_entries_view"].exists)
        
        // Filters
        let search_sort_by_picker = app.pickers["search_sort_by_picker"]
        XCTAssertFalse(search_sort_by_picker.exists)
        
        let search_filter_by_picker = app.pickers["search_filter_by_picker"]
        XCTAssertFalse(search_filter_by_picker.exists)
        
        //MARK: - Share
        let export_button = app.buttons["export_button"]
        XCTAssertTrue(export_button.exists)
        XCTAssertFalse(export_button.isEnabled)
        
        
        //MARK: - Tabs
        let tab_search = app.tabBars.buttons["tab.search"]
        XCTAssertTrue(tab_search.exists)
        XCTAssertTrue(tab_search.isSelected)
        
        let tab_cutter = app.tabBars.buttons["tab.cutterTable"]
        XCTAssertTrue(tab_cutter.exists)
        XCTAssertFalse(tab_cutter.isSelected)
        
        let tab_about = app.tabBars.buttons["tab.about"]
        XCTAssertTrue(tab_about.exists)
        XCTAssertFalse(tab_about.isSelected)
        
        let tab_settings = app.tabBars.buttons["tab.settings"]
        XCTAssertTrue(tab_settings.exists)
        XCTAssertFalse(tab_settings.isSelected)
    }
    
    
    func testSearchCutter_Basic() throws {
        // Search
        
        let search_main_textfield = app.textFields["search_main_textfield"]
        let search_button = app.buttons["search_button"]
        
        search_main_textfield.tap()
        search_main_textfield.firstMatch.typeText("John Smith")
        search_button.tap()

        search_main_textfield.tap()
        search_main_textfield.typeText("Smith, John\r")
        
        search_main_textfield.tap()
        search_main_textfield.typeText("Smith\r")
        
        // List Filters
        let search_sort_by_picker = app.pickers["search_sort_by_picker"]
        XCTAssertTrue(search_sort_by_picker.exists)
        search_sort_by_picker.tap()
        
        XCTAssertTrue(app.buttons["search_sort_by_newest"].exists)
        XCTAssertTrue(app.buttons["search_sort_by_newest"].isSelected)
        
        XCTAssertTrue(app.buttons["search_sort_by_oldest"].exists)
        XCTAssertFalse(app.buttons["search_sort_by_oldest"].isSelected)
        
        XCTAssertTrue(app.buttons["search_sort_by_author"].exists)
        XCTAssertFalse(app.buttons["search_sort_by_author"].isSelected)
        
        let search_filter_by_picker = app.pickers["search_filter_by_picker"]
        XCTAssertTrue(search_filter_by_picker.exists)
        search_filter_by_picker.tap()
        
        XCTAssertTrue(app.buttons["search_filter_by_all"].exists)
        XCTAssertTrue(app.buttons["search_filter_by_all"].isSelected)
        
        XCTAssertTrue(app.buttons["search_filter_by_needsReview"].exists)
        XCTAssertFalse(app.buttons["search_filter_by_needsReview"].isSelected)
        
        XCTAssertTrue(app.buttons["search_filter_by_needsReview"].exists)
        XCTAssertFalse(app.buttons["search_filter_by_needsReview"].isSelected)
        
        // Check if list exists
        let search_results_list = app.collectionViews["search_results_list"]
        XCTAssertTrue(search_results_list.exists)
        XCTAssertEqual(search_results_list.count, 3)
        
        
    }
}
