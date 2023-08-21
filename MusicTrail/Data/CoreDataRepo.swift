//
//  CoreDataRepo.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/31/23.
//

import CoreData
import Foundation

class CoreDataRepo {
    private let container = PersistanceContainer.shared
    
    func fetch<M: NSManagedObject>(_ type: M.Type, predicate: NSPredicate?=nil, sort: NSSortDescriptor?=nil) -> [M] {
        
        var fetched: [M]
        let entity = String(describing: type)
        let request = NSFetchRequest<M>(entityName: entity)
        
        request.predicate = predicate
        request.sortDescriptors = [sort] as? [NSSortDescriptor]
        
        do {
            fetched = try container.viewContext.fetch(request)
            return fetched
        } catch {
            print("Error during fetch: \(error)")
        }
        
        return []
    }
    
    func save() {
        container.saveContext()
    }
    
    func getContext() -> NSManagedObjectContext {
        return container.viewContext
    }
    
    func delete(_ entity: NSManagedObject) {
        container.viewContext.delete(entity)
        save()
    }
}

