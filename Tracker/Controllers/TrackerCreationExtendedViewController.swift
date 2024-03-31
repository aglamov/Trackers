//
//   TrackerCreation2Controller.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 25.01.2024.

import Foundation
import UIKit

final class TrackerCreationExtendedViewController: UIViewController  {
    
    var selectedType: TrackerType
    var selectedCategory: String = ""
    var selectedDays: String = ""
    var selectedIndexes: [Int] = []
    var selectedEmojiIndexPath: IndexPath?
    var selectedColorIndexPath: IndexPath?
    
    init(selectedType: TrackerType) {
        self.selectedType = selectedType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .yBackground
        textField.layer.cornerRadius = 16
        textField.attributedPlaceholder = NSAttributedString(string: "Введите название трекера", attributes: [NSAttributedString.Key.foregroundColor: UIColor.yGray])
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.yRed, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.yRed.cgColor
        
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .yGray
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
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
    
    private lazy var titleEmoji: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: 50, height: 50)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        return collectionView
    }()
    
    private lazy var titleColor: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: 50, height: 50)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        return collectionView
    }()
    
    func updateSaveButtonAvailability() {
        let isNameValid = !(trackerNameTextField.text?.isEmpty ?? true)
        let isCategorySelected = !selectedCategory.isEmpty
        let currentTrackerType = selectedType
        var isScheduleSelected = true
        if currentTrackerType == .habit {
            isScheduleSelected = !selectedIndexes.isEmpty }
        
        if isNameValid && isCategorySelected && isScheduleSelected {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .black
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .yGray
        }
    }
    
    func textField(_  textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSaveButtonAvailability()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateSaveButtonAvailability()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(titleLabel)
        view.addSubview(trackerNameTextField)
        contentView.addSubview(setupTableView)
        contentView.addSubview(titleEmoji)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(titleColor)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(saveButton)
        setupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let totalContentHeight = calculateTotalContentHeight()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: totalContentHeight)
    }
    
    func calculateTableViewHeight() -> CGFloat {
        let numberOfRows = setupTableView.numberOfRows(inSection: 0)
        let firstRowHeight = tableView(setupTableView, heightForRowAt: IndexPath(row: 0, section: 0))
        let totalHeight = CGFloat(numberOfRows) * firstRowHeight
        return totalHeight
    }
    
    func calculateTotalContentHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        totalHeight += setupTableView.contentSize.height
        totalHeight += titleEmoji.frame.height
        totalHeight += emojiCollectionView.frame.height
        totalHeight += titleColor.frame.height
        totalHeight += colorCollectionView.frame.height
        
        totalHeight += 140
        return totalHeight
    }
    
    func setupConstraints() {
        titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        trackerNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        trackerNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        trackerNameTextField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 123).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        setupTableView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        setupTableView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        setupTableView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        setupTableView.heightAnchor.constraint(equalToConstant: calculateTableViewHeight()+30).isActive = true
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        titleEmoji.translatesAutoresizingMaskIntoConstraints = false
        titleEmoji.topAnchor.constraint(equalTo: setupTableView.bottomAnchor, constant: 20).isActive = true
        titleEmoji.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.topAnchor.constraint(equalTo: titleEmoji.bottomAnchor, constant: 10).isActive = true
        emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        emojiCollectionView.heightAnchor.constraint(equalToConstant: 165).isActive = true
        
        titleColor.translatesAutoresizingMaskIntoConstraints = false
        titleColor.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 10).isActive = true
        titleColor.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.topAnchor.constraint(equalTo: titleColor.bottomAnchor, constant: 10).isActive = true
        colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: 165).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 20).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -5).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        saveButton.topAnchor.constraint(equalTo: cancelButton.topAnchor).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 5).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        contentView.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor).isActive = true
        
    }
    
    @objc private func scheduleButtonTapped() {
        let trackerCreation = TrackerSchedule()
        trackerCreation.delegate = self
        let navController = UINavigationController(rootViewController: trackerCreation)
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc private func categoryButtonTapped() {
        let trackerCreation = TrackerCategoryViewController()
        trackerCreation.delegate = self
        let navController = UINavigationController(rootViewController: trackerCreation)
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        let id = UUID()
        let name = trackerNameTextField.text ?? ""
        let color = UIColor.red
        let emoji = "💪"
        let schedule: [Int] = selectedIndexes
        let isPinned = false
        
        let newTracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, isPinned: isPinned)
        TrackerManager.shared.addTracker(newTracker)
        
        if TrackerCategoryManager.shared.trackerCategories.contains(where: { $0.name == selectedCategory }) {
            TrackerCategoryManager.shared.addTrackerToCategory(newTracker, categoryName: selectedCategory)
        } else {
            let newCategory = TrackerCategory(name: selectedCategory, trackers: [newTracker])
            TrackerCategoryManager.shared.addNewTrackerCategories(newCategory)
        }
        
        let trackerStore = TrackerStore()
           
           // Вызываем метод createTracker() для сохранения нового трекера в Core Data
        trackerStore.createTracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, isPinned: isPinned)
        
        
        
        let tabBarController = TabBarController.shared
        tabBarController.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSaveButtonAvailability()
    }
}

extension TrackerCreationExtendedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentTrackerType = selectedType
        return currentTrackerType == .habit ? 2: 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            if selectedCategory == "" { cell.textLabel?.text = "Выберите категорию" } else {
                cell.textLabel?.text = "Категория"
                cell.detailTextLabel?.text = selectedCategory
                cell.detailTextLabel?.textColor = .gray
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            }
            
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = selectedDays
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        }
        return cell
    }
}

extension TrackerCreationExtendedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .yBackground
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            scheduleButtonTapped()
            return
        }
        if indexPath.row == 0 {
            categoryButtonTapped()
        }
    }
}

extension TrackerCreationExtendedViewController: CategorySelectionDelegate {
    func didDeselectCategory() {
        updateSaveButtonAvailability()
    }
    
    func didSelectCategory(_ category: String) {
        selectedCategory = category
        updateSaveButtonAvailability()
        setupTableView.reloadData()
    }
}

extension TrackerCreationExtendedViewController: TrackerScheduleDelegate {
    func didUpdateSelectedWeekdays(_ selectedWeekdays: [(String, Int)]) {
        selectedDays = selectedWeekdays.map { $0.0 }.joined(separator: ", ")
        selectedIndexes = selectedWeekdays.map { $0.1 }
        updateSaveButtonAvailability()
        setupTableView.reloadData()
    }
}

extension TrackerCreationExtendedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier: String
        let cell: UICollectionViewCell
        
        if collectionView == emojiCollectionView {
            reuseIdentifier = "emojiCell"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EmojiCollectionViewCell
            let emoji = emojis[indexPath.item]
            (cell as! EmojiCollectionViewCell).configure(with: emoji)
        } else if collectionView == colorCollectionView {
            reuseIdentifier = "colorCell"
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ColorCollectionViewCell
            let color = colors[indexPath.item]
            (cell as! ColorCollectionViewCell).configure(with: color)
        } else {
            fatalError("Unknown collection view")
        }
        
        return cell
    }
}

extension TrackerCreationExtendedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for visibleIndexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: visibleIndexPath) {
                cell.layer.borderWidth = 0.0
                cell.backgroundColor = .clear
            }
        }
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.backgroundColor = .yLightGray
            cell?.layer.cornerRadius = 8.0
            selectedEmojiIndexPath = indexPath
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3.0
            cell?.layer.borderColor = colors[indexPath.item].withAlphaComponent(0.3).cgColor
            cell?.layer.cornerRadius = 10.0
            selectedColorIndexPath = indexPath
        }
    }
}


