//
//  ContactRefetcher.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 12.01.21.
//

import Contacts
import UIKit

class ContactRefechter {
    public static func refetchContactPictures() {
        guard AppUsageCounter.getLogCountFor(type: .contactImport) > 0, CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return
        }

        var rawContacts: [CNContact] = []

        DispatchQueue.global(qos: .background).async {
            let contactStore = CNContactStore()
            let keys = [CNContactThumbnailImageDataKey] as [CNKeyDescriptor]

            // Get all the containers
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }

            for container in allContainers {
                let containerPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

                do {
                    let containerResults = try contactStore.unifiedContacts(matching: containerPredicate, keysToFetch: keys)
                    rawContacts.append(contentsOf: containerResults)

                } catch {
                    print("Error fetching results for container")
                }
            }

            DispatchQueue.main.async {
                let allBirthdays = BirthdayRepository.getAllBirthdays(predicate: NSPredicate(format: "cnContactId != nil && pictureCnOverriden == false"))

                var changes = false
                for birthday in allBirthdays {
                    if let matchingContact = rawContacts.filter({ $0.identifier == birthday.cnContactId }).first, let imageData = matchingContact.thumbnailImageData, let image = UIImage(data: imageData) {
                        
                        PictureRepository.updatePictureForBirthday(birthday: birthday, picture: image)
                        changes = true
                    }
                }
                if changes {
                    CoreDataStack.defaultStack.saveContext()
                    NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)
                }
            }
        }
    }
}
