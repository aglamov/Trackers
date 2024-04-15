//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData
import UIKit

class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackersRecordCoreData>!
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }

    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()

        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackersRecordCoreData.date, ascending: true)
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
    
    
    func createRecord(date: Date, tracker: TrackersCoreData) {
            guard let trackerInContext = context.object(with: tracker.objectID) as? TrackersCoreData else {
                fatalError("Tracker is not in the same context as newRecord")
            }
            
            let newRecord = TrackersRecordCoreData(context: context)
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            newRecord.date = startOfDay
            newRecord.trackers = trackerInContext
        
            do {
                try context.save()
                print("Создана запись на дату \(date) с идентификтором \(tracker.id)")
            } catch {
                print("Ошибка при создании и сохранении записи трекера на дату \(date): \(error.localizedDescription)")
            }
    }
    
    func countRecords() -> Int {
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Ошибка при подсчете записей: \(error.localizedDescription)")
            return 0
        }
    }
    
    func fetchAllRecords() -> [TrackersRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        
        do {
            let records = try context.fetch(fetchRequest)
            return records
        } catch {
            print("Ошибка при получении записей: \(error.localizedDescription)")
            return []
        }
    }
    
    func removeRecord(trackerID: UUID, date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY trackers.id == %@ AND date == %@", trackerID as CVarArg, startOfDay as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)

            for record in records {
                context.delete(record)
            }

            try context.save()
            
            print("Записи для трекера с ID \(trackerID) на дату \(date) успешно удалены.")
        } catch {
            print("Ошибка при удалении записей: \(error.localizedDescription)")
        }
    }
    
    private func fetchTracker(with id: UUID, context: NSManagedObjectContext) -> TrackersCoreData? {
        let fetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.first
        } catch {
            print("Ошибка при получении трекера с ID \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
    func doesRecordExist(forTrackerID trackerID: UUID, date: Date) -> Bool {
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
      
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND ANY trackers.id == %@", startOfDay as CVarArg, trackerID as CVarArg)
        
        do {
            let count = try context.count(for: fetchRequest)
            fetchAndPrintRecords(forTrackerID: trackerID)
            return count > 0
        } catch {
            print("Error fetching record count: \(error.localizedDescription)")
            return false
        }
    }

    private func fetchRecord(with id: UUID, context: NSManagedObjectContext) -> TrackersRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.first
        } catch {
            print("Ошибка при поиске записи: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchRecords(forTrackerID trackerID: UUID, date: Date) -> [TrackersRecordCoreData]? {
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND ANY trackers.id == %@", date as CVarArg, trackerID as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return nil
        }
    }
    
    func countRecords(forTrackerID trackerID: UUID) -> Int {
        let trackerFetchRequest: NSFetchRequest<TrackersCoreData> = TrackersCoreData.fetchRequest()
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        do {
            let trackers = try context.fetch(trackerFetchRequest)
            guard let tracker = trackers.first else {
                print("Tracker with ID \(trackerID) not found")
                return 0
            }
            let recordFetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
            recordFetchRequest.predicate = NSPredicate(format: "ANY trackers == %@", tracker)
            let count = try context.count(for: recordFetchRequest)
            return count
        } catch {
            print("Error counting records for tracker with ID \(trackerID): \(error.localizedDescription)")
            return 0
        }
    }
    
   private func fetchAndPrintRecords(forTrackerID trackerID: UUID) {
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY trackers.id == %@", trackerID as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            if records.isEmpty {
                print("No records found for tracker with ID \(trackerID)")
            } else {
                print("Records for tracker with ID \(trackerID):")
                for record in records {
                    print("- \(record)")
                }
            }
        } catch {
            print("Error fetching records for tracker with ID \(trackerID): \(error.localizedDescription)")
        }
    }

}
