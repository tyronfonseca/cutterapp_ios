//
//  Previewing.swift
//  Cutter App
//
// Based on https://github.com/andynadal/swiftui-coredata-previews
//  Created by Tyron Fonseca on 21/1/25.
//

import CoreData
import SwiftUI

struct Previewing<Content: View, Model>: View {
    var content: Content
    var persistence: SearchesCD
    
    init(_ keyPath: KeyPath<PreviewingData, (NSManagedObjectContext) -> Model>, @ViewBuilder content: (Model) -> Content) {
        self.persistence = SearchesCD(inMemory: true)
        let data = PreviewingData()
        let closure = data[keyPath: keyPath]
        let models = closure(persistence.persistentContainer.viewContext)
        self.content = content(models)
    }
    
    var body: some View {
        content
            .environment(\.managedObjectContext, persistence.persistentContainer.viewContext)
    }
}

struct PreviewingData {
    var items : (NSManagedObjectContext) -> [SearchResult] {
        {
            context in
            var results : [SearchResult] = []
            for i in 0..<3 {
                let res = SearchResult(context: context)
                res.calling_number = "G666"
                res.last_name = "Isaacson_\(i)"
                res.name = "Seth"
                res.last_searched = Date()
                res.name_selected = "G. Jonsson"
                results.append(res)
            }
            return results
        }
    }
    
    var item: (NSManagedObjectContext) -> SearchResult {{ context in
        let res = SearchResult(context: context)
        res.calling_number = "G666"
        res.last_name = "Isaacson"
        res.name = "Seth"
        res.last_searched = Date()
        res.name_selected = "G. Jonsson"
        return res
    }
    }
}
