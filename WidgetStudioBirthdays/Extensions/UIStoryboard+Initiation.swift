//
//  UIStoryboard+Initiation.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import UIKit

enum StoryboardTypes: String {
    case main = "Main"
    case options = "Options"
    case purchases = "Purchases"
    case eventImport = "Import"
    case groups = "Groups"
    case messages = "Messages"
    case fileImport = "FileImport"
    case calendarImport = "CalendarImport"
}

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T? {
        if let name = NSStringFromClass(T.self).components(separatedBy: ".").last {
            return instantiateViewController(withIdentifier: name) as? T

        } else {
            return nil
        }
    }

    convenience init(type: StoryboardTypes) {
        self.init(name: type.rawValue, bundle: nil)
    }
}
