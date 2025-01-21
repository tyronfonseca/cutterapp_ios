//
//  View+Ext.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/11/24.
//

import SwiftUI

extension View {
    public func toCard() -> some View {
        return modifier(CardModifier())
    }
}
