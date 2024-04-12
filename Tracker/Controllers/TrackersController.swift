//
//  ViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 16.12.2023.

import UIKit

//protocol TrackersViewControllerProtocol: AnyObject {
//    var presenter: TrackersPresenterProtocol? { get }
//    var trackersCollectionView: UICollectionView { get }
//    var currentDate: Date? { get }
//    func didSelectDate(_ date: Date)
//}

final class TrackersViewController: UIViewController, TrackerCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let categoryStore = TrackerCategoryStore()
       let coreDataStore = CoreDataStore()
       var currentDate: Date = Date()
       var presenter: TrackersPresenterProtocol?
       var visibleTrackerCategories = [TrackersCategoryCoreData]()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
//        let carrentTrackerCategories = TrackerCategoryStore()
//        let weekday = weekdayNumber(for: currentDate)
        
    //    visibleTrackerCategories = carrentTrackerCategories.fetchCategoriesWithTrackersOnWeekday(weekday)
        
        let category = visibleTrackerCategories[indexPath.section]
        if let trackersSet = category.trackers,
           let trackersArray = trackersSet.allObjects as? [TrackersCoreData],
           indexPath.item < trackersArray.count {
            
            let tracker = trackersArray[indexPath.item]
            cell.id = tracker.id
            cell.titleLabel.text = tracker.name
            let colorCell = tracker.color as? UIColor
            cell.containerView.backgroundColor = colorCell
            cell.emoji.text = tracker.emoji
            cell.containerEmoji.backgroundColor = colorCell?.withAlphaComponent(0.2)
            cell.delegate = self
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        let carrentTrackerCategories = TrackerCategoryStore()
//        let weekday = weekdayNumber(for: currentDate)
//        
   //     visibleTrackerCategories = carrentTrackerCategories.fetchCategoriesWithTrackersOnWeekday(weekday)
        for category in visibleTrackerCategories {
            print("Категория: \(category.name ?? "Unknown")")
            if let trackers = category.trackers {
                for tracker in trackers {
                    print("  Tracker: \((tracker as AnyObject).name ?? "Unknown")")
                }
            } else {
                print("  Нет трекеров в этой категории")
            }
        }
        return visibleTrackerCategories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleTrackerCategories[section].trackers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
//        let carrentTrackerCategories = TrackerCategoryStore()
//        let weekday = weekdayNumber(for: currentDate)
//        
//        visibleTrackerCategories = carrentTrackerCategories.fetchCategoriesWithTrackersOnWeekday(weekday)
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
            headerView.titleLabel.text = visibleTrackerCategories[indexPath.section].name
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let trackerCell = cell as? TrackerCell else { return }
        updateCellUIAndButton(for: trackerCell)
    }
    
    private func updateVisibleTrackerCategories() {
  //      visibleTrackerCategories = TrackerCategoryStore().fetchCategories()
        trackersCollectionView.reloadData()
        checkEmptyState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateVisibleTrackerCategories()
        trackersCollectionView.reloadData()
        checkEmptyState()
    }
    
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
    
    private func checkEmptyState() {
        if visibleTrackerCategories.isEmpty {
            emptyScreenImage.isHidden = false
            emptyScreenText.isHidden = false
        } else {
            emptyScreenImage.isHidden = true
            emptyScreenText.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackersScreen()
        trackersCollectionView.delegate = self
        categoryStore.delegate = self
        categoryStore.fetchCategories()
        currentDate = Date()
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
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func updateCellUIAndButton(for cell: TrackerCell) {
        guard let trackerID = cell.id else {
            return
        }
        let trackerRecordStore = TrackerRecordStore()
        
        print("Обрабатываем трекер \(trackerID)")
        let recordCount = trackerRecordStore.countRecords(forTrackerID: trackerID)
        print("Количество записей с таким трекером \(recordCount)")
        cell.countLabel.text = "\(recordCount) \(dayString(for: recordCount))"
        
        let isCompleted = isTrackerCompleted(trackerID, date: currentDate)
        print("На дату \(currentDate) трекер выполнен \(isCompleted)")
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

    private func isTrackerCompleted(_ trackerID: UUID, date: Date) -> Bool {
        let recordStore = TrackerRecordStore()
        if let records = recordStore.fetchRecords(forTrackerID: trackerID, date: date) {
            return !records.isEmpty
        }
        return false
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
    
    @objc private func addButtonTapped() {
        let trackerCreation = TrackerCreationViewController()
        let navController = UINavigationController(rootViewController: trackerCreation)
        navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc private func setDateForTrackers(_ sender: UIDatePicker) {
        currentDate = sender.date
        let weekday = Calendar.current.component(.weekday, from: currentDate)
       // let trackerCategories = TrackerCategoryStore().fetchCategories()
        visibleTrackerCategories.removeAll()
//        for category in trackerCategories {
//            guard let trackers = category.trackers else { continue }
//            for tracker in trackers {
//                guard let tracker = tracker as? TrackersCoreData else { continue }
//                guard let scheduleData = tracker.schedule as? Data else { continue }
//                do {
//                    if let schedule = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scheduleData) as? [Int] {
//                        print("Расписание для трекере \(tracker.name ?? ""): \(schedule)")
//                        if schedule.contains(weekday) || tracker.typeTracker == 1 {
//                            visibleTrackerCategories.append(category)
//                            break
//                        }
//                    }
//                } catch {
//                    print("Ошибка декодирования расписания: \(error)")
//                }
//            }
//        }
        checkEmptyState()
        trackersCollectionView.reloadData()
    }
    
    func weekdayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date)
    }
}


extension TrackersViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChange(_ trackerCategoryStore: TrackerCategoryStore) {
        
    }
    
    func trackerCategoryStore(_ trackerCategoryStore: TrackerCategoryStore, didFetchCategories categories: [TrackersCategoryCoreData]) {
        self.visibleTrackerCategories = categories
        trackersCollectionView.reloadData()
    }
    
    func trackerCategoryStore(_ trackerCategoryStore: TrackerCategoryStore, didFailWithError error: Error) {
        // Обработка ошибки при получении данных
    }
}
