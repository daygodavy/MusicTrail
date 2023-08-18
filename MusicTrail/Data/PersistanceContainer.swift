//
//  PersistanceContainer.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/31/23.
//

import CoreData
import Foundation

class PersistanceContainer {
    private let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    static let shared = PersistanceContainer()
    
    init() {
        self.container = NSPersistentContainer(name: "MusicTrail")
        self.backgroundContext = container.newBackgroundContext()
        self.viewContext = container.viewContext
        
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("PersistanceContainer.init() error: \(error.localizedDescription)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("PersistanceContainer.saveContext() error: \(error.localizedDescription)")
            }
        }
    }
}
