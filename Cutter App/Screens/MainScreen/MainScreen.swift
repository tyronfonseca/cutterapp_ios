//
//  ContentView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

struct MainScreen: View {
    @EnvironmentObject var mainScreenData: MainScreenModel
    @FocusState private var focusedTextField: FormTextField?
        
    enum FormTextField {
        case firstName, lastName
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(.cPrimary)
                VStack {
                    Image(.longLogoWhite)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250)
                        .padding(.bottom, 120)
                        .accessibilityLabel(String("logo_description"))
                        .accessibilityAddTraits(.isImage)
                    
                    Text(mainScreenData.data.result)
                        .bold()
                        .font(.largeTitle)
                        .foregroundStyle(.cText)
                        .animation(.smooth)
                    
                    Text(mainScreenData.data.dataUsed)
                        .foregroundStyle(.cTextSecondary)
                        .font(.title3)
                        .animation(.smooth)
                    
                    
                    VStack{
                        CustomTextField(text: $mainScreenData.lastName, placeholder: "placeholder_last_name")
                        
                            .focused($focusedTextField, equals: .lastName)
                            .onSubmit {
                                focusedTextField = .firstName
                            }
                            .submitLabel(.next)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 30)
                        
                        CustomTextField(text: $mainScreenData.firstName, placeholder: "placeholder_name")
                            .focused($focusedTextField, equals: .firstName)
                            .onSubmit {
                                focusedTextField = nil
                            }
                            .submitLabel(.continue)
                            .onSubmit {
                                mainScreenData.searchValue()
                            }
                            .autocorrectionDisabled()
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 60)
                    
                    Button {
                        mainScreenData.searchValue()
                    } label: {
                        Text("search_btn")
                            .textCase(.uppercase)
                            .foregroundStyle(.cText)
                            .bold()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                    .controlSize(.large)
                    
                    NavigationLink(destination: About(), label:
                                    {
                        Text("about_btn")
                            .foregroundStyle(.white)
                            .bold()
                    })
                    .padding(.top, 60)
                }
                .overlay(Button {
                    mainScreenData.settingOpen = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .foregroundStyle(.cText)
                        .frame(width: 30, height: 30)
                        .accessibilityLabel(String(localized: "change_version"))
                        .accessibilityAddTraits(.isButton)
                    
                }, alignment: .bottomLeading)
                .overlay(
                    NavigationLink(destination: SearchHistory(), label: {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        .resizable()
                        .foregroundStyle(.cText)
                        .frame(width: 35, height: 30)
                        .accessibilityLabel(String(localized: "search_history_accessibility"))
                        .accessibilityAddTraits(.isButton)
                    
                }), alignment: .bottomTrailing)
                .padding()
            }
            .sheet(isPresented: $mainScreenData.settingOpen
                   , onDismiss: { mainScreenData.saveChanges(true) }){
                SettingsScreen()
                    .environmentObject(mainScreenData)
            }
            .onAppear(){
                mainScreenData.retriveData()
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MainScreen()
        .environmentObject(MainScreenModel())
}
