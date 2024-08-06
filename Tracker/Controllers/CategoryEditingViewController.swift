//
//  CategoryEditingViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 08.05.2024.
//

import UIKit

protocol CategoryEditingDelegate: AnyObject {
    func didEditCategory(oldCategory: String, newCategory: String)
}

class CategoryEditingViewController: CategoryCreationViewController {
    private var originalCategoryName: String = ""
    weak var editDelegate: CategoryEditingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Редактирование категории"
        categoryNameTextField.text = originalCategoryName
        updateSaveButtonAvailability()
    }
  
    func configureWithCategoryName(_ categoryName: String) {
        originalCategoryName = categoryName
    }

    override func saveButtonTapped() {
        guard let newCategory = categoryNameTextField.text, !newCategory.isEmpty else {
            return
        }
        
        editDelegate?.didEditCategory(oldCategory: originalCategoryName, newCategory: newCategory)
        dismiss(animated: true, completion: nil)
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}
