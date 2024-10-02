//
//  Collection+SafeIndex.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.

import Foundation
import UIKit

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
