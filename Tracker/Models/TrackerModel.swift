//
//  TrackerModel.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 23.01.2024.

import Foundation

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Int]
    let isPinned: Bool
}

extension Tracker {
    var type: TrackerType {
        schedule.isEmpty ? .unregularEvent : .habit
    }
}
