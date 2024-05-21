//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 17.12.2023.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyStatistics")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Анализировать пока нечего?"
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.sizeToFit()
        return label
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatisticsScreen()
        checkEmptyState()
    }
    
    // MARK: - Setup Methods
    
    private func setupStatisticsScreen() {
        view.backgroundColor = UIColor.systemBackground
        setupNavigationBar()
        addSubviews()
        constraintSubviews()
    }
    
    private func setupNavigationBar() {
        let titleBarButton = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = titleBarButton
    }
    
    private func addSubviews() {
        view.addSubview(emptyScreenView)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyScreenText.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Helper Methods
    
    private func checkEmptyState() {
        emptyScreenImage.isHidden = false
        emptyScreenText.isHidden = false
    }
}
