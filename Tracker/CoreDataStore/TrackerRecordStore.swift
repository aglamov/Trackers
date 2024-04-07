//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 31.03.2024.
//

import Foundation
import CoreData

class TrackerRecordStore: CoreDataStore {
    func createRecord(date: Date, trackerID: UUID) {
        let context = persistentContainer.viewContext
        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.date = date
        if let tracker = fetchTracker(with: trackerID, context: context) {
            newRecord.addToTrackers(tracker)
            do {
                try context.save()
                print("Запись трекера на дату \(date) успешно создана и сохранена в базе данных.")
            } catch {
                print("Ошибка при создании и сохранении записи трекера на дату \(date): \(error.localizedDescription)")
            }
        } else {
            print("Трекер с ID \(trackerID) не найден.")
        }
    }
    
    func removeRecord(trackerID: UUID, date: Date) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY trackers.id == %@ AND date == %@", trackerID as CVarArg, date as CVarArg)
        
        do {
            // Получаем записи, соответствующие запросу
            let records = try context.fetch(fetchRequest)
            
            // Удаляем найденные записи
            for record in records {
                context.delete(record)
            }
            
            // Сохраняем контекст
            try context.save()
            
            print("Записи для трекера с ID \(trackerID) на дату \(date) успешно удалены.")
        } catch {
            print("Ошибка при удалении записей: \(error.localizedDescription)")
        }
    }
    
    private func fetchTracker(with id: UUID, context: NSManagedObjectContext) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.first
        } catch {
            print("Ошибка при получении трекера с ID \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchRecord(with id: UUID, context: NSManagedObjectContext) -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.first
        } catch {
            print("Ошибка при поиске записи: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchRecords(forTrackerID trackerID: UUID, date: Date) -> [TrackerRecordCoreData]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
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
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY trackers.id == %@", trackerID as CVarArg)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Error counting records for tracker with ID \(trackerID): \(error.localizedDescription)")
            return 0
        }
    }
}
