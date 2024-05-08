//
//  CutterHelperTests.swift
//  Cutter AppTests
//
//  Created by Tyron Fonseca on 6/5/24.
//

import XCTest
@testable import Cutter_App

final class CutterHelperTests: XCTestCase {
    
    
    func test_convertStrToIntArr_sucessful(){
        // arrange
        let expected = [23,6,22,23,10,16,8]
        
        // act
        let result = CutterHelper.convertStrToIntArr(str: "TESTING")
        
        // assert
        XCTAssertEqual(result, expected)
    }
    
    func test_convertStrToIntArr_withAccent(){
        // arrange
        let expected = [23,6,22,23,10,16,8]
        
        // act
        let result = CutterHelper.convertStrToIntArr(str: "TÉSTÍNG")
        
        // assert
        XCTAssertEqual(result, expected)
    }
    
    func test_compareIntArrTo_successful(){
        // arrange
        let compare = CutterHelper.convertStrToIntArr(str: "TESTING")
        let before = CutterHelper.convertStrToIntArr(str: "TESS")
        let after = CutterHelper.convertStrToIntArr(str: "TESZ")
        
        // act
        let resultBefore = CutterHelper.compareIntArrTo(leftArr: compare, rightArr: before)
        let resultAfter = CutterHelper.compareIntArrTo(leftArr: compare, rightArr: after)
        let resultEqual = CutterHelper.compareIntArrTo(leftArr: compare, rightArr: compare)
        
        // assert
        XCTAssertTrue(resultBefore >= 0)
        XCTAssertTrue(resultAfter < 0)
        XCTAssertTrue(resultEqual >= 0)
    }
    
    func test_getFirstLetter_normal(){
        // arrange
        let expected = "F"
        
        // act
        let result = CutterHelper.getFirstLetter(word: "Friend", currVersion: .normal)
        
        // assert
        XCTAssertEqual(expected, result)
    }
    
    func test_getFirstLetter_normal_LL(){
        // arrange
        let expected = "L"
        
        // act
        let result = CutterHelper.getFirstLetter(word: "Llorente", currVersion: .normal)
        
        // assert
        XCTAssertEqual(expected, result)
    }
    
    func test_getFirstLetter_LL(){
        // arrange
        let expected = "Ll"
        
        // act
        let result = CutterHelper.getFirstLetter(word: "Llorente", currVersion: .ucr)
        
        // assert
        XCTAssertEqual(expected, result)
    }
    
    func test_getFirstLetter_CH(){
        // arrange
        let expected = "Ch"
        
        // act
        let result = CutterHelper.getFirstLetter(word: "Chavez", currVersion: .ucr)
        
        // assert
        XCTAssertEqual(expected, result)
    }
    
    func test_ucrFix_normal(){
        // arrange
        let expected = [16,1,25,6,22] //N A V E S
        
        // act
        let arr = CutterHelper.convertStrToIntArr(str: "NAVES")
        let result = CutterHelper.ucrFix(list: arr)
        
        // assert
        XCTAssertEqual(expected, result)
    }
    
    func test_ucrFix_normal_LL(){
        // arrange
        let expected = [14,1,25,6,22] //LL A V E S
        
        // act
        let arr = CutterHelper.convertStrToIntArr(str: "LLAVES")
        let result = CutterHelper.ucrFix(list: arr)
        
        // assert
        XCTAssertEqual(expected, result)
    }
    
    func test_ucrFix_normal_CH(){
        // arrange
        let expected = [4,1,25,6,22] //CH A V E S
        
        // act
        let arr = CutterHelper.convertStrToIntArr(str: "CHAVES")
        let result = CutterHelper.ucrFix(list: arr)
        
        // assert
        XCTAssertEqual(expected, result)
    }
    
    func test_ucrFix_checkLast(){
        // arrange
        let expected = [2,1,4] //B A CH
        
        // act
        let arr = CutterHelper.convertStrToIntArr(str: "BACH")
        let result = CutterHelper.ucrFix(list: arr)
        
        // assert
        XCTAssertEqual(expected, result)
    }
}
