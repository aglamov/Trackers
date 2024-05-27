//
//  TrackerEditViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 30.04.2024.
//

import UIKit

class TrackerEditViewController: TrackerCreationExtendedViewController {
    
    var trackerToEdit: TrackersCoreData
    
    init(tracker: TrackersCoreData) {
        self.trackerToEdit = tracker
        let trackerType: TrackerType = tracker.typeTracker == 0 ? .habit : .unregularEvent
        super.init(selectedType: trackerType)
        self.selectedCategory = tracker.trackerCategorys?.name ?? ""
        if let scheduleData = tracker.schedule as? Data {
            do {
                if let decodedSchedule = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scheduleData) as? [Int] {
                    selectedIndexes = decodedSchedule
                    let trackerSchedule = TrackerSchedule()
                    let selectedWeekdays = decodedSchedule.compactMap { index in
                        trackerSchedule.weekdays.first { $0.2 == index }?.1
                    }
                    selectedDays = selectedWeekdays.joined(separator: ", ")
                } else {
                    print("Ошибка: не удалось декодировать расписание как массив [Int]")
                }
            } catch {
                print("Ошибка при декодировании расписания: \(error)")
            }
        }
        
        if let trackerEmoji = tracker.emoji, let emojiIndex = emojis.firstIndex(of: trackerEmoji) {
            selectedEmojiIndexPath = IndexPath(item: emojiIndex, section: 0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Редактирование привычки"
        trackerNameTextField.text = trackerToEdit.name
        saveButton.setTitle("Сохранить", for: .normal)
        setupTableView.delegate = self
        setupTableView.dataSource = self
        
        if let trackerEmoji = trackerToEdit.emoji, let emojiIndex = emojis.firstIndex(of: trackerEmoji) {
            selectedEmojiIndexPath = IndexPath(item: emojiIndex, section: 0)
        }
        
        if let trackerColor = trackerToEdit.color as? UIColor, let colorIndex = colors.firstIndex(of: trackerColor) {
            selectedColorIndexPath = IndexPath(item: colorIndex, section: 0)
        }
        
        if let emojiIndexPath = selectedEmojiIndexPath {
            emojiCollectionView.selectItem(at: emojiIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        
        if let colorIndexPath = selectedColorIndexPath {
            colorCollectionView.selectItem(at: colorIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        updateSaveButtonAvailability()
    }
    
    override func saveButtonTapped() {
        trackerToEdit.name = trackerNameTextField.text ?? ""
        if let selectedEmojiIndexPath = selectedEmojiIndexPath {
            trackerToEdit.emoji = emojis[selectedEmojiIndexPath.item]
        }
        
        if let selectedColorIndexPath = selectedColorIndexPath {
            trackerToEdit.color = colors[selectedColorIndexPath.item] as NSObject
        }
        
        let updatedSchedule = selectedIndexes
        do {
            let scheduleData = try NSKeyedArchiver.archivedData(withRootObject: updatedSchedule, requiringSecureCoding: false)
            trackerToEdit.schedule = scheduleData as NSObject
        } catch {
            print("Ошибка при сохранении расписания: \(error)")
        }
    
        let categoryStore = TrackerCategoryStore.shared

        if let existingCategory = categoryStore.fetchCategory(with: selectedCategory) {
            existingCategory.addToTrackers(trackerToEdit)
            trackerToEdit.trackerCategorys = existingCategory
        } else {
            categoryStore.createCategory(name: selectedCategory, tracker: trackerToEdit)
        }
        
        do {
            try trackerToEdit.managedObjectContext?.save()
        } catch {
            print("Ошибка при сохранении изменений в базе данных: \(error)")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func cancelButtonTapped() {
        super.cancelButtonTapped()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        
        if collectionView == emojiCollectionView {
            if indexPath == selectedEmojiIndexPath {
                cell.backgroundColor = .yLightGray
                cell.layer.cornerRadius = 8.0
                selectedEmojiIndexPath = indexPath
            } else {
                cell.layer.borderWidth = 0.0
                cell.backgroundColor = .clear
            }
        } else if collectionView == colorCollectionView {
            if indexPath == selectedColorIndexPath {
                cell.layer.borderWidth = 3.0
                cell.layer.borderColor = colors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.layer.cornerRadius = 10.0
                selectedColorIndexPath = indexPath
            } else {
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        collectionView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            super.categoryButtonTapped()
        } else if indexPath.row == 1 {
            super.scheduleButtonTapped()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
