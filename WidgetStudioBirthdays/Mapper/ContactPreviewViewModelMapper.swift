//
//  ContactPreviewViewModelMapper.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import Contacts
import Foundation
import SwiftDate
import UIKit

class ContactPreviewViewModelMapper {
    public func map(contact: CNContact) -> ContactPreviewViewModel? {
        // Birtday
        guard let birthday = contact.birthday?.date else {
            return nil
        }

        // Anniversary and possibly other dates later
        var anniversary: Date?
        for dateLabel in contact.dates {
            if dateLabel.label?.contains("Anniversary") == true, let anniversaryDate = Date(components: dateLabel.value as DateComponents, region: Region.ISO) {
                anniversary = anniversaryDate
            }
        }

        // Name & ID
        var firstName = contact.givenName
        let lastName = contact.familyName
        let contactId = contact.identifier
        let organizationName = contact.organizationName

        // If no name is given, use company as first name
        if firstName.count <= 0 && lastName.count <= 0 {
            firstName = organizationName
        }

        guard firstName.count > 0 || lastName.count > 0 else {
            return nil
        }

        // Pic
        var picture: UIImage?
        if let pictureData = contact.thumbnailImageData, let profilePicture = UIImage(data: pictureData) {
            picture = profilePicture.resizeToSquare(sideLength: 50)
        }

        return ContactPreviewViewModel(birthday: birthday,
                                       anniversary: anniversary,
                                       firstName: firstName,
                                       lastName: lastName,
                                       picture: picture,
                                       cnContactId: contactId)
    }
}
