//
//  SettingsView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/5/24.
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationStack{
            VStack{
                Form {
                    Section{
                        Button{
                            print("Version")
                        }label: {
                            Text("save_close")
                        }
                    }
                    footer: {
                        Text("old_explained")
                    }
                }
                
            }
            .navigationTitle("settings")
        }
    }
}

#Preview {
    SettingsScreen()
}
