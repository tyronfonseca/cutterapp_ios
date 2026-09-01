//
//  FAQView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/11/24.
//

import SwiftUI

struct FAQView: View {
    var question : String
    var answer : String
    
    var body: some View {
        // Make the text go left
        VStack (alignment: .leading, spacing: 10) {
            Text(question)
                .bold()
                .underline()
            Text(answer)
        }
    }
}

#Preview {
    FAQView(question: String(localized: "question_1"), answer: String(localized: "question_1_a"))
}
