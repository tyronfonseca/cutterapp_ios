//
//  MainScreen.swift
//  Cutter App
//
//  Created by Tyron on 2/9/26.
//

import SwiftUI

struct MainScreen: View {
    @EnvironmentObject var mainScreenData: MainViewModel
    @FocusState private var focusedTextField: FormTextField?
    
    enum FormTextField {
        case firstName, lastName
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                    
                    VStack {
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
                                mainScreenData.searchValue()
                            }
                            .submitLabel(.continue)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 60)
                    
                    Button("search_btn", action: { mainScreenData.searchValue() })
                        .buttonStyle(.glassProminent)
                        .controlSize(.extraLarge)
                }
                .padding()
            }
            .sheet(isPresented: $mainScreenData.settingOpen, onDismiss: { mainScreenData.saveChanges(true) }) {
                SettingsScreen()
                    .environmentObject(mainScreenData)
            }
            .onAppear {
                mainScreenData.retriveData()
            }
        }
    }
}

#Preview {
    MainScreen()
}
