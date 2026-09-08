//
//  SessionRepository.swift
//  Cutter App
//
//  Created by Tyron on 8/9/26.
//

import Foundation
import CoreData

public protocol SessionRepositoryProtocol {
    func createSession(name: String, description: String?, cutters: [CutterDataEntity]) throws -> SessionEntity
    func fetchAllSessions() throws -> [SessionEntity]
    func fetchSession(by id: UUID) throws -> SessionEntity?
    func updateSession(_ session: SessionEntity, name: String?, description: String?, addCutters: [CutterDataEntity], removeCutters: [CutterDataEntity]) throws
    func deleteSession(_ session: SessionEntity) throws
}

public class SessionRepository: SessionRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Save Session (Create)
    @discardableResult
    public func createSession(
        name: String,
        description: String? = nil,
        cutters: [CutterDataEntity] = []
    ) throws -> SessionEntity {
        let session = SessionEntity(context: context)
        session.id = UUID()
        session.name = name
        session.sessionDescription = description
        session.created_at = Date()
        session.updated_at = Date()
        
        for cutter in cutters {
            session.addToCutters(cutter)
        }
        
        try context.save()
        return session
    }
    
    // MARK: - Load Sessions (Fetch)
    public func fetchAllSessions() throws -> [SessionEntity] {
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.updated_at, ascending: false)]
        return try context.fetch(request)
    }
    
    public func fetchSession(by id: UUID) throws -> SessionEntity? {
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    // MARK: - Edit Session (Update)
    public func updateSession(
        _ session: SessionEntity,
        name: String? = nil,
        description: String? = nil,
        addCutters: [CutterDataEntity] = [],
        removeCutters: [CutterDataEntity] = []
    ) throws {
        if let name = name {
            session.name = name
        }
        if let description = description {
            session.sessionDescription = description
        }
        
        for cutter in addCutters {
            session.addToCutters(cutter)
        }
        
        for cutter in removeCutters {
            session.removeFromCutters(cutter)
        }
        
        session.updated_at = Date()
        try context.save()
    }
    
    // MARK: - Delete Session
    public func deleteSession(_ session: SessionEntity) throws {
        context.delete(session)
        try context.save()
    }
}
