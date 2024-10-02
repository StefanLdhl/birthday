//
//  String+Localize.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import UIKit

public extension String {
    func localize(values arguments: CVarArg...) -> String {
        return "\(String(format: NSLocalizedString(self, comment: ""), arguments: arguments))"
    }

    func localize() -> String {
        
        let returnString = "\(NSLocalizedString(self, comment: ""))"
        if returnString == self {
            return "-"
        }
        return "\(NSLocalizedString(self, comment: ""))"
    }
}
