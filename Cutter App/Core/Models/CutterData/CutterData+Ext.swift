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
        let cleanPrefix = prefixSource.strippingLeadingArticles(settings.ignoreArticles)
        let prefix = String(cleanPrefix.prefix(settings.charsBeforeNum)).trimmingCharacters(in: .whitespaces)
        
        // Resolve suffix text (Author Surname vs Title)
        let suffixSource = settings.textAfterNum == .authorSurname ? authorSurname : bookName
        let cleanSuffix = suffixSource.strippingLeadingArticles(settings.ignoreArticles)
        let suffix = String(cleanSuffix.prefix(settings.charsAfterNum)).trimmingCharacters(in: .whitespaces)
        
        // Assemble: [Prefix][Cutter Number][Suffix] (e.g. "Bs825T")
        return "\(prefix)\(self.code)\(suffix)"
    }
}
