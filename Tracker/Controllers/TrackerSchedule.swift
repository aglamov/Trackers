//
//  TrackerSchedule.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 29.01.2024.

import Foundation
import UIKit

protocol TrackerScheduleDelegate: AnyObject {
    func didUpdateSelectedWeekdays(_ selectedWeekdays: [(String, Int)])
}

final class TrackerSchedule: UIViewController, UITableViewDataSource, UITableViewDelegate, TrackerScheduleDelegate  {
    
    let weekdays: [(String, String, Int)] = [
        ("Понедельник", "Пн", 2),
        ("Вторник", "Вт", 3),
        ("Среда", "Ср", 4),
        ("Четверг", "Чт", 5),
        ("Пятница", "Пт", 6),
        ("Суббота", "Сб", 7),
        ("Воскресенье", "Вс", 1)
    ]
    
    var selectedWeekdays: [(String, Int)] = []
    weak var delegate: TrackerScheduleDelegate?
    
    func didUpdateSelectedWeekdays(_ selectedWeekdays: [(String, Int)]) {
        delegate?.didUpdateSelectedWeekdays(selectedWeekdays)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let weekday = weekdays[indexPath.row]
        cell.textLabel?.text = weekday.0
        let switchView = UISwitch(frame: .zero)
       
        let isSelected = selectedWeekdays.contains { $0.1 == weekday.2 }
        switchView.setOn(isSelected, animated: false)
        switchView.tag = indexPath.row
        switchView.onTintColor = .yBlue
        cell.accessoryView = switchView
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return cell
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .yBackground
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var setupTableView: UITableView = {
        let planningTableView = UITableView(frame: .zero, style: .insetGrouped)
        planningTableView.translatesAutoresizingMaskIntoConstraints = false
        planningTableView.separatorStyle = .singleLine
        planningTableView.contentInsetAdjustmentBehavior = .never
        planningTableView.backgroundColor = .white
        planningTableView.isScrollEnabled = true
        planningTableView.showsVerticalScrollIndicator = false
        planningTableView.dataSource = self
        planningTableView.delegate = self
        planningTableView.allowsSelection = true
        
        return planningTableView
    }()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(setupTableView)
        view.addSubview(saveButton)
        setupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setupConstraints()
    }
    
    func setupConstraints() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        setupTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        setupTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        setupTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        setupTableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -5).isActive = true
        
        saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc func saveButtonTapped() {
        selectedWeekdays = []
        for (index, day) in weekdays.enumerated() {
                if let cell = setupTableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                    if let switchView = cell.accessoryView as? UISwitch, switchView.isOn {
                        let tuple = (day.1, day.2)
                        selectedWeekdays.append(tuple)
                    }
                }
            }
        
        delegate?.didUpdateSelectedWeekdays(selectedWeekdays)
        dismiss(animated: true, completion: nil)
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        
    }
}

