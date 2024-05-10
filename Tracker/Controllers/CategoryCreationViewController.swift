//
//  CategoryCreationViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 08.02.2024.

import Foundation
import UIKit

protocol CategoryCreationDelegate: AnyObject {
    func didCreatCategory(_ category: String)
}

class CategoryCreationViewController: UIViewController {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.textAlignment = .center
        label.textColor = .invertedSystemBackground
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .yBackground
        textField.layer.cornerRadius = 16
        textField.attributedPlaceholder = NSAttributedString(string: "Введите название категории", attributes: [NSAttributedString.Key.foregroundColor: UIColor.yGray])
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = .invertedSystemBackground
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: CategoryCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(titleLabel)
        view.addSubview(categoryNameTextField)
        view.addSubview(saveButton)
        updateSaveButtonAvailability()
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupConstraints()
    }
    
    func setupConstraints() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        
        categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        categoryNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        categoryNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        categoryNameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSaveButtonAvailability()
    }
    
    func updateSaveButtonAvailability() {
        let isNameValid = !(categoryNameTextField.text?.isEmpty ?? true)
        
        if isNameValid {
            saveButton.isEnabled = true
            saveButton.tintColor = UIColor.systemBackground
            saveButton.backgroundColor = .invertedSystemBackground
        } else {
            saveButton.isEnabled = false
            saveButton.tintColor = .invertedSystemBackground
            saveButton.backgroundColor = .yGray
        }
    }
    
    @objc func saveButtonTapped() {
        guard let newCategory = categoryNameTextField.text, !newCategory.isEmpty else {
            return
        }
        delegate?.didCreatCategory(newCategory)
        
        dismiss(animated: true, completion: nil)
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}

