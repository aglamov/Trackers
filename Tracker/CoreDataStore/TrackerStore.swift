//
//  TrackerStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdateData()
}

class TrackerStore: NSObject, NSFetchedResultsControllerDelegate{
    static let shared = TrackerStore()
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackersCoreData>!
    weak var delegate: (TrackerStoreDelegate)?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackersCoreData.name, ascending: true)
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
    
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [Int], isPinned: Bool, typeTracker: Int16) {
        let newTracker = TrackersCoreData(context: context)
        newTracker.id = id
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.isPinned = false
        newTracker.typeTracker = typeTracker
        
        do {
            let scheduleData = try NSKeyedArchiver.archivedData(withRootObject: schedule, requiringSecureCoding: false)
            newTracker.schedule = scheduleData as NSObject
        } catch {
            print("Error serializing schedule data: \(error.localizedDescription)")
        }
        
        do {
            try context.save()
            print("New tracker successfully created and saved to the database.")
        } catch {
            print("Error saving new tracker: \(error.localizedDescription)")
        }
    }
    
    func fetchTracker(with id: UUID) -> TrackersCoreData? {
        let fetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.first
        } catch {
            print("Error fetching tracker with id \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func fetchTracker(with id: UUID, context: NSManagedObjectContext) -> TrackersCoreData? {
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
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Начало обновления контента
        // Вы можете выполнить действия, которые нужно выполнить перед началом обновления, например, начать обновление интерфейса
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Завершение обновления контента
        // Вы можете выполнить действия, которые нужно выполнить после завершения обновления, например, обновить интерфейс
        delegate?.trackerStoreDidUpdateData()
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
    
    func deleteTracker(with id: UUID) {
        let fetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let trackers = try context.fetch(fetchRequest)
            if let tracker = trackers.first {
                context.delete(tracker)
                try context.save()
            }
        } catch {
            print("Error deleting tracker: \(error)")
        }
    }

}
