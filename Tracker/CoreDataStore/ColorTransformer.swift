//
//  ColorTransformer.swift
//  Tracker
//
//  Created by Рамиль Аглямов on 05.04.2024.
//

import UIKit
import CoreData

@objc(ColorTransformer)
class ColorTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: ColorTransformer.self))
    
    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }
    
    public static func register() {
        let transformer = ColorTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
