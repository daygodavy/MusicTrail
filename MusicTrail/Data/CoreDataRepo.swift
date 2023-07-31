//
//  CoreDataRepo.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/31/23.
//

import CoreData
import Foundation

class CoreDataRepo {
    private let context = PersistanceContainer.shared.container.viewContext
    
    func fetch<M: NSManagedObject>(_ type: M.Type, predicate: NSPredicate?=nil, sort: NSSortDescriptor?=nil) -> [M]? {
        
        var fetched: [M]?
        let entity = String(describing: type)
        let request = NSFetchRequest<M>(entityName: entity)
        
        request.predicate = predicate
        request.sortDescriptors = [sort] as? [NSSortDescriptor]
        
        do {
            fetched = try context.fetch(request)
        } catch {
            print("Error during fetch: \(error)")
        }
        
        return fetched
    }
    
//    func add<M: NSManagedObject>(_ type: M.Type) -> M? {
//        return nil
//    }
}

