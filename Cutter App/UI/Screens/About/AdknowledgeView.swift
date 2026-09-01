//
//  CreditView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/11/24.
//

import SwiftUI

struct AdknowledgeView: View {
    var contribution: String
    var name : String
    var url : String
    var body: some View {
        VStack {
            Text("\(contribution):")
                .font(.callout)
                .bold()
            Text(name)
                .font(.subheadline)
            Link(destination: URL(string: url)!) {
                Text(url)
                .font(.caption)
                .underline()
                .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    AdknowledgeView(contribution: "Design and development", name: "Test test – 2024", url: "https://www.google.com")
}
