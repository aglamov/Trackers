//
//  TrackerCell.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 04.02.2024.

import Foundation
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func doneButtonTapped(in cell: TrackerCell)
}

class TrackerCell: UICollectionViewCell {
  //  weak var delegate: TrackersViewControllerProtocol?
    weak var delegate: TrackerCellDelegate?
    var id: UUID?
    var currentDate: Date?
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
      //  view.backgroundColor = .yGreen
        view.layer.cornerRadius = 10
        return view
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
        button.tintColor = .yGreen
        
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
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
            // Проверяем, является ли текущая дата будущей
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
