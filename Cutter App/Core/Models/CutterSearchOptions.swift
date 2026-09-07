//
//  CutterSearchOptions.swift
//  Cutter App
//
//  Created by Tyron on 7/9/26.
//

struct CutterSearchOptions {
    let dontSeparateName: Bool
    let ignoreArticles: Bool
    let useFormatMac: Bool

    init(settings: AppSettingsProtocol, dontSeparateName: Bool? = nil, ignoreArticles: Bool? = nil) {
        self.dontSeparateName = dontSeparateName ?? settings.dontSeparateName
        self.ignoreArticles = ignoreArticles ?? settings.ignoreArticles
        self.useFormatMac = settings.useFormatMac
    }
}
