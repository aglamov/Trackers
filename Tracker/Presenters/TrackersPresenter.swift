//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 17.12.2023.
//

import UIKit

import UIKit

protocol TrackersPresenterProtocol: AnyObject {
    var viewController: TrackersViewController? { get set }
    var visibleTrackerCategories: [TrackersCategoryCoreData] { get set }
    func viewDidLoad()
    //  func viewWillAppear()
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func setDateForTrackers(for date: Date)
    func addButtonTapped(trackerID: Int)
    func removeButtonTapped(trackerID: UUID)
    func filteredTrackersInCategory(_ category: TrackersCategoryCoreData, for weekday: Int) -> [TrackersCoreData]
    func weekdayNumber(for date: Date) -> Int
    func categoryName(forSection section: Int) -> String
    func trackerAtIndexPath(_ indexPath: IndexPath) -> TrackersCoreData?
    func updateVisibleTrackerCategories(_ date: Date)
}

class TrackersPresenter: TrackersPresenterProtocol {
    weak var viewController: TrackersViewController?
    var visibleTrackerCategories = [TrackersCategoryCoreData]()
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private var currentDate = Date()
    
    func viewDidLoad() {
        updateVisibleTrackerCategories(currentDate)
    }
    
    //    func viewWillAppear() {
    //        viewController?.checkEmptyState()
    //    }
    //
    func numberOfSections() -> Int {
        return visibleTrackerCategories.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard section < visibleTrackerCategories.count else { return 0 }
        let category = visibleTrackerCategories[section]
        let weekday = weekdayNumber(for: currentDate)
        return filteredTrackersInCategory(category, for: weekday).count
    }
    
    func filteredTrackersInCategory(_ category: TrackersCategoryCoreData, for weekday: Int) -> [TrackersCoreData] {
        guard let trackers = category.trackers as? Set<TrackersCoreData> else { return [] }
        let sortedTrackers = trackers.sorted { $0.name ?? "" < $1.name ?? "" }
        let filteredTrackers = sortedTrackers.filter { tracker in
            if let scheduleData = tracker.schedule,
               let schedule = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scheduleData as! Data) as? [Int] {
                return schedule.contains(weekday) || tracker.typeTracker == 1
            } else {
                return tracker.typeTracker == 1
            }
        }
        return filteredTrackers
    }
    
    func categoryName(forSection section: Int) -> String {
        guard section < visibleTrackerCategories.count else { return "" }
        return visibleTrackerCategories[section].name ?? ""
    }
    
    func setDateForTrackers(for date: Date) {
        currentDate = date
        updateVisibleTrackerCategories(currentDate)
    }
    
    func updateVisibleTrackerCategories(_ date: Date) {
        let weekday = weekdayNumber(for: date)
        visibleTrackerCategories = categoryStore.fetchCategoriesWithTrackersOnWeekday(weekday)
        viewController?.trackersCollectionView.reloadData()
        viewController?.checkEmptyState()
    }
    
    func addButtonTapped(trackerID: Int) {
        // Логика добавления трекера
    }
    
    func removeButtonTapped(trackerID: UUID) {
        trackerStore.deleteTracker(with: trackerID)
        updateVisibleTrackerCategories(currentDate)
    }
    
    func weekdayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date)
    }
    
    func trackerAtIndexPath(_ indexPath: IndexPath) -> TrackersCoreData? {
        let category = visibleTrackerCategories[indexPath.section]
        let weekday = weekdayNumber(for: currentDate)
        let trackers = filteredTrackersInCategory(category, for: weekday)
        return trackers.count > indexPath.row ? trackers[indexPath.row] : nil
    }
    
}
