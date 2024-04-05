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
        let context = persistentContainer.viewContext
        if let existingCategory = fetchCategory(with: name, context: context) {
            // Категория уже существует, добавляем трекер к существующей категории
            if let tracker = fetchTracker(with: trackerID, context: context) {
                existingCategory.addToTrackers(tracker)
                do {
                    try context.save()
                    print("Трекер успешно добавлен к существующей категории и сохранен в базе данных.")
                } catch {
                    print("Ошибка при сохранении изменений: \(error.localizedDescription)")
                }
            }
        } else {
            // Категория не существует, создаем новую категорию
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = name
            
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
    
    private func fetchCategory(with name: String, context: NSManagedObjectContext) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Ошибка при поиске категории: \(error.localizedDescription)")
            return nil
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
