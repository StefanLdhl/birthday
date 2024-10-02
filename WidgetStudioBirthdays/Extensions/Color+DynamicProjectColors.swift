//
//  Color+DynamicProjectColors.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 18.01.21.
//

import SwiftUI
import UIKit

extension Color {
    static func defaultWidgetBackgroundColor() -> Color {
        let backgroundStyleId = GroupedUserDefaults.integer(forKey: .localUserInfo_backgroundStyleId)

        if backgroundStyleId == 0 {
            return Color("widgetDefaultBackground")
        }

        if backgroundStyleId == 1 {
            return Color("widgetDefaultBackgroundLight")
        }

        if backgroundStyleId == 2 {
            return Color("widgetDefaultBackgroundDark")
        }

        return Color("widgetDefaultBackground")
    }

    static func defaultWidgetFontColor() -> Color {
        let backgroundStyleId = GroupedUserDefaults.integer(forKey: .localUserInfo_backgroundStyleId)

        if backgroundStyleId == 0 {
            return Color("widgetDefaultFontColor")
        }

        if backgroundStyleId == 1 {
            return Color("widgetDefaultFontColorLight")
        }

        if backgroundStyleId == 2 {
            return Color("widgetDefaultFontColorDark")
        }

        return Color("widgetDefaultFontColor")
    }
}
