//
//  PictureRepository.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 16.02.21.
//

import CoreData
import Foundation
import UIKit

class PictureRepository {
    /// Lädt alle Bilder aus der Datenbank
    static func getAllPictures(predicate: NSPredicate? = nil) -> [Picture] {
        let request = Picture.fetchRequest() as NSFetchRequest<Picture>

        if let predicateToSet = predicate {
            request.predicate = predicateToSet
        }

        do {
            // CoreDataStack.defaultStack.managedObjectContext.reset()
            let result = try CoreDataStack.defaultStack.managedObjectContext.fetch(request) as [Picture]

            return result

        } catch {
            print("Failed")
        }

        return []
    }

    /// Erstellt ein neuen Datenbankeintrag und legt die Geburtstags ID im Bild ab
    public static func createNewPictureForBirthday(pictureData: Data?, birthday: Birthday) {
        guard let picData = pictureData, let birthdayIdentifier = birthday.identifier else {
            return
        }

        let newPicture = Picture(context: CoreDataStack.defaultStack.managedObjectContext)

        newPicture.identifier = createUniquePicId()
        newPicture.creationDate = Date()
        newPicture.pictureData = picData
        newPicture.picCategory = "birthday"
        newPicture.birthdayIdentifier = birthdayIdentifier
        CoreDataStack.defaultStack.saveContext()
    }

    /// Aktualisiert das Bild für den eingehenden Geburtstag. Entweder neu anlegen oder aktualisieren.
    public static func updatePictureForBirthday(birthday: Birthday, pictureData: Data?) {
        guard let validPictureData = pictureData else {
            deletePicturesForBirthday(birthday: birthday)
            return
        }

        if let existingPicture = getPictureForBirthday(birthdayIdentifier: birthday.identifier) {
            guard existingPicture.pictureData != validPictureData else {
                return
            }

            existingPicture.pictureData = validPictureData
            CoreDataStack.defaultStack.saveContext()

        } else {
            createNewPictureForBirthday(pictureData: pictureData, birthday: birthday)
        }
    }

    /// Überladung, um alternativ auch ein UIImage übergeben zu können
    public static func updatePictureForBirthday(birthday: Birthday, picture: UIImage?) {
        var pictureData: Data?

        if let validPicture = picture?.resizeToSquare(sideLength: 50) {
            pictureData = validPicture.pngData()
        }

        updatePictureForBirthday(birthday: birthday, pictureData: pictureData)
    }

    /// Löscht das Bild eines Geburtstags
    public static func deletePicturesForBirthday(birthday: Birthday) {
        for picture in getAllPicturesForBirthday(birthdayIdentifier: birthday.identifier) {
            deletePicture(picture: picture)
        }
    }

    /// Löscht doppelte Bilder (2x die selbe Birthaday ID verknüpft)
    public static func cleanDuplicatePictures() {
        let allPictures = getAllPictures()

        var uniquePictureBirthdayIds = [String]()
        for picture in allPictures {
            if uniquePictureBirthdayIds.contains(where: { $0 == picture.birthdayIdentifier }) {
                deletePicture(picture: picture)
            } else if let birthdayId = picture.birthdayIdentifier {
                uniquePictureBirthdayIds.append(birthdayId)
            }
        }
    }

    public static func deletePicture(picture: Picture) {
        CoreDataStack.defaultStack.managedObjectContext.delete(picture)
        CoreDataStack.defaultStack.saveContext()
    }

    /// Gibt das Bild anhand der eigenen ID zurück
    public static func getPictureById(identifier: String) -> Picture? {
        return getAllPictures(predicate: NSPredicate(format: "identifier == %@", identifier)).first
    }

    /// Gibt das Bild anhand der Geburtstags ID zurück
    public static func getPictureForBirthday(birthdayIdentifier: String?) -> Picture? {
        guard let identifier = birthdayIdentifier else {
            return nil
        }

        return getAllPictures(predicate: NSPredicate(format: "birthdayIdentifier == %@", identifier)).first
    }

    /// Gibt alle Bilder anhand der Geburtstags ID zurück (Falls doppelte existieren)
    public static func getAllPicturesForBirthday(birthdayIdentifier: String?) -> [Picture] {
        guard let identifier = birthdayIdentifier else {
            return []
        }

        return getAllPictures(predicate: NSPredicate(format: "birthdayIdentifier == %@", identifier))
    }

    public static func getOriginalPictureFromBirthday(birthdayIdentifier: String?) -> UIImage? {
        guard let picture = getPictureForBirthday(birthdayIdentifier: birthdayIdentifier) else {
            return nil
        }

        guard let picData = picture.pictureData else {
            return nil
        }

        return UIImage(data: picData)
    }

    private static func createUniquePicId() -> String {
        return "pic_\(UUID().uuidString)"
    }
}
