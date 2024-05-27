//
//  TrackerUtils.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 09.05.2024.
//

import Foundation
import UIKit

enum FilterOption: Int {
    case allTrackers = 0
    case today
    case completed
    case incomplete
}

func filterTrackers(_ trackers: Set<TrackersCoreData>, for weekday: Int, on date: Date, withFilter filter: FilterOption, using calendar: Calendar) -> [TrackersCoreData] {
    let startOfDay = calendar.startOfDay(for: date)

    let hasRecordOnDate: (TrackersCoreData) -> Bool = { tracker in
        guard let recordsSet = tracker.trackerRecords as? Set<TrackersRecordCoreData> else { return false }
        return recordsSet.contains { record in
            let recordDate = calendar.startOfDay(for: record.date ?? Date())
            return recordDate == startOfDay
        }
    }

    return trackers.filter { tracker in
        if let scheduleData = tracker.schedule,
            let schedule = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scheduleData as! Data) as? [Int] {
            switch filter {
            case .allTrackers, .today:
                return schedule.contains(weekday) || tracker.typeTracker == 1
            case .completed:
                return (schedule.contains(weekday) || tracker.typeTracker == 1) && hasRecordOnDate(tracker)
            case .incomplete:
                return (schedule.contains(weekday) || tracker.typeTracker == 1) && !hasRecordOnDate(tracker)
            }
        } else {
            return tracker.typeTracker == 1
        }
    }
}

extension UIColor {
    static var invertedSystemBackground: UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return .black
            }
        }
    }
}
