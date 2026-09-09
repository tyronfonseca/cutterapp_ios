//
//  AppSettings.swift
//  Cutter App
//
//  Created by Tyron on 6/9/26.
//

import Foundation
import SwiftUI

/// Determines whether to use the author's surname or book title when formatting call numbers.
public enum TextBeforeAfterNum: Int {
    case authorSurname
    case title
}

public protocol AppSettingsProtocol: AnyObject {
    var dontSeparateName: Bool { get set }
    var ignoreArticles: Bool { get set }
    var textBeforeNum: TextBeforeAfterNum { get set }
    var charsBeforeNum: Int { get set }
    var textAfterNum: TextBeforeAfterNum { get set }
    var charsAfterNum: Int { get set }
    var includeExtrasInExport: Bool { get set }
    var useFormatMac: Bool { get set }
}

@Observable
final class AppSettings: AppSettingsProtocol {
    // MARK: - App Storage Keys
    private enum Keys {
        static let dontSeparateName = "dontSeparateName"
        static let includeExtrasInExport = "includeExtrasInExport"
        static let textBeforeNum = "textBeforeNum"
        static let charsBeforeNum = "charsBeforeNum"
        static let textAfterNum = "textAfterNum"
        static let charsAfterNum = "charsAfterNum"
        static let ignoreArticles = "ignoreArticles"
        static let useFormatMac = "useFormatMac"
    }
    
    // MARK: - Properties with Observation Notifications
    
    /// Use the whole word instead of separating the search into name and surname.
    @ObservationIgnored
    @AppStorage(Keys.dontSeparateName) private var _dontSeparateName: Bool = false
    var dontSeparateName: Bool {
        get {
            access(keyPath: \.dontSeparateName)
            return _dontSeparateName
        }
        set {
            withMutation(keyPath: \.dontSeparateName) {
                _dontSeparateName = newValue
            }
        }
    }
    
    /// Ignore articles (grammar) in English, Spanish, and Portuguese. Set to true by default.
    @ObservationIgnored
    @AppStorage(Keys.ignoreArticles) private var _ignoreArticles: Bool = true
    var ignoreArticles: Bool {
        get {
            access(keyPath: \.ignoreArticles)
            return _ignoreArticles
        }
        set {
            withMutation(keyPath: \.ignoreArticles) {
                _ignoreArticles = newValue
            }
        }
    }
    
    /// What to use before the cutter number. Defaults to authorSurname.
    @ObservationIgnored
    @AppStorage(Keys.textBeforeNum) private var _textBeforeNum: TextBeforeAfterNum = .authorSurname
    var textBeforeNum: TextBeforeAfterNum {
        get {
            access(keyPath: \.textBeforeNum)
            return _textBeforeNum
        }
        set {
            withMutation(keyPath: \.textBeforeNum) {
                _textBeforeNum = newValue
            }
        }
    }
    
    /// How many characters to use before the cutter number. Accepts non-negative values (minimum 0).
    @ObservationIgnored
    @AppStorage(Keys.charsBeforeNum) private var _charsBeforeNum: Int = 1
    var charsBeforeNum: Int {
        get {
            access(keyPath: \.charsBeforeNum)
            return max(0, _charsBeforeNum)
        }
        set {
            withMutation(keyPath: \.charsBeforeNum) {
                _charsBeforeNum = max(0, newValue)
            }
        }
    }
    
    /// What to use after the cutter number. Defaults to authorSurname.
    @ObservationIgnored
    @AppStorage(Keys.textAfterNum) private var _textAfterNum: TextBeforeAfterNum = .title
    var textAfterNum: TextBeforeAfterNum {
        get {
            access(keyPath: \.textAfterNum)
            return _textAfterNum
        }
        set {
            withMutation(keyPath: \.textAfterNum) {
                _textAfterNum = newValue
            }
        }
    }
    
    /// How many characters to use after the cutter number. Accepts non-negative values (minimum 0).
    @ObservationIgnored
    @AppStorage(Keys.charsAfterNum) private var _charsAfterNum: Int = 0
    var charsAfterNum: Int {
        get {
            access(keyPath: \.charsAfterNum)
            return max(0, _charsAfterNum)
        }
        set {
            withMutation(keyPath: \.charsAfterNum) {
                _charsAfterNum = max(0, newValue)
            }
        }
    }
    
    /// Include DDC numbers and Book title in the exported CSV.
    @ObservationIgnored
    @AppStorage(Keys.includeExtrasInExport) private var _includeExtrasInExport: Bool = false
    var includeExtrasInExport: Bool {
        get {
            access(keyPath: \.includeExtrasInExport)
            return _includeExtrasInExport
        }
        set {
            withMutation(keyPath: \.includeExtrasInExport) {
                _includeExtrasInExport = newValue
            }
        }
    }
    
    /// Names using Mc, M' and Mac will be compare as they were Mac
    @ObservationIgnored
    @AppStorage(Keys.useFormatMac) private var _useFormatMac: Bool = true
    var useFormatMac: Bool {
        get {
            access(keyPath: \.useFormatMac)
            return _useFormatMac
        }
        set {
            withMutation(keyPath: \.useFormatMac) {
                _useFormatMac = newValue
            }
        }
    }
}
