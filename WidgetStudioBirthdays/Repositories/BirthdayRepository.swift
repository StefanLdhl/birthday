//
//  BirthdayRepository.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import CoreData
import Foundation
import SwiftDate
import UIKit

class BirthdayRepository {
    static func getAllBirthdays(predicate: NSPredicate? = nil) -> [Birthday] {
        let request = Birthday.fetchRequest() as NSFetchRequest<Birthday>

        if let predicateToSet = predicate {
            request.predicate = predicateToSet
        }

        do {
            // CoreDataStack.defaultStack.managedObjectContext.reset()
            let result = try CoreDataStack.defaultStack.managedObjectContext.fetch(request) as [Birthday]

            // Migration
            for item in result {
                if item.picture != nil {
                    migrateProfilePictureToOwnEntity(birthday: item)
                }
            }

            // Überprüfen, ob doppelte Geburtstage exisitieren
            SessionState.shared.databaseHasPossibleDuplicateEntries = checkForDuplicateEntries(entries: result)

            return result

        } catch {
            print("Failed")
        }

        return []
    }

    static func getBirthdayById(identifier: String) -> Birthday? {
        return getAllBirthdays(predicate: NSPredicate(format: "identifier == %@", identifier)).first
    }

    public static func deleteBirthday(identifier: String) {
        guard let existingBirthday = getAllBirthdays(predicate: NSPredicate(format: "identifier == %@", identifier)).first else {
            return
        }

        deleteBirthday(birthday: existingBirthday)
    }

    public static func deleteBirthday(birthday: Birthday) {
        NotificationManager.removeRemindersForId(identifier: birthday.identifier ?? "")

        PictureRepository.deletePicturesForBirthday(birthday: birthday)

        CoreDataStack.defaultStack.managedObjectContext.delete(birthday)
        CoreDataStack.defaultStack.saveContext()
    }

    public static func addFromPreviews(previews: [ContactPreviewViewModel], group: GroupViewModel?) -> [Birthday] {
        var result: [Birthday] = []

        var groupToLink: Group?
        if let validGroupId = group?.identifier, let group = GroupRepository.getGroupbyId(identifier: validGroupId) {
            groupToLink = group
        }

        for preview in previews {
            result.append(addFromPreview(preview: preview, group: groupToLink))
        }

        CoreDataStack.defaultStack.saveContext()
        // CoreDataStack.defaultStack.managedObjectContext.reset()

        return result
    }

    public static func updateFromPreviews(previews: [ContactPreviewViewModel], group: GroupViewModel?) -> [Birthday] {
        var result: [Birthday] = []

        var groupToLink: Group?
        if let validGroupId = group?.identifier, let group = GroupRepository.getGroupbyId(identifier: validGroupId) {
            groupToLink = group
        }

        for preview in previews {
            if let updatedBirthday = updateFromPreview(preview: preview, group: groupToLink) {
                result.append(updatedBirthday)
            }
        }

        CoreDataStack.defaultStack.saveContext()

        return result
    }

    public static func updateFromViewModel(birthdayViewModel: BirthdayInfoViewModel) -> Birthday? {
        var existingBirthday = getAllBirthdays(predicate: NSPredicate(format: "identifier == %@", birthdayViewModel.identifier)).first

        if existingBirthday == nil, birthdayViewModel.identifier == "new" {
            AppUsageCounter.logEventFor(type: .newBirthday)
            existingBirthday = Birthday(context: CoreDataStack.defaultStack.managedObjectContext)
            existingBirthday?.identifier = createUniqueBirthdayId()
            existingBirthday?.creationDate = Date()
        }

        guard let validBirthday = existingBirthday else {
            return nil
        }

        validBirthday.birthdate = birthdayViewModel.birthdate
        validBirthday.firstName = birthdayViewModel.firstName
        validBirthday.lastName = birthdayViewModel.lastName
        validBirthday.lastChangeDate = Date()
        validBirthday.pictureCnOverriden = birthdayViewModel.pictureCnOverriden
        validBirthday.favorite = false
        validBirthday.memorialized = false

        // Refresh pic
        PictureRepository.updatePictureForBirthday(birthday: validBirthday, picture: birthdayViewModel.profilePicture)

        if let group = GroupRepository.getGroupbyId(identifier: birthdayViewModel.group.identifier) {
            validBirthday.group = group
        } else {
            validBirthday.group = nil
        }

        CoreDataStack.defaultStack.saveContext()

        return existingBirthday
    }

    private static func addFromPreview(preview: ContactPreviewViewModel, group: Group?) -> Birthday {
        let newBirthday = Birthday(context: CoreDataStack.defaultStack.managedObjectContext)

        newBirthday.identifier = createUniqueBirthdayId()
        newBirthday.firstName = preview.firstName
        newBirthday.lastName = preview.lastName
        newBirthday.birthdate = preview.birthday
        newBirthday.cnContactId = preview.cnContactId
        newBirthday.cnContactImportDate = Date()
        newBirthday.creationDate = Date()
        newBirthday.lastChangeDate = Date()
        newBirthday.group = group
        newBirthday.pictureCnOverriden = false

        // Refresh pic
        PictureRepository.updatePictureForBirthday(birthday: newBirthday, picture: preview.picture)

        CoreDataStack.defaultStack.saveContext()

        return newBirthday
    }

    private static func updateFromPreview(preview: ContactPreviewViewModel, group _: Group?) -> Birthday? {
        guard let existingBirthday = getAllBirthdays(predicate: NSPredicate(format: "cnContactId == %@", preview.cnContactId)).first else {
            return nil
        }

        existingBirthday.firstName = preview.firstName
        existingBirthday.lastName = preview.lastName
        existingBirthday.birthdate = preview.birthday
        existingBirthday.cnContactId = preview.cnContactId
        existingBirthday.lastChangeDate = Date()
        existingBirthday.cnContactImportDate = Date()
        existingBirthday.pictureCnOverriden = false

        // Refresh pic
        PictureRepository.updatePictureForBirthday(birthday: existingBirthday, picture: preview.picture)

        return existingBirthday
    }

    public static func addFromFileImportPreviews(previews: [FileImportContactPreviewViewModel], group: GroupViewModel?, fileName: String) -> [Birthday] {
        var result: [Birthday] = []

        var groupToLink: Group?
        if let validGroupId = group?.identifier, let group = GroupRepository.getGroupbyId(identifier: validGroupId) {
            groupToLink = group
        }

        for preview in previews {
            result.append(addFromFileImportPreview(preview: preview, group: groupToLink, fileName: fileName))
        }

        CoreDataStack.defaultStack.saveContext()

        return result
    }

    private static func addFromFileImportPreview(preview: FileImportContactPreviewViewModel, group: Group?, fileName: String) -> Birthday {
        let newBirthday = Birthday(context: CoreDataStack.defaultStack.managedObjectContext)

        newBirthday.identifier = createUniqueBirthdayId()
        newBirthday.firstName = preview.firstName
        newBirthday.lastName = preview.lastName
        newBirthday.birthdate = preview.birthday
        newBirthday.creationDate = Date()
        newBirthday.lastChangeDate = Date()
        newBirthday.group = group
        newBirthday.fileSource = fileName

        CoreDataStack.defaultStack.saveContext()

        return newBirthday
    }

    private static func createUniqueBirthdayId() -> String {
        return "birthday_\(UUID().uuidString)"
    }

    static func deleteAllBirthdays() {
        let birthdays = getAllBirthdays()

        for birthday in birthdays {
            PictureRepository.deletePicturesForBirthday(birthday: birthday)
            CoreDataStack.defaultStack.managedObjectContext.delete(birthday)
        }

        CoreDataStack.defaultStack.saveContext()
    }

    /// Gibt alle Daten als Dictionary zurück.
    static func getAllDataAsDictionary() -> (content: [[String: String]], imageData: [Data]) {
        let allEvents = getAllBirthdays()
        var eventDictArray: [[String: String]] = []
        var imageDataArray: [Data] = []

        for event in allEvents {
            eventDictArray.append(event.asDictionary())

            if let picture = PictureRepository.getPictureForBirthday(birthdayIdentifier: event.identifier), let imageData = picture.pictureData {
                imageDataArray.append(imageData)
            }
        }

        return (content: eventDictArray, imageData: imageDataArray)
    }

    /// Das direkt in der Entity Birthday gespeicherte Profilbild in eine eigene Entity verschieben und über die Beziehung "profilePicture" verknüpfen. Eimalig nötig.
    public static func migrateProfilePictureToOwnEntity(birthday: Birthday) {
        guard let originalPictureData = birthday.picture else {
            return
        }

        // Neues Bild anlegen
        PictureRepository.updatePictureForBirthday(birthday: birthday, pictureData: originalPictureData)

        // Altes im Model löschen
        birthday.picture = nil
        CoreDataStack.defaultStack.saveContext()
    }

    public static func checkForDuplicateEntries(entries: [Birthday]) -> Bool {
        return loadDuplicateBirthdays(birthdays: entries).count > 0
    }

    public static func getAllDuplicateBirthdays() -> [DuplicateBirthdays] {
        let birthdays = getAllBirthdays()
        return loadDuplicateBirthdays(birthdays: birthdays)
    }

    private static func loadDuplicateBirthdays(birthdays: [Birthday]) -> [DuplicateBirthdays] {
        let groupedBirthdays = Array(Dictionary(grouping: birthdays, by: { getUniqueComparisonValueForBirthday(birthday: $0) }).values)
        return groupedBirthdays.filter { $0.count > 1 }.map { DuplicateBirthdays(birthdays: $0) }
    }

    private static func getUniqueComparisonValueForBirthday(birthday: Birthday) -> String {
        return "\(birthday.firstName ?? "")\(birthday.lastName ?? "")\(birthday.birthdate?.toFormat("ddMMyyyy") ?? "")"
    }
}

public struct DuplicateBirthdays {
    var birthdays: [Birthday]
    var isSelected: Bool = true
}
