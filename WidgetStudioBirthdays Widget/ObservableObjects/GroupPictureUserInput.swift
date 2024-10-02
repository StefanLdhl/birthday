//
//  ProfilePictureUserInput.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.11.20.
//

import Foundation
import SwiftUI
import WidgetKit

class GroupPictureUserInput: ObservableObject {
    @Published var color1: Color
    @Published var color2: Color

    init(color1: Color? = nil, color2: Color? = nil) {
        self.color1 = color1 ?? Color.clear
        self.color2 = color2 ?? Color.clear
    }
}
