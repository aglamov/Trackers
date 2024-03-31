//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 29.03.2024.
//

import Foundation
import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
    }
    
    func setupConstraints() {
        emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}

