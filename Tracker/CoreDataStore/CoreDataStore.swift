//
//  CoreDataStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation

import CoreData

class CoreDataStore {
    @NSManaged var typeTrecker: Int16
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "TrackersModel")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func convertTrackerTypeToInt16(_ typeTrecker: TrackerType) -> Int16 {
            return Int16(typeTrecker.rawValue)
        }
    
    func convertInt16ToTrackerType(_ intValue: Int16) -> TrackerType? {
            return TrackerType(rawValue: intValue)
        }
    
    func deleteAllData() {
        let context = persistentContainer.viewContext
        let fetchRequestTrackerCategory: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackersCategoryCoreData")
        
        do {
            let objects = try context.fetch(fetchRequestTrackerCategory)
            for object in objects {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
            
            try context.save()
            print("Все данные удалены из базы данных TrackerCategory.")
        } catch {
            print("Ошибка при удалении данных: \(error.localizedDescription)")
        }
        
        let fetchRequestTRecords: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackersRecordCoreData")
        
        do {
            let objects = try context.fetch(fetchRequestTRecords)
            for object in objects {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
            
            try context.save()
            print("Все данные удалены из базы данных TrackerRecord.")
        } catch {
            print("Ошибка при удалении данных: \(error.localizedDescription)")
        }
        
        let fetchRequestTrackers: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackersCoreData")
        
        do {
            let objects = try context.fetch(fetchRequestTrackers)
            for object in objects {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
            
            try context.save()
            print("Все данные удалены из базы данных Trackers.")
        } catch {
            print("Ошибка при удалении данных: \(error.localizedDescription)")
        }
        
    }
    
}
