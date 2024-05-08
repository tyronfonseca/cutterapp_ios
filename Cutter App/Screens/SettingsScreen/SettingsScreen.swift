//
//  SettingsView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/5/24.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var mainScreenData: MainScreenModel
    let versions = CsvVersion.allCases
    
    var body: some View {
        NavigationView{
            VStack{
                Form {
                    Section{
                        Picker("change_version", selection: $mainScreenData.data.versionSelected){
                            ForEach(versions, id:\.self){
                                Text($0.description)
                            }
                        }
                        .frame(height: 40)
                        
                        Button{
                            mainScreenData.settingOpen = false
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
        .environmentObject(MainScreenModel())
}
