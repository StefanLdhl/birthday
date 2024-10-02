//
//  SessionState.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 10.01.21.
//

import Foundation
import WidgetKit

class SessionState: NSObject {
    // Singleton
    static let shared = SessionState()

    var lastDatabaseStatus: Date?

    var coreDataSynchronizationAfterRemoteUpdatePending = false
    private var coreDataTimeIntervalOfLastSynchronization: Double?
    private var coreDataChangesAppliedCheckTimer: Timer?
    private var timeoutCounter = 0

    public var databaseHasPossibleDuplicateEntries = false

    public func checkForIncomingCoreDataCloudKitChanges(completion: @escaping (Bool) -> Void) {
        coreDataChangesAppliedCheckTimer?.invalidate()
        coreDataSynchronizationAfterRemoteUpdatePending = true
        coreDataTimeIntervalOfLastSynchronization = nil
        timeoutCounter = 0

        coreDataChangesAppliedCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in

            if self.checkIfAllCloudKitChangesShouldHaveBeenApplied() {
                CoreDataStack.defaultStack.saveContext()

                WidgetCenter.shared.reloadAllTimelines()

                self.stopTimer()

                completion(true)
                return
            } else if self.timeoutCounter >= 25 {
                self.stopTimer()
                completion(false)
                return
            }

            self.timeoutCounter += 1
        }
    }

    public func triggerPersistentStoreRemoteChange() {
        coreDataTimeIntervalOfLastSynchronization = Date().timeIntervalSince1970
    }

    private func stopTimer() {
        coreDataSynchronizationAfterRemoteUpdatePending = false
        coreDataTimeIntervalOfLastSynchronization = nil
        coreDataChangesAppliedCheckTimer?.invalidate()
        coreDataChangesAppliedCheckTimer = nil
    }

    private func checkIfAllCloudKitChangesShouldHaveBeenApplied() -> Bool {
        guard let lastSynchronisationTime = coreDataTimeIntervalOfLastSynchronization else {
            return false
        }

        let difference = Date().timeIntervalSince1970 - lastSynchronisationTime
        return difference > 10
    }
}
