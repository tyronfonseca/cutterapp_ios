//
//  CustomTextField.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: LocalizedStringKey
    var body: some View {
        TextField("", text: $text
                  , prompt: Text(placeholder).foregroundStyle(.cTextSecondary))
            .underLineTextField()    }
}

#Preview {
    CustomTextField(text: .constant(""), placeholder: "placeholder_name")
        .padding(.horizontal, 30)
        .background(.accent)
}
