//
//  AbouView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 26/7/24.
//

import SwiftUI

struct About: View {
    var body: some View {
        NavigationStack{
            VStack (spacing: 30){
                VStack (spacing: 30) {
                    AdknowledgeView(contribution: String(localized:"author_header")
                                    , name: String(localized: "author")
                                    , url: String(localized: "author_url"))
                    
                    AdknowledgeView(contribution: String(localized:"ui_header")
                                    , name: String(localized:"ui_name")
                                    , url: String(localized:"ui_url"))
                }
                .frame(maxWidth: .infinity)
                .toCard()
                
                VStack (alignment: .leading, spacing: 30) {
                    Text("faq_header")
                        .bold()
                    FAQView(question: String(localized: "question_1"), answer: String(localized:"question_1_a"))
                    FAQView(question: String(localized: "question_2")
                            , answer: "\(String(localized:"question_2_a")): \(String(localized:"contact_email")) ")
                }
                .frame(maxWidth: .infinity)
                .toCard()
            }
            .padding()
        }
        .navigationTitle("about_btn")
    }
}

#Preview {
    About()
}
