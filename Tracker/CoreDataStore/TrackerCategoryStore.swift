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
            delegate?.trackerCategoryStoreDidChange(self)
            print("Changes successfully saved to the database.")
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
    
    func createCategoryNameOnly(name: String) {
        let newCategory = TrackersCategoryCoreData(context: context)
        newCategory.name = name
        
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

    func fetchCategories() {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            delegate?.trackerCategoryStore(self, didFetchCategories: categories)
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    func fetchCategoriesWithTrackersOnWeekday(_ weekday: Int) -> [TrackersCategoryCoreData] {
            var categoriesWithTrackersOnWeekday = [TrackersCategoryCoreData]()

            let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()

            do {
                let categories = try context.fetch(fetchRequest)
                for category in categories {
                    guard let trackers = category.trackers else { continue }
                    for tracker in trackers {
                        guard let tracker = tracker as? TrackersCoreData else { continue }

                        if let scheduleData = tracker.schedule as? Data {
                            do {
                                if let schedule = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scheduleData) as? [Int] {
     
                                    if schedule.contains(weekday) || tracker.typeTracker == 1 {
                                        categoriesWithTrackersOnWeekday.append(category)
                                        break
                                    }
                                }
                            } catch {
                                print("Error deserializing schedule data: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            } catch {
                print("Error fetching categories: \(error.localizedDescription)")
            }

            return categoriesWithTrackersOnWeekday
        }

    func getCategories(completion: @escaping ([String]) -> Void) {
        let fetchRequest: NSFetchRequest<TrackersCategoryCoreData> = TrackersCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            let categoryNames = categories.map { $0.name ?? "" }
            completion(categoryNames)
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            completion([])
        }
    }

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}
