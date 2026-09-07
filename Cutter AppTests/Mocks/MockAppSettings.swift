//
//  MockAppSettings.swift
//  Cutter App
//
//  Created by Tyron on 7/9/26.
//

import Foundation
@testable import Cutter_App

/// An in-memory mock implementation of `AppSettingsProtocol` for unit testing.
final class MockAppSettings: AppSettingsProtocol {
    var dontSeparateName: Bool
    var ignoreArticles: Bool
    var textBeforeNum: TextBeforeAfterNum
    var charsBeforeNum: Int
    var textAfterNum: TextBeforeAfterNum
    var charsAfterNum: Int
    var includeExtrasInExport: Bool
    var useFormatMac: Bool

    init(
        dontSeparateName: Bool = false,
        ignoreArticles: Bool = true,
        textBeforeNum: TextBeforeAfterNum = .authorSurname,
        charsBeforeNum: Int = 1,
        textAfterNum: TextBeforeAfterNum = .title,
        charsAfterNum: Int = 0,
        includeExtrasInExport: Bool = false,
        useFormatMac: Bool = true
    ) {
        self.dontSeparateName = dontSeparateName
        self.ignoreArticles = ignoreArticles
        self.textBeforeNum = textBeforeNum
        self.charsBeforeNum = charsBeforeNum
        self.textAfterNum = textAfterNum
        self.charsAfterNum = charsAfterNum
        self.includeExtrasInExport = includeExtrasInExport
        self.useFormatMac = useFormatMac
    }
}
