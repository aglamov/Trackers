//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 20.05.2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    // Функция для отправки события
    private func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = ["event": event, "screen": screen]
        if let item = item {
            params["item"] = item
        }
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    // Функция для события открытия экрана
    func reportScreenOpen(screen: String) {
        report(event: "open", screen: screen)
    }

    // Функция для события закрытия экрана
    func reportScreenClose(screen: String) {
        report(event: "close", screen: screen)
    }

    // Функция для события тапа на кнопку
    func reportButtonClick(screen: String, item: String) {
        report(event: "click", screen: screen, item: item)
    }
}
