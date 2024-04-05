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

    let coreDataStore = CoreDataStore()
    var currentDate: Date = Date()
    var presenter: TrackersPresenterProtocol?
    var trackerCategories: [TrackerCategory] {
        return TrackerCategoryManager.shared.trackerCategories
    }
    var visibleTrackerCategories: [TrackerCategoryCoreData] = []
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        
        let category = visibleTrackerCategories[indexPath.section]
        if let trackersSet = category.trackers,
           let trackersArray = trackersSet.allObjects as? [TrackerCoreData],
           indexPath.item < trackersArray.count {
            
            let tracker = trackersArray[indexPath.item]
            cell.id = tracker.id
            cell.titleLabel.text = tracker.name
            cell.containerView.backgroundColor = tracker.color as? UIColor
            cell.
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
        return visibleTrackerCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleTrackerCategories[section].trackers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
            visibleTrackerCategories = TrackerCategoryStore().fetchCategories()
            trackersCollectionView.reloadData()
            checkEmptyState()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // visibleTrackerCategories = trackerCategories
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
    
    //    func didSelectDate(_ date: Date) {
    //        currentDate = date
    //    }
    
    
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
        //       print("Обрабатываем трекер \(trackerID)")
        let recordCount = TrackerRecordManager.shared.countTrackerRecords(for: trackerID)
        //       print("Количество записей с таким трекером \(recordCount)")
        cell.countLabel.text = "\(recordCount) \(dayString(for: recordCount))"
        
        let isCompleted = isTrackerCompleted(trackerID, date: currentDate)
        //      print("На дату \(currentDate) трекер выполнен \(isCompleted)")
        cell.addButton.isSelected = isCompleted
    }
    
    func doneButtonTapped(in cell: TrackerCell) {
        guard let trackerID = cell.id else {
            return
        }
        
        if !cell.addButton.isSelected {
            TrackerRecordManager.shared.addTrackerRecord(id: trackerID, date: currentDate)
            cell.addButton.isSelected = true
        } else {
            TrackerRecordManager.shared.removeTrackerRecord(id: trackerID, date: currentDate)
            cell.addButton.isSelected = false
        }
        trackersCollectionView.reloadData()
    }
    
    
    private func isTrackerCompleted(_ trackerID: UUID, date: Date) -> Bool {
        return TrackerRecordManager.shared.getTrackerRecords().contains(where: { $0.id == trackerID && Calendar.current.isDate($0.date, inSameDayAs: date) })
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
        // print ("Обрабатывает дату \(currentDate)")
        let weekday = Calendar.current.component(.weekday, from: currentDate)
//        visibleTrackerCategories = TrackerCategoryManager.shared.trackerCategories.filter { category in
//            category.trackers.contains { tracker in
//                tracker.schedule.contains(weekday) || tracker.type == .unregularEvent
//            }
//        }
        
        checkEmptyState()
        
        if visibleTrackerCategories.isEmpty {
            trackersCollectionView.reloadData()
            return
        }
        
//        for category in visibleTrackerCategories {
//            for tracker in category.trackers {
//                guard let cell = findCell(for: tracker) else {
//                    continue
//                }
//                //      print(cell)
//            }
//        }
        
        trackersCollectionView.reloadData()
    }
    
    private func findCell(for tracker: Tracker) -> TrackerCell? {
        for section in 0..<trackersCollectionView.numberOfSections {
            for item in 0..<trackersCollectionView.numberOfItems(inSection: section) {
                if let cell = trackersCollectionView.cellForItem(at: IndexPath(item: item, section: section)) as? TrackerCell, cell.id == tracker.id {
                    return cell
                }
            }
        }
        return nil
    }
    
}




