//
//  ProfilePictureUserInput.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.11.20.
//

import Foundation
import SwiftUI
import WidgetKit

class ProfilePictureUserInput: ObservableObject {
    @Published var profilePicture: UIImage? = nil
    @Published var initals: String? = nil
    @Published var color1: Color
    @Published var color2: Color
    @Published var fixedBorderWidth: CGFloat? = nil
    @Published var showShadow: Bool = false
    @Published var fixedSize: CGSize?

    init(profilePicture: UIImage?, initials: String?, color1: Color? = nil, color2: Color? = nil, shadow: Bool = false, fixedSize: CGSize? = nil) {
        self.profilePicture = profilePicture
        initals = initials

        self.color1 = color1 ?? Color.clear
        self.color2 = color2 ?? Color.clear
        self.showShadow = shadow
        self.fixedSize = fixedSize
    }
    
    
    init (birthdayInfo: BirthdayInfoViewModel, showShadow: Bool, fixedBorderWidth: CGFloat? = nil) {
        
        self.color1 = birthdayInfo.group.colorGradient.color1.color
        self.color2 = birthdayInfo.group.colorGradient.color2.color
        self.profilePicture = birthdayInfo.profilePicture
        self.initals = birthdayInfo.initials
        self.fixedBorderWidth = fixedBorderWidth
        self.showShadow = showShadow
    }
}
