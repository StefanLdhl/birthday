//
//  BirthdayInfoViewModelMapper.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 22.11.20.
//

import UIKit

class BirthdayInfoViewModelMapper {
    public static func map(birthday: Birthday, includeImage: Bool = true) -> BirthdayInfoViewModel {
        var linkedGroup = GroupViewModel.getFallbackGroupViewModel()

        if let group = birthday.group {
            linkedGroup = GroupViewModel(group: group)
        }

        var birthdayVM = BirthdayInfoViewModel(identifier: birthday.identifier ?? "",
                                               firstName: birthday.firstName ?? "",
                                               lastName: birthday.lastName ?? "",
                                               birthday: birthday.birthdate ?? Date(),
                                               group: linkedGroup,
                                               creationDate: birthday.creationDate ?? Date())

        if includeImage, let pic = PictureRepository.getOriginalPictureFromBirthday(birthdayIdentifier: birthday.identifier) {
            birthdayVM.profilePicture = pic
        }

        birthdayVM.pictureCnOverriden = birthday.pictureCnOverriden

        return birthdayVM
    }
}
