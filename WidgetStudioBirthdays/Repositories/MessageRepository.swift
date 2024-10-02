//
//  MessageRepository.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.01.21.
//

import CoreData
import Foundation
import UIKit

class MessageRepository {
    public static func getAllMessages(predicate: NSPredicate? = nil) -> [Message] {
        let request = Message.fetchRequest() as NSFetchRequest<Message>

        if let predicateToSet = predicate {
            request.predicate = predicateToSet
        }

        do {
            let result = try CoreDataStack.defaultStack.managedObjectContext.fetch(request) as [Message]
            let shoudlCheckForDuplicates = GroupedUserDefaults.bool(forKey: .localUserInfo_iCloudActivated)
            return shoudlCheckForDuplicates ? removePossibleDuplicates(messages: result) : result

        } catch {
            print("Failed")
        }

        return []
    }

    static func addNewLocalizableMessage(title: String, content: String, isDefault: Bool = false, identifier: String? = nil, group: Group? = nil) -> Message {
        let newMessage = Message(context: CoreDataStack.defaultStack.managedObjectContext)

        newMessage.title = title
        newMessage.content = content
        newMessage.identifier = identifier ?? createUniqueMessageId()
        newMessage.creationDate = Date()
        newMessage.isDefault = isDefault
        newMessage.lastChangeDate = Date()
        newMessage.group = group
        newMessage.localizable = true

        CoreDataStack.defaultStack.saveContext()

        return newMessage
    }

    public static func getMessagebyId(identifier: String) -> Message? {
        return getAllMessages(predicate: NSPredicate(format: "identifier == %@", identifier)).first
    }

    private static func resetIsDefaultValueForOtherEntriesExcept(exceptId: String) {
        let allMessages = getAllMessages(predicate: NSPredicate(format: "identifier != %@", exceptId))

        for message in allMessages {
            message.isDefault = false
        }
    }

    private static func removePossibleDuplicates(messages: [Message]) -> [Message] {
        var checkeMessages: [Message] = []
        var somethingChanged = false

        for message in messages.sorted(by: { $0.creationDate ?? Date() < $1.creationDate ?? Date() }) {
            if checkeMessages.map({ $0.identifier }).contains(message.identifier ?? "") {
                CoreDataStack.defaultStack.managedObjectContext.delete(message)
                somethingChanged = true
            } else {
                checkeMessages.append(message)
            }
        }
        if somethingChanged {
            CoreDataStack.defaultStack.saveContext()
        }

        return checkeMessages
    }

    public static func updateFromViewModel(messageViewModel: MessagesViewModel) -> Message? {
        var existingMessage = getMessagebyId(identifier: messageViewModel.identifier)

        if existingMessage == nil, messageViewModel.identifier == "new" {
            AppUsageCounter.logEventFor(type: .newMessageTemplate)
            existingMessage = Message(context: CoreDataStack.defaultStack.managedObjectContext)
            existingMessage?.identifier = createUniqueMessageId()
            existingMessage?.creationDate = Date()
        }

        guard let validMessage = existingMessage else {
            return nil
        }

        if !messageViewModel.localizable {
            validMessage.content = messageViewModel.content
            validMessage.title = messageViewModel.title
        }

        validMessage.lastChangeDate = Date()
        validMessage.isDefault = messageViewModel.isDefault
        validMessage.localizable = messageViewModel.localizable

        if validMessage.isDefault {
            resetIsDefaultValueForOtherEntriesExcept(exceptId: validMessage.identifier ?? "")
        }

        CoreDataStack.defaultStack.saveContext()

        return existingMessage
    }

    static func deleteMessage(identifier: String) {
        guard let existingMessage = getAllMessages(predicate: NSPredicate(format: "identifier == %@", identifier)).first else {
            return
        }

        CoreDataStack.defaultStack.managedObjectContext.delete(existingMessage)
        CoreDataStack.defaultStack.saveContext()
    }

    private static func createUniqueMessageId() -> String {
        return "message_\(UUID().uuidString)"
    }

    /// Gibt alle Daten als Dictionary zurück.
    static func getAllDataAsDictionary() -> [[String: String]] {
        let allMessages = getAllMessages()
        var rmessageDictArray: [[String: String]] = []

        for group in allMessages {
            rmessageDictArray.append(group.asDictionary())
        }

        return rmessageDictArray
    }
}
