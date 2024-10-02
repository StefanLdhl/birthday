//
//  View+GradientForeground.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 30.11.20.
//

import Foundation
import SwiftUI

extension View {
    public func gradientMask(gradient: LinearGradient) -> some View {
        overlay(gradient)
            .mask(self)
    }

    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            return AnyView(content(self))
        } else {
            return AnyView(self)
        }
    }
}
