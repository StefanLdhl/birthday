//
//  BirthdayInfoViewModel.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import SwiftDate
import UIKit

struct BirthdayInfoViewModel {
    var identifier: String
    var firstName: String
    var lastName: String
    var notificationsMuted: Bool = false

    var birthdateInYear: Date
    var birthdate: Date {
        didSet {
            birthdateInYear = birthdate.dateWithTodaysYear
            birthdayIsToday = DateInRegion(birthdateInYear, region: .current).isToday
            daysLeftToBirthday = getDaysLeftToBirthday()
            birthdayType = getBirthdayType()
            nextAgeBirthdayType = getBirthdayType(forNextBirthday: true)
        }
    }

    var creationDate: Date

    var birthdayIsToday: Bool
    var daysLeftToBirthday: Int
    var birthdayType: BirthdayType = .normal
    var nextAgeBirthdayType: BirthdayType = .normal

    var group: GroupViewModel

    var currentAge: Int? {
        return birthdate.year > 1 ? Date.yearsSinceDate(birthdate: birthdate) : nil
    }

    var initials: String? {
        return NamesCreator.createInitials(for: firstName, lastName: lastName)
    }

    var profilePicture: UIImage?
    var pictureCnOverriden: Bool = false

    init(identifier: String, firstName: String, lastName: String, birthday: Date, group: GroupViewModel?, creationDate: Date) {
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        birthdate = birthday
        birthdateInYear = birthday.dateWithTodaysYear
        self.group = group ?? GroupViewModel.getFallbackGroupViewModel()
        birthdayIsToday = DateInRegion(birthdateInYear, region: .current).isToday
        self.creationDate = creationDate

        daysLeftToBirthday = 999
        daysLeftToBirthday = getDaysLeftToBirthday()
        birthdayType = getBirthdayType()
        nextAgeBirthdayType = getBirthdayType(forNextBirthday: true)
    }

    private func getDaysLeftToBirthday() -> Int {
        let birthdate = DateInRegion(birthdateInYear, region: .current)
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: DateInRegion(Date(), region: .current).date)
        let date2 = calendar.startOfDay(for: birthdate.date)
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }

    private func getBirthdayType(forNextBirthday: Bool = false) -> BirthdayType {
        guard var age = currentAge else {
            return .normal
        }

        age = forNextBirthday ? (age + 1) : age

        if [18, 21].contains(age) {
            return .special
        }

        if [1].contains(age) {
            return .first
        }

        if [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120].contains(age) {
            return .round
        }

        return .normal
    }

    /// Lädt Profilbild nachträglich
    public mutating func fetchProfilePic() {
        profilePicture = PictureRepository.getOriginalPictureFromBirthday(birthdayIdentifier: identifier)
    }

    init(identifier: String, name: String) {
        self.init(identifier: identifier, firstName: name, lastName: name, birthday: Date(), group: GroupViewModel(identifier: "Preview"), creationDate: Date())
    }
}

public enum BirthdayType {
    case normal
    case round
    case special
    case first

    public func imageName() -> String {
        switch self {
        case .normal:
            return "BirthdayStar"
        case .round:
            return "MilestoneStarRound"
        case .special:
            return "MilestoneStarSpecial"
        case .first:
            return "MilestoneStarFirst"
        }
    }
}

extension BirthdayInfoViewModel: Identifiable, Hashable, Equatable {
    var id: String { identifier }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BirthdayInfoViewModel, rhs: BirthdayInfoViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
