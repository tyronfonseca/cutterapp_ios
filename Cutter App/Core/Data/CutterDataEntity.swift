//
//  CutterDataEntity.swift
//  Cutter App
//
//  Created by Tyron on 8/9/26.
//

import Foundation
import CoreData

@objc(CutterDataEntity)
public class CutterDataEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var code: String
    @NSManaged public var authorName: String
    @NSManaged public var authorSurname: String
    @NSManaged public var isbn: String?
    @NSManaged public var bookName: String?
    @NSManaged public var ddcsJoined: String?   // Stores array as "100,200,300"
    @NSManaged public var ddcSelected: String?
    @NSManaged public var needsReview: Bool
    @NSManaged public var dontSeparateName: Bool
    
    // MARK: - Convenient Array Binding
    
    public var ddcs: [String] {
        get {
            guard let ddcsJoined, !ddcsJoined.isEmpty else { return [] }
            return ddcsJoined.components(separatedBy: ",")
        }
        set {
            ddcsJoined = newValue.joined(separator: ",")
        }
    }
}

extension CutterDataEntity {
    /// Convenience initializer from struct
    @discardableResult
    convenience init(from structData: CutterData, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = structData.id
        self.name = structData.name
        self.code = structData.code
        self.authorName = structData.authorName
        self.authorSurname = structData.authorSurname
        self.isbn = structData.isbn
        self.bookName = structData.bookName
        self.ddcs = structData.ddcs
        self.ddcSelected = structData.ddcSelected
        self.needsReview = structData.needsReview
        self.dontSeparateName = structData.dontSeparateName
    }
    
    /// Export to in-memory struct
    func toStruct() -> CutterData {
        CutterData(
            id: id,
            name: name,
            code: name,
            authorName: authorName,
            authorSurname: authorSurname,
            isbn: isbn ?? "",
            bookName: bookName ?? "",
            ddc: ddcs,
            ddcSelected: ddcSelected ?? "",
            needsReview: needsReview,
            dontSeparateName: dontSeparateName
        )
    }
}
