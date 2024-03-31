//
//  TrackerManager.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 02.02.2024.

import Foundation

class TrackerManager {
    static let shared = TrackerManager()
    private init() {}
    
    var trackers: [Tracker] = []
    
    func addTracker(_ tracker: Tracker) {
        trackers.append(tracker)
    }
    
    func findTracker(for id: UUID) -> Tracker? {
        return trackers.first(where: { $0.id == id })
    }
    
}

class TrackerCategoryManager {
    static let shared = TrackerCategoryManager()
    private init() {}
    
    var trackerCategories: [TrackerCategory] = []
    
    func addNewTrackerCategories(_ newCategory: TrackerCategory) {
        trackerCategories.append(newCategory)
    }
    
    func addTrackerToCategory(_ newTracker: Tracker, categoryName: String) {
        if let index = trackerCategories.firstIndex(where: { $0.name == categoryName }) {
            trackerCategories[index].trackers.append(newTracker)
        }
    }
}

class TrackerRecordManager {
    static let shared = TrackerRecordManager()
    
    var completedTrackers: Set<TrackerRecord> = []
    
    private init() {}
    
    func addTrackerRecord(id: UUID, date: Date) {
        let trackerRecord = TrackerRecord(id: id, date: date)
        completedTrackers.insert(trackerRecord)
        //      print("Добавлен новый элемент \(completedTrackers)")
        //     print("Количество элементов массива стало \(completedTrackers.count)")
    }
    
    func removeTrackerRecord(id: UUID, date: Date) {
        let trackerRecordToRemove = completedTrackers.first { $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
        if let trackerRecordToRemove = trackerRecordToRemove {
            completedTrackers.remove(trackerRecordToRemove)
            //            print("Удален элемент \(completedTrackers)")
            //            print("Количество элементов массива стало \(completedTrackers.count)")           
        }
    }
    
    func getTrackerRecords() -> Set<TrackerRecord> {
        return completedTrackers
    }
    
    func countTrackerRecords(for id: UUID) -> Int {
        return completedTrackers.filter { $0.id == id }.count
    }
}


