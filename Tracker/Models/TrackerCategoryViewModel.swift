//
//  TrackerCategoryViewModel.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 26.04.2024.
//

import Foundation

class TrackerCategoryViewModel {
    private var categoryStore: TrackerCategoryStore 
    private(set) var categories: [String] = []
    var updateUI: (() -> Void)?
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        fetchCategories()
    }
    
    func fetchCategories() {
        categoryStore.getCategories { [weak self] fetchedCategories in
            self?.categories = fetchedCategories
            self?.updateUI?()
        }
    }
    
    
    func createCategory(name: String) {
        categoryStore.createCategoryNameOnly(name: name) 
        self.fetchCategories()
        updateUI?()
    }
}
