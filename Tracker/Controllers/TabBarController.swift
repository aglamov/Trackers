//
//  TabBurController.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 17.12.2023.

import Foundation

import UIKit

class TabBarController: UITabBarController {
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureTabBarController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let shared = TabBarController() 
    
    private func configureTabBarController() {
        let trackers = TrackersViewController()
        let statistics = StatisticsViewController()
        
        view.backgroundColor = .white
        
        trackers.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "Trackers"), tag: 0)
        statistics.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "Statistics"), tag: 1)
        
        let trackersNav = UINavigationController(rootViewController: trackers)
        let statisticsNav = UINavigationController(rootViewController: statistics)

        viewControllers = [trackersNav, statisticsNav]
        
        let lineView = UIView(frame: CGRect(x: 0, y: -5, width: tabBar.frame.width, height: 0.5))
        lineView.backgroundColor = UIColor.gray 
        tabBar.addSubview(lineView)
    }
}
