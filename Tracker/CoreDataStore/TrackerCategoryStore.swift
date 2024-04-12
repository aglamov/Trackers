//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChange(_ trackerCategoryStore: TrackerCategoryStore)
    func trackerCategoryStore(_ trackerCategoryStore: TrackerCategoryStore, didFetchCategories categories: [TrackersCategoryCoreData])
   // func trackerCategoryStore(_ trackerCategoryStore: TrackerCategoryStore, didFailWithError error: Error)
}

class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackersCategoryCoreData>!
    weak var delegate: TrackerCategoryStoreDelegate?
    
    override init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        super.init()

        do {
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
        } catch {
            print("Error initializing fetched results controller: \(error.localizedDescription)")
        }
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
            newCategory.addToTrackers(trackerInContext)
        }
        
        do {
            try context.save()
            // Уведомляем делегата о необходимости сохранения изменений
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

    func fetchCategories() {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            // Вызываем метод делегата для передачи результата
            delegate?.trackerCategoryStore(self, didFetchCategories: categories)
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            // Можно также вызвать метод делегата для передачи ошибки, если требуется
           // delegate?.trackerCategoryStore(self, didFetchCategories: error)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Начало обновления контента
        // Вы можете выполнить действия, которые нужно выполнить перед началом обновления, например, начать обновление интерфейса
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Завершение обновления контента
        // Вы можете выполнить действия, которые нужно выполнить после завершения обновления, например, обновить интерфейс
    }
}
