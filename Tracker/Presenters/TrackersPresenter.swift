//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 17.12.2023.
//

import Foundation

protocol TrackersPresenterProtocol {
 //   var view: TrackersViewControllerProtocol? { get }
    var search: String { get set }
    var isEmpty: Bool { get }
}

final class TrackersPresenter: TrackersPresenterProtocol {
    var search: String = ""
    
  //  weak var view: TrackersViewControllerProtocol?
    
    
    var isEmpty: Bool {
        0 == 0
    }
}
