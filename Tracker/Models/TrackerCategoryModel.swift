//
//  TrackerCategoryModel.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 23.01.2024.

import Foundation

struct TrackerCategory {
    let name: String
    var trackers: [Tracker]

    init(name: String, trackers: [Tracker]) {
        self.name = name
        self.trackers = trackers
    }
}
