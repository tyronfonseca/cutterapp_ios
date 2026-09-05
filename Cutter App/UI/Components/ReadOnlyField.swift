//
//  ReadOnlyField.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import SwiftUI

struct ReadOnlyField: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .bold()
        }
        .foregroundStyle(.secondary)
    }
}


#Preview {
    ReadOnlyField(text: "Texting")
}
