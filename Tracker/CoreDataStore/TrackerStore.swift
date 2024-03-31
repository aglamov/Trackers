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
        //  newTracker.color = color
        //  newTracker.emoji = emoji
        //  newTracker.emoji =
        
        do {
            try context.save()
            print("Новый трекер успешно создан и сохранен в базе данных.")
        } catch {
            print("Ошибка при сохранении нового трекера: \(error.localizedDescription)")
        }
    }
    
    func fetchTrackers() -> [TrackerCoreData] {
        // Ваш код для извлечения трекеров из Core Data
        return []
    }
    
    // Другие методы для работы с трекерами
}
