//
//  BannerView.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI

struct BannerView : View {
    var body: some View {
        HStack () {
            Image(systemName: "text.page.badge.magnifyingglass")
                .font(.footnote)
            Text("Step 1 of 3: Capture")
                .font(.footnote)
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top, 8)
        
    }
}


#Preview {
    BannerView()
}
