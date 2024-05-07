//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 29.01.2024.

import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

protocol TrackerCategoryContextMenuDelegate: AnyObject {
    func editCategory(name: String)
    func deleteCategory(name: String)
}

final class TrackerCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var contextMenuDelegate: TrackerCategoryContextMenuDelegate?
    private var selectedIndexPath: IndexPath?
    weak var delegate: CategorySelectionDelegate?
    var selectedCategory: String = ""
    private var viewModel: TrackerCategoryViewModel!
    
    private lazy var setupTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавить категорию"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(setupTableView)
        view.addSubview(saveButton)
        
        setupConstraints()
        setupViewModel()
        
        if let index = viewModel.categories.firstIndex(of: selectedCategory) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        }
        
        updateCreateCategoryButtonTitle()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            setupTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            setupTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            setupTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            
            setupTableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -5),
            
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupViewModel() {
        viewModel = TrackerCategoryViewModel(categoryStore: TrackerCategoryStore())
        viewModel.updateUI = { [weak self] in
            self?.setupTableView.reloadData()
        }
    }
    
    private func updateCreateCategoryButtonTitle() {
        if selectedCategory.isEmpty {
            saveButton.setTitle("Создать категорию", for: .normal)
        } else {
            saveButton.setTitle("Готово", for: .normal)
        }
    }
    
    @objc private func saveButtonTapped() {
        if selectedCategory.isEmpty {
            let categoryCreationVC = CategoryCreationViewController()
            categoryCreationVC.delegate = self
            present(categoryCreationVC, animated: true, completion: nil)
        } else {
            delegate?.didSelectCategory(selectedCategory)
            dismiss(animated: true, completion: nil)
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.categories[indexPath.row]
        
        if let selectedIndexPath = selectedIndexPath, indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 75
        }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cell.backgroundColor = .yBackground
        }
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
            selectedCategory = ""
        } else {
            selectedIndexPath = indexPath
            selectedCategory = viewModel.categories[indexPath.row]
        }
        tableView.reloadData()
        updateCreateCategoryButtonTitle()
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let categoryName = viewModel.categories[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.contextMenuDelegate?.editCategory(name: categoryName)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                let alertController = UIAlertController(
                    title: "Удалить категорию?",
                    message: "Вы уверены, что хотите удалить категорию \"\(categoryName)\"?",
                    preferredStyle: .alert
                )
                
                let confirmDeleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    self.contextMenuDelegate?.deleteCategory(name: categoryName)
                }
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                
                alertController.addAction(confirmDeleteAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

extension TrackerCategoryViewController: CategoryCreationDelegate {
    func didCreatCategory(_ category: String) {
        viewModel.createCategory(name: category)
        DispatchQueue.main.async { [weak self] in
            self?.setupTableView.reloadData()
        }
    }
}
