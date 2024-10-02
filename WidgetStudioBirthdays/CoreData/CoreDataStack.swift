//
//  CoreDataStack.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import CloudKit
import CoreData
import UIKit
import WidgetKit

class CoreDataStack {
    // Singleton
    static let defaultStack = CoreDataStack()

    // ManagedObjectContext
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        return context
    }()

    lazy var persistentContainer: NSPersistentCloudKitContainer = setupContainer()

    private func setupContainer() -> NSPersistentCloudKitContainer {
        let isExtension = Bundle.main.bundlePath.hasSuffix(".appex")
        let iCloudActivated = !isExtension && GroupedUserDefaults.bool(forKey: .localUserInfo_iCloudActivated)

        let storeURL = URL.storeURL(for: "group.stefanliesendahl.widgetstudio.birthdayevents", databaseName: "WidgetStudioBirthdays")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        if iCloudActivated {
            let icloudContainer = "iCloud.stefanliesendahl.widgetstudio.birthdays"
            storeDescription.cloudKitContainerOptions = .init(containerIdentifier: icloudContainer)
        } else {
            storeDescription.cloudKitContainerOptions = nil
        }

        let persistentContainer = NSPersistentCloudKitContainer(name: "WidgetStudioBirthdays")
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

        NotificationCenter.default.addObserver(self, selector: #selector(processUpdate), name: .NSPersistentStoreRemoteChange, object: nil)

        return persistentContainer
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {}
        }
    }

    func deleteContainer() {
        let container = CKContainer(identifier: "iCloud.stefanliesendahl.widgetstudio.birthdays")

        container.privateCloudDatabase.fetchAllRecordZones { zones, error in
            guard let zones = zones, error == nil else {
                print("Error fetching zones.")
                return
            }

            let zoneIDs = zones.map { $0.zoneID }
            let deletionOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: zoneIDs)

            deletionOperation.modifyRecordZonesCompletionBlock = { _, _, error in
                guard error == nil else { return }
            }

            container.privateCloudDatabase.add(deletionOperation)
        }
    }

    @objc
    func processUpdate(notification _: NSNotification) {
        // log.info("iCloud PersistentStoreRemoteChange")
        if SessionState.shared.coreDataSynchronizationAfterRemoteUpdatePending {
            SessionState.shared.triggerPersistentStoreRemoteChange()
        }
    }

    /// Reinitialisiert den aktuelle NSPersistentContainer. Benötigt, wenn sich z.B. der Status der iCloud Nutzung ändert.
    func reinitializePersistentCloudKitContainer() {
        persistentContainer = setupContainer()
        managedObjectContext = persistentContainer.viewContext
    }
}

private extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
