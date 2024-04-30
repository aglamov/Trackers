//
//  SelectCreateTrackerViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 23.01.2024.

import Foundation
import UIKit

class TrackerCreationViewController: UIViewController {
    let titleLabel = UILabel()
    let habitButton = UIButton()
    let eventButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        titleLabel.text = "Создание трекера"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.backgroundColor = .black
        habitButton.setTitleColor(.white, for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)

        habitButton.translatesAutoresizingMaskIntoConstraints = false
        habitButton.layer.cornerRadius = 16
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        view.addSubview(habitButton)
        
        eventButton.setTitle("Нерегулярное событие", for: .normal)
        eventButton.backgroundColor = .black
        eventButton.setTitleColor(.white, for: .normal)
        eventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        eventButton.translatesAutoresizingMaskIntoConstraints = false
        eventButton.layer.cornerRadius = 16
        eventButton.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        view.addSubview(eventButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        habitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        eventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 24).isActive = true
        eventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        eventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        eventButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc func habitButtonTapped() {
        let trackerCreation = TrackerCreationExtendedViewController(selectedType: TrackerType.habit)
        let navController = UINavigationController(rootViewController: trackerCreation)
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc func eventButtonTapped() {
        let trackerCreation = TrackerCreationExtendedViewController(selectedType: TrackerType.unregularEvent)
        let navController = UINavigationController(rootViewController: trackerCreation)
        navController.modalPresentationStyle = .fullScreen
        navigationController?.present(navController, animated: true, completion: nil)
    }
}
