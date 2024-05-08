//
//  AppData.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

final class MainScreenModel: ObservableObject {
    @AppStorage("appData") private var appData: Data?
    
    @Published var data = MainScreenData()
    @Published var lastName: String = ""
    @Published var firstName: String = ""
    @Published var msgError: String = ""
    
    @Published var settingOpen: Bool = false
    
    private let cutterGetter = CutterGetter.shared
    
    var isValidForm: Bool {
        guard !lastName.isEmpty && lastName.count > 1 else {
            self.msgError = String(localized: "msg_error_last_name")
            return false
        }
        
        guard !firstName.isEmpty else {
            self.msgError = String(localized: "msg_error_empty_inputs")
            return false
        }
        
        return true
    }
    
    func searchValue(){
        guard isValidForm else{
            return
        }
        
        let result = cutterGetter.search(name: self.firstName, lastName: self.lastName)
        
        guard let name = result?.name else {
            return
        }
        
        guard let value = result?.value else {
            return
        }
        
        let letter = CutterHelper.getFirstLetter(word: name, currVersion: self.data.versionSelected)
        
        self.data.result   = letter + value
        self.data.dataUsed = name + ": " + value
        
        self.saveChanges()
    }
    
    
    func changeVersion(newVersion: CsvVersion){
        self.data.versionSelected = newVersion
        self.saveChanges()
    }

    
    func saveChanges(){
        do {
            let data = try JSONEncoder().encode(data)
            appData = data
        }catch
        {
            
        }
    }
    
    func retriveData() {
        guard let appData else {return}
        do{
            data = try JSONDecoder().decode(MainScreenData.self, from: appData)
        }catch
        {
            
        }
    }
    
}
