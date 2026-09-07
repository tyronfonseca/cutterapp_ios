//
//  CutterData+Ext.swift
//  Cutter App
//
//  Created by Tyron on 6/9/26.
//

extension CutterData {
    /// Generates a fully formatted Call/Cutter Number based on active AppSettings.
    func fullCallNumber(using settings: AppSettings) -> String {
        // Resolve prefix text (Author Surname vs Title)
        let prefixSource = settings.textBeforeNum == .authorSurname ? authorSurname : bookName
        let cleanPrefix = prefixSource.strippingLeadingArticles(shouldIgnore: settings.ignoreArticles)
        let prefix = String(cleanPrefix.prefix(settings.charsBeforeNum))
        
        // Resolve suffix text (Author Surname vs Title)
        let suffixSource = settings.textAfterNum == .authorSurname ? authorSurname : bookName
        let cleanSuffix = suffixSource.strippingLeadingArticles(shouldIgnore: settings.ignoreArticles)
        let suffix = String(cleanSuffix.prefix(settings.charsAfterNum))
        
        // Assemble: [Prefix][Cutter Number][Suffix] (e.g. "Bs825T")
        return "\(prefix)\(self.code)\(suffix)"
    }
}
