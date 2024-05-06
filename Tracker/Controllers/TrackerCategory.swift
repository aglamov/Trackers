//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 29.01.2024.

import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}

final class TrackerCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    private var selectedIndexPath: IndexPath?
    weak var delegate: CategorySelectionDelegate?
    var selectedCategory: String = ""
    private var viewModel: TrackerCategoryViewModel!
    private var tableView: UITableView!
    
    func didSelectCategory(_ category: String) {
        delegate?.didSelectCategory(category)
    }
    
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .yBackground
    }
    
    private func updateCreateCategoryButtonTitle() {
        if selectedCategory == "" {
            saveButton.setTitle("Создать категорию", for: .normal)
        } else {
            saveButton.setTitle("Готово", for: .normal)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавить категорию"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var setupTableView: UITableView = {
        let planningTableView = UITableView(frame: .zero, style: .insetGrouped)
        planningTableView.translatesAutoresizingMaskIntoConstraints = false
        planningTableView.separatorStyle = .singleLine
        planningTableView.contentInsetAdjustmentBehavior = .never
        planningTableView.backgroundColor = .white
        planningTableView.isScrollEnabled = true
        planningTableView.showsVerticalScrollIndicator = false
        planningTableView.dataSource = self
        planningTableView.delegate = self
        planningTableView.allowsSelection = true
        
        return planningTableView
    }()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(setupTableView)
        view.addSubview(saveButton)
        
        setupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        setupTableView.dataSource = self
        setupTableView.delegate = self
        setupViewModel()
        
        if let index = viewModel.categories.firstIndex(of: selectedCategory) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        }
        setupConstraints()
        updateCreateCategoryButtonTitle()
    }
    
    func setupConstraints() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        setupTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        setupTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        setupTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        setupTableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -5).isActive = true
        
        saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc func saveButtonTapped() {
        if selectedCategory.isEmpty {
            let categoryCreationVC = CategoryCreationViewController()
            categoryCreationVC.delegate = self
            present(categoryCreationVC, animated: true, completion: nil)
        } else {
            delegate?.didSelectCategory(selectedCategory)
            dismiss(animated: true, completion: nil)
            if let navigationController = self.navigationController {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    
    private func setupViewModel() {
        viewModel = TrackerCategoryViewModel(categoryStore: TrackerCategoryStore())
        viewModel.updateUI = { [weak self] in
            self?.setupTableView.reloadData()
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
