//
//  View+Ext.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/11/24.
//

import SwiftUI

extension View {
    public func toCard(backgroundColor: Color = Color(uiColor: .darkGray)) -> some View {
        return modifier(CardModifier(backgroundColor: backgroundColor))
    }
}
