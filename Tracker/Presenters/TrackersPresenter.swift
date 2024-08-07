//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 17.12.2023.
//

import UIKit



protocol TrackersPresenterProtocol: AnyObject {
    var viewController: TrackersViewController? { get set }
    var visibleTrackerCategories: [TrackersCategoryCoreData] { get set }
    func viewDidLoad()
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func setDateForTrackers(for date: Date)
    func removeButtonTapped(trackerID: UUID)
    func filteredTrackersInCategory(_ category: TrackersCategoryCoreData, for weekday: Int) -> [TrackersCoreData]
    func weekdayNumber(for date: Date) -> Int
    func categoryName(forSection section: Int) -> String
    func trackerAtIndexPath(_ indexPath: IndexPath) -> TrackersCoreData?
    func updateVisibleTrackerCategories(_ date: Date)
    func filterCompletedTrackers(for date: Date)
    var currentFilter: FilterOption { get set }
}

class TrackersPresenter: TrackersPresenterProtocol {
    
    weak var viewController: TrackersViewController?
    var visibleTrackerCategories = [TrackersCategoryCoreData]()
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore.shared
    private var currentDate = Date()
    var currentFilter: FilterOption = .allTrackers
    
    func viewDidLoad() {
        updateVisibleTrackerCategories(currentDate)
    }
    
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
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let filteredTrackers = filterTrackers(trackers, for: weekday, on: startOfDay, withFilter: currentFilter, using: calendar)
        return filteredTrackers.sorted { $0.name ?? "" < $1.name ?? "" }
    }
    
    func categoryName(forSection section: Int) -> String {
        guard section < visibleTrackerCategories.count else { return "" }
        return visibleTrackerCategories[section].name ?? ""
    }
    
    func setDateForTrackers(for date: Date) {
        currentDate = date
        updateVisibleTrackerCategories(currentDate)
    }
    
    func updateVisibleTrackerCategories(_ currentDate: Date) {
        visibleTrackerCategories = categoryStore.fetchCategoriesWithTrackersOnWeekday(currentDate)
        viewController?.trackersCollectionView.reloadData()
        viewController?.checkEmptyState()
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
    
    func filterCompletedTrackers(for date: Date) {
        updateVisibleTrackerCategories(date)
    }
}

