//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 17.12.2023.

import UIKit

class StatisticsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleLabel = UILabel()
        titleLabel.text = "Статистика"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.sizeToFit()
        
        let titleBarButton = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = titleBarButton
    }
}
