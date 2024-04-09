//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData

class TrackerRecordStore: CoreDataStore {
    func createRecord(date: Date, tracker: TrackersCoreData) {
        let context = persistentContainer.viewContext
            guard let trackerInContext = context.object(with: tracker.objectID) as? TrackersCoreData else {
                fatalError("Tracker is not in the same context as newRecord")
            }
            
            let newRecord = TrackersRecordCoreData(context: context)
            newRecord.date = date
            newRecord.trackers = trackerInContext
        
            do {
                try context.save()
          //      let totalCount = countRecords()
           //     print("Запись трекера \(String(describing: tracker.id)) на дату \(date) успешно создана и сохранена в базе данных.")
           //     print("Общее количество записей в базе TrackerRecordCoreData: \(totalCount)")
          //      print("Вот все записи базы:")
//                let allRecords = fetchAllRecords()
//                for record in allRecords {
//                    guard let trackers = record.trackers as? Set<TrackersCoreData> else {
//                        print("Дата записи: \(String(describing: record.date)), ID трекеров: Нет трекеров")
//                        continue
//                    }
//                    var trackersInfo = ""
//                        for tracker in trackers {
//                            if let trackerID = tracker.id {
//                                trackersInfo += "\(trackerID.uuidString), "
//                            } else {
//                                trackersInfo += "Нет идентификатора, "
//                            }
//                        }
//                        print("Дата записи: \(String(describing: record.date)), ID трекеров: \(trackersInfo)")
//                }
                           
            } catch {
                print("Ошибка при создании и сохранении записи трекера на дату \(date): \(error.localizedDescription)")
            }
    }
    
    func countRecords() -> Int {
        let context = persistentContainer.viewContext
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
        let context = persistentContainer.viewContext
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
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<TrackersRecordCoreData> = TrackersRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY trackers.id == %@ AND date == %@", trackerID as CVarArg, date as CVarArg)
        
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
        let context = persistentContainer.viewContext
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
        let context = persistentContainer.viewContext
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
}
