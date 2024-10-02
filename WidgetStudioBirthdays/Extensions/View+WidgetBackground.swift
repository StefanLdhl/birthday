//
//  View+WidgetBackground.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan on 13.09.23.
//

import SwiftUI
import WidgetKit

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
