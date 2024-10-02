//
//  LockMultiBirthdayProvider.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 08.09.22.
//

import Foundation
import Intents
import SwiftUI
import WidgetKit

struct LockMultiBirthdayProvider: IntentTimelineProvider {
    func getTimeline(for intent: LockMultiBirthdayWidgetIntent, in _: Context, completion: @escaping (Timeline<DateTimelineEntry>) -> Void) {
        let timelineEntries = getBirthdayDetails(for: intent)

        let timeline = Timeline(entries: timelineEntries, policy: .atEnd)
        completion(timeline)
    }

    
    private func getBirthdayDetails(for intent: LockMultiBirthdayWidgetIntent? = nil) -> [DateTimelineEntry] {
        CoreDataStack.defaultStack.managedObjectContext.reset()
        let allBirthdays = BirthdayRepository.getAllBirthdays()

        let showAllItems = intent?.showAll as? Bool ?? true
        
        if !showAllItems, let groups = intent?.groups, groups.count > 0 {
            let groupIds = groups.map { $0.identifier }
            var itemsToShow: [Birthday] = []

            for birthday in allBirthdays {
                if groupIds.contains(birthday.group?.identifier) {
                    itemsToShow.append(birthday)
                }
            }

            return TimelineEntryFactory.createTimelineEntriesForMultiWidget(birthdays: itemsToShow)
        }

        return TimelineEntryFactory.createTimelineEntriesForMultiWidget(birthdays: allBirthdays)
    }

    func getSnapshot(for _: LockMultiBirthdayWidgetIntent, in _: Context, completion: @escaping (DateTimelineEntry) -> Void) {
        completion(getBirthdayDetails().first ?? DateTimelineEntry(date: Date(), userInput: UserInput()))
    }

    func placeholder(in _: Context) -> DateTimelineEntry {
        return DateTimelineEntry(date: Date(), userInput: UserInput())
    }
}

