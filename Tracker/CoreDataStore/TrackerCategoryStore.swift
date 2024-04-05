//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData

class TrackerCategoryStore: CoreDataStore {
    func createCategory(name: String, trackerID: UUID) {
        if !categoryExists(with: name) {
            let context = persistentContainer.viewContext
            
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = name
            
            // Получаем объект трекера из того же контекста, что и категория
            if let tracker = fetchTracker(with: trackerID, context: context) {
                newCategory.addToTrackers(tracker)
                do {
                    try context.save()
                    print("Новая категория успешно создана и сохранена в базе данных.")
                } catch {
                    print("Ошибка при сохранении новой категории: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchTracker(with id: UUID, context: NSManagedObjectContext) -> TrackerCoreData? {
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
    
    private func categoryExists(with name: String) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if category exists: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest() 
        do {
            let categories = try persistentContainer.viewContext.fetch(fetchRequest)
            return categories
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            return []
        }
    }
}
