//
//  CardView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/11/24.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var backgroundColor: Color = Color(uiColor: .darkGray)
    func body(content: Content) -> some View {
        content.padding()
            .background(backgroundColor.cornerRadius(10))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.1), radius: 10)
    }
}
