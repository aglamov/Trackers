//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 23.04.2024.
//

import Foundation
import UIKit

class OnboardingViewController: UIViewController {
    
    var labelText: String?
    var imageName: String?
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.numberOfLines = 0
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitle("Вот это технологии!", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(button)
        view.addSubview(label)
        
        label.text = labelText
        
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func buttonTapped() {
        UserDefaults.standard.set(true, forKey: "OnboardingSkipped")
        let tabBarViewController = TabBarController()
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.pushViewController(tabBarViewController, animated: true)
        }
}


