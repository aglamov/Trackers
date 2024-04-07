//
//  TrackerStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData
import UIKit

class TrackerStore: CoreDataStore {
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Int], isPinned: Bool, typeTrecker: Int16) {
        
        let context = persistentContainer.viewContext
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = id
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.isPinned = false
        newTracker.typeTrecker = typeTrecker
        do {
            let scheduleData = try NSKeyedArchiver.archivedData(withRootObject: schedule, requiringSecureCoding: false)
            newTracker.schedule = scheduleData as NSObject
        } catch {
            print("Ошибка при сериализации данных: \(error.localizedDescription)")
        }
      
        do {
            try context.save()
            print("Новый трекер успешно создан и сохранен в базе данных.")
        } catch {
            print("Ошибка при сохранении нового трекера: \(error.localizedDescription)")
        }
    }
    
    func fetchTracker(with id: UUID) -> TrackerCoreData? {
            let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let trackers = try persistentContainer.viewContext.fetch(fetchRequest)
                return trackers.first
            } catch {
                print("Error fetching tracker with id \(id): \(error.localizedDescription)")
                return nil
            }
        }
    
    func fetchTracker(with id: UUID, context: NSManagedObjectContext) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.first
        } catch {
            print("Error fetching tracker: \(error.localizedDescription)")
            return nil
        }
    }
}
