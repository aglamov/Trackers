//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData

class TrackerCategoryStore: CoreDataStore {
    func createCategory(name: String, tracker: TrackersCoreData) {
        let context = persistentContainer.viewContext
        
        guard let trackerInContext = context.object(with: tracker.objectID) as? TrackersCoreData else {
            fatalError("Tracker is not in the same context as newRecord")
        }
        
        if let existingCategory = fetchCategory(with: name, context: context) {
            existingCategory.addToTrackers(trackerInContext)
         //   print("В категорию \(String(describing: existingCategory.name)). Добавлен трекер \(String(describing: trackerInContext.name))")
        } else {
            let newCategory = TrackersCategoryCoreData(context: context)
            newCategory.name = name
            newCategory.addToTrackers(trackerInContext)
         //   print("Cоздана категория \(name). Добавлен трекер \(String(describing: trackerInContext.name)) с расписанием \(String(describing: trackerInContext.schedule))")
        }
        
        do {
            try context.save()
            print("Изменения успешно сохранены в базе данных.")
            let allCategories = fetchCategories().count
            print("В базе категорий трекеров \(allCategories) категорий")
        } catch {
            print("Ошибка при сохранении изменений: \(error.localizedDescription)")
        }
    }
    
    private func fetchTracker(with id: UUID, context: NSManagedObjectContext) -> TrackersCoreData? {
        let fetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.first
        } catch {
            print("Error fetching tracker: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchCategory(with name: String, context: NSManagedObjectContext) -> TrackersCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Ошибка при поиске категории: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchCategories() -> [TrackersCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        do {
            let categories = try persistentContainer.viewContext.fetch(fetchRequest)
            return categories
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchCategoriesWithTrackersOnWeekday(_ weekday: Int) -> [TrackersCategoryCoreData] {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
            
            do {
                let categories = try context.fetch(fetchRequest)
                let categoriesWithTrackersOnWeekday = categories.filter { category in
                    if let trackers = category.trackers {
                        return trackers.contains { tracker in
                            if let tracker = tracker as? TrackersCoreData,
                               let scheduleData = tracker.schedule as? Data {
                                do {
                                    let schedule = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scheduleData) as? [Int]
                                    return schedule?.contains(weekday) ?? false
                                } catch {
                                    print("Ошибка декодирования расписания: \(error)")
                                    return false
                                }
                            }
                            return false
                        }
                    }
                    return false
                }
                return categoriesWithTrackersOnWeekday
            } catch {
                print("Error fetching categories: \(error.localizedDescription)")
                return []
            }
        }
}
