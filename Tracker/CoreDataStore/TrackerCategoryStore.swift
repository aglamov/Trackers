//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange(_ trackerCategoryStore: TrackerCategoryStore)
    func trackerCategoryStore(_ trackerCategoryStore: TrackerCategoryStore, didFetchCategories categories: [TrackersCategoryCoreData])
}

class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackersCategoryCoreData>!
    weak var delegate: TrackerCategoryStoreDelegate?
    private let pinnedCategoryName = "Закрепленные"
    private var currentFilter: FilterOption = .allTrackers
    
    private override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.init()
        
        do {
            let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \TrackersCategoryCoreData.name, ascending: true)
            ]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController.delegate = self
            try fetchedResultsController.performFetch()
        } catch {
            print("Error initializing fetched results controller: \(error.localizedDescription)")
        }
        
        createDefaultCategoryIfNeeded()
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackersCategoryCoreData.name, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
        
        createDefaultCategoryIfNeeded()
    }
    
    private func createDefaultCategoryIfNeeded() {
        if fetchCategory(with: pinnedCategoryName) == nil {
            let defaultCategory = TrackersCategoryCoreData(context: context)
            defaultCategory.name = pinnedCategoryName
            defaultCategory.id = UUID()
            defaultCategory.dataCreation = Date()
            
            do {
                try context.save()
            } catch {
                print("Error saving default category: \(error.localizedDescription)")
            }
        }
    }
    
    func createCategory(name: String, tracker: TrackersCoreData) {
        guard let trackerInContext = context.object(with: tracker.objectID) as? TrackersCoreData else {
            fatalError("Tracker is not in the same context as newRecord")
        }
        
        if let existingCategory = fetchCategory(with: name) {
            existingCategory.addToTrackers(trackerInContext)
        } else {
            let newCategory = TrackersCategoryCoreData(context: context)
            newCategory.name = name
            newCategory.id = UUID()
            newCategory.dataCreation = Date()
            newCategory.addToTrackers(trackerInContext)
        }
        
        do {
            try context.save()
            delegate?.trackerCategoryStoreDidChange(self)
            print("Changes successfully saved to the database.")
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
    
    func createCategoryNameOnly(name: String) {
        let newCategory = TrackersCategoryCoreData(context: context)
        newCategory.name = name
        newCategory.id = UUID()
        newCategory.dataCreation = Date()
        
        do {
            try context.save()
            delegate?.trackerCategoryStoreDidChange(self)
            print("Changes successfully saved to the database.")
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
    
    func fetchCategory(with name: String) -> TrackersCategoryCoreData? {
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
    
    func fetchCategoryID(with ID: UUID) -> TrackersCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", ID as CVarArg)
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Ошибка при поиске категории: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchCategories() {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            delegate?.trackerCategoryStore(self, didFetchCategories: categories)
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    func weekdayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date)
    }
    
    func fetchCategoriesWithTrackersOnWeekday(_ data: Date) -> [TrackersCategoryCoreData] {
        var categoriesWithTrackersOnWeekday = [TrackersCategoryCoreData]()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: data)
        let weekday = weekdayNumber(for: data)
        
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            
            for category in categories {
                guard let trackers = category.trackers as? Set<TrackersCoreData> else { continue }
                
                let filteredTrackers = filterTrackers(trackers, for: weekday, on: startOfDay, withFilter: currentFilter, using: calendar)
                
                if !filteredTrackers.isEmpty {
                    categoriesWithTrackersOnWeekday.append(category)
                }
            }
        } catch {
            print("Ошибка при получении категорий: \(error.localizedDescription)")
        }
        
        return categoriesWithTrackersOnWeekday.sorted { $0.dataCreation ?? Date() < $1.dataCreation ?? Date() }
    }
    
    func getCategories(completion: @escaping ([String]) -> Void) {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            let sortedCategoryNames = categories
                .sorted { $0.dataCreation ?? Date() < $1.dataCreation ?? Date() }
                .map { $0.name ?? "" }
            completion(sortedCategoryNames)
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            completion([])
        }
    }
    
    func deleteCategory(name: String) {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            if let category = try context.fetch(fetchRequest).first {
                context.delete(category)
                try context.save()
                delegate?.trackerCategoryStoreDidChange(self)
                print("Категория \(name) успешно удалена.")
            } else {
                print("Категория с именем \(name) не найдена.")
            }
        } catch {
            print("Ошибка при удалении категории: \(error.localizedDescription)")
        }
    }
    
    func saveChanges() throws {
        do {
            try context.save()
            print("Changes successfully saved to the database.")
        } catch {
            throw error
        }
    }
    
    func updateFilter(to newFilter: FilterOption) {
        self.currentFilter = newFilter
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
