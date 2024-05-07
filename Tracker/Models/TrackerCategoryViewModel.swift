//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 26.04.2024.
//

import Foundation

class TrackerCategoryViewModel {
    private var categoryStore: TrackerCategoryStore 
    private let pinnedCategoryName = "Закрепленные"
    private(set) var categories: [String] = []
    var updateUI: (() -> Void)?
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        fetchCategories()
    }
    
    func fetchCategories() {
        categoryStore.getCategories { [weak self] fetchedCategories in
            self?.categories = fetchedCategories.filter { $0 != self?.pinnedCategoryName }
            self?.updateUI?()
        }
    }
    
    func createCategory(name: String) {
        guard name != pinnedCategoryName else {
                    print("Категория с именем '\(pinnedCategoryName)' не может быть создана.")
                    return
                }
        categoryStore.createCategoryNameOnly(name: name)
        self.fetchCategories()
        updateUI?()
    }
}
