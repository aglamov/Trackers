//
//  TrackerCell.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 04.02.2024.

import Foundation
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func doneButtonTapped(in cell: TrackerCell)
    func isPinned(for cell: TrackerCell) -> Bool
    func editMenuItemTapped(for cell: TrackerCell)
}

class TrackerCell: UICollectionViewCell {
    weak var delegate: TrackerCellDelegate?
    weak var presenter: TrackersPresenterProtocol?
    var id: UUID?
    var currentDate: Date?
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    let containerEmoji: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        return view
    }()
    
    let emoji: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
        label.text = "0 дней"
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.backgroundColor = .white
        let configuration = UIImage.SymbolConfiguration(pointSize: 24)
        let checkmarkImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: configuration)
        let preCheckmarkImage = UIImage(systemName: "plus.circle.fill", withConfiguration: configuration)
        button.setImage(checkmarkImage, for: .selected)
        button.setImage(preCheckmarkImage, for: .normal)
        
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(addButton)
        containerView.addSubview(containerEmoji)
        containerEmoji.addSubview(emoji)
        let interaction = UIContextMenuInteraction(delegate: self)
        containerView.addInteraction(interaction)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            containerEmoji.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            containerEmoji.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            containerEmoji.heightAnchor.constraint(equalToConstant: 24),
            containerEmoji.widthAnchor.constraint(equalToConstant: 24),
            
            emoji.centerXAnchor.constraint(equalTo: containerEmoji.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: containerEmoji.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8),
            
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            addButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 12),
            addButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateButtonAvailability(for date: Date) {
        if date > Date() {
            addButton.isEnabled = false
        } else {
            addButton.isEnabled = true
        }
    }
    
    @objc func doneButtonTapped(_ sender: UIButton) {
        delegate?.doneButtonTapped(in: self)
    }
}

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = NSUUID()
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            var pinAction: UIAction
            let isPinned = self.delegate?.isPinned(for: self) ?? false
            if isPinned {
                pinAction = UIAction(title: "Открепить", image: UIImage(systemName: "pin.slash")) { _ in
                    self.unpinMenuItemTapped(for: self)
                }
            } else {
                pinAction = UIAction(title: "Закрепить", image: UIImage(systemName: "pin")) { _ in
                    self.pinMenuItemTapped(for: self)
                }
            }
            
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.editMenuItemTapped()
            }
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    self.deleteMenuItemTapped(for: self)
                }
                alertController.addAction(deleteAction)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                if let viewController = self.delegate as? UIViewController {
                    viewController.present(alertController, animated: true, completion: nil)
                }
            }
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    private func pinMenuItemTapped(for cell: TrackerCell) {
        let trackerStore = TrackerStore()
        let categoryStore = TrackerCategoryStore.shared
        
        guard let trackerID = cell.id else {
            return
        }
        
        guard let tracker = trackerStore.fetchTracker(with: trackerID) else {
            return
        }
        
        guard let pinCategory = categoryStore.fetchCategory(with: "Закрепленные") else {
            return
        }
        if let originalCategory =  tracker.trackerCategorys as? TrackersCategoryCoreData {
            tracker.isPinned = true
            tracker.originalCategoryID = originalCategory.id
            tracker.trackerCategorys = pinCategory
            trackerStore.save()
        }
        else {
            print("Original category not found or is not of the expected type.")
        }
    }
        
    private func unpinMenuItemTapped(for cell: TrackerCell) {
        let categoryStore = TrackerCategoryStore.shared
        let trackerStore = TrackerStore()
        
        guard let trackerID = cell.id else {
            return
        }
        
        guard let tracker = trackerStore.fetchTracker(with: trackerID) else {return}
        
        guard let originalCategoryID = tracker.originalCategoryID else {return}
        guard let originCategory = categoryStore.fetchCategoryID(with: originalCategoryID) else {return}
       
        tracker.trackerCategorys = originCategory
        tracker.isPinned = false
        trackerStore.save()
    }
    
    private func editMenuItemTapped() {
        delegate?.editMenuItemTapped(for: self)
    }
    
    private func deleteMenuItemTapped(for cell: TrackerCell) {
        guard let trackerID = self.id else { return }
        presenter?.removeButtonTapped(trackerID: trackerID)
    }
}
