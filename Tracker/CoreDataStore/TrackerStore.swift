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
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Int], isPinned: Bool) {
        
        let context = persistentContainer.viewContext
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = id
        newTracker.name = name
    //    newTracker.color = color
        newTracker.emoji = emoji
        newTracker.isPinned = false
     //   newTracker.schedule = schedule as NSObject
        
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
}
