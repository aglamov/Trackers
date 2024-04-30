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
            if tracker.typeTracker == 0 {
                super.init(selectedType: .habit)
            } else {
                super.init(selectedType: .unregularEvent) 
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
//        if let emojiIndex = emojis.firstIndex(of: trackerToEdit.emoji!) {
//            let indexPath = IndexPath(item: emojiIndex, section: 0)
//            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
//            selectedEmojiIndexPath = indexPath
//        }
//        if let colorIndex = colors.firstIndex(of: trackerToEdit.color as! UIColor) {
//            let indexPath = IndexPath(item: colorIndex, section: 0)
//            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
//            selectedColorIndexPath = indexPath
//        }
//        
//        if let color = trackerToEdit.color,
//           let colorIndex = colors.firstIndex(where: { $0 == color }) {
//            let indexPath = IndexPath(item: colorIndex, section: 0)
//            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
//            selectedColorIndexPath = indexPath
//        }
        updateSaveButtonAvailability()
    }
    
    override func saveButtonTapped() {
        // Логика сохранения обновленных данных трекера
//        trackerToEdit.name = trackerNameTextField.text ?? ""
//        trackerToEdit.color = colors[selectedColorIndexPath!.item]
//        trackerToEdit.emoji = emojis[selectedEmojiIndexPath!.item]
//        // Другие обновления данных...
//        
//        // Сохранение изменений в хранилище
//        trackerStore.updateTracker(trackerToEdit)
        
        // Возврат на предыдущий экран или выполнение других действий после сохранения
        navigationController?.popViewController(animated: true)
    }
    
    override func cancelButtonTapped() {
        // Дополнительные действия при нажатии кнопки отмены, если необходимо
        super.cancelButtonTapped() // Вызов родительского метода
    }
    
}
