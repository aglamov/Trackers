//
//  ViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 16.12.2023.

import UIKit

enum FilterType {
    case all, today, completed, incomplete
}

final class TrackersViewController: UIViewController, TrackerCellDelegate {
    
    let categoryStore = TrackerCategoryStore()
    let trackerStore = TrackerStore()
    var currentDate: Date = Date()
    var presenter: TrackersPresenterProtocol?
    
    lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        return collectionView
    }()
    
    private lazy var datePickerButton: UIBarButtonItem = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(setDateForTrackers), for: .valueChanged)
        let dateButton = UIBarButtonItem(customView: datePicker)
        return dateButton
    }()
    
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyTackers")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyScreenImage)
        view.addSubview(emptyScreenText)
        return view
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.clipsToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackersScreen()
        trackersCollectionView.delegate = self
        categoryStore.delegate = self
        trackerStore.delegate = self
        currentDate = Date()
        presenter = TrackersPresenter()
        presenter?.viewController = self
        presenter?.viewDidLoad()
        checkEmptyState()
    }
    
    func checkEmptyState() {
        if presenter?.numberOfSections() == 0 {
            emptyScreenImage.isHidden = false
            emptyScreenText.isHidden = false
            filterButton.isHidden = true
        } else {
            emptyScreenImage.isHidden = true
            emptyScreenText.isHidden = true
            filterButton.isHidden = false
        }
    }
    
    private func setupTrackersScreen() {
        view.backgroundColor = .white
        setupNavigationBar()
        addSubviews()
        constraintSubviews()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationBar.topItem?.setLeftBarButton(addButton, animated: true)
        navigationBar.topItem?.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    private func addSubviews() {
        view.addSubview(emptyScreenView)
        view.addSubview(trackersCollectionView)
        view.addSubview(filterButton)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyScreenText.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    func updateCellUIAndButton(for cell: TrackerCell) {
        guard let trackerID = cell.id else {
            return
        }
        let trackerRecordStore = TrackerRecordStore()
        let recordCount = trackerRecordStore.countRecords(forTrackerID: trackerID)
        cell.countLabel.text = "\(recordCount) \(dayString(for: recordCount))"
        let isCompleted = trackerRecordStore.doesRecordExist(forTrackerID: trackerID, date: currentDate)
        cell.addButton.isSelected = isCompleted
    }
    
    func doneButtonTapped(in cell: TrackerCell) {
        guard let trackerID = cell.id else {
            return
        }
        
        let trackerStore = TrackerStore()
        
        if !cell.addButton.isSelected {
            if let tracker = trackerStore.fetchTracker(with: trackerID) {
                let trackerRecordStore = TrackerRecordStore()
                trackerRecordStore.createRecord(date: currentDate, tracker: tracker)
            }
            cell.addButton.isSelected = true
        } else {
            let trackerRecordStore = TrackerRecordStore()
            trackerRecordStore.removeRecord(trackerID: trackerID, date: currentDate)
            cell.addButton.isSelected = false
        }
        trackersCollectionView.reloadData()
    }
    
    
    func dayString(for days: Int) -> String {
        if days % 10 == 1 && days % 100 != 11 {
            return "день"
        } else if days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20) {
            return "дня"
        } else {
            return "дней"
        }
    }
    
    func weekdayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date)
    }
    
    @objc private func addButtonTapped() {
        let trackerCreation = TrackerCreationViewController()
        let navController = UINavigationController(rootViewController: trackerCreation)
        navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc private func setDateForTrackers(_ sender: UIDatePicker) {
        currentDate = sender.date
        presenter?.setDateForTrackers(for: currentDate)
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.modalPresentationStyle = .formSheet
        filterVC.delegate = self
        present(filterVC, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        
        if let tracker = presenter?.trackerAtIndexPath(indexPath) {
            cell.id = tracker.id
            cell.titleLabel.text = tracker.name
            cell.containerView.backgroundColor = tracker.color as? UIColor
            cell.emoji.text = tracker.emoji
            cell.addButton.tintColor = tracker.color as? UIColor
            cell.delegate = self
            cell.presenter = self.presenter
            cell.currentDate = currentDate
            cell.updateButtonAvailability(for: currentDate)
            updateCellUIAndButton(for: cell)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInsets: CGFloat = 16 * 3
        let width: CGFloat = min((collectionView.bounds.width - horizontalInsets) / 2, 196)
        let height: CGFloat = 130
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfItems(in: section) ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter?.numberOfSections() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
            headerView.titleLabel.text = presenter?.categoryName(forSection: indexPath.section) ?? "Категория"
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 16, bottom: 24, right: 16)
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ trackerCategoryStore: TrackerCategoryStore) {
        
    }
    
    func trackerCategoryStore(_ trackerCategoryStore: TrackerCategoryStore, didFetchCategories categories: [TrackersCategoryCoreData]) {
        presenter?.visibleTrackerCategories = categories
        presenter?.updateVisibleTrackerCategories(currentDate)
    }
    
    func trackerCategoryStore(_ trackerCategoryStore: TrackerCategoryStore, didFailWithError error: Error) {
        
    }
}

extension TrackersViewController {
    func isPinned(for cell: TrackerCell) -> Bool {
        guard let trackerID = cell.id else {
            return false
        }
        let trackerStore = TrackerStore()
        if let tracker = trackerStore.fetchTracker(with: trackerID) {
            return tracker.isPinned?.boolValue ?? false
        } else {
            return false
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdateData() {
        presenter?.updateVisibleTrackerCategories(currentDate)
    }
}

extension TrackersViewController {
    func editMenuItemTapped(for cell: TrackerCell) {
        guard let trackerID = cell.id else {
            return
        }
        let trackerStore = TrackerStore()
        guard let tracker = trackerStore.fetchTracker(with: trackerID) else {
            return
        }
        let trackerEditViewController = TrackerEditViewController(tracker: tracker)
        let navController = UINavigationController(rootViewController: trackerEditViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)

    }
}

//extension TrackersViewController: FilterViewControllerDelegate {
//    func didSelectCompletedFilter() {
//    presenter?.filterCompletedTrackers(for: currentDate)
//        presenter?.updateVisibleTrackerCategories(currentDate)
//        
//        trackersCollectionView.reloadData()
//    }
//    
//    func didSelectTodayFilter() {
//        if let datePicker = datePickerButton.customView as? UIDatePicker {
//            datePicker.date = Date()
//            currentDate = Date()
//            setDateForTrackers(datePicker)
//        }
//    }
//    
//    func didSelectAllFilter() {
//        presenter?.updateVisibleTrackerCategories(currentDate)
//        }
//    }

extension TrackersViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: FilterOption) {
        presenter?.currentFilter = filter
        presenter?.updateVisibleTrackerCategories(currentDate) // Примените фильтрацию на основе текущего фильтра
    }
}
