//
//  WidgetStudioBirthdaysTests.swift
//  WidgetStudioBirthdaysTests
//
//  Created by Stefan Liesendahl on 20.11.20.
//
import SwiftDate
@testable import WidgetStudioBirthdays
import XCTest

class WidgetStudioBirthdaysTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        for i in -50 ... 50 {
            let birthday = Date() + i.days
            let triggerDate = Date()

            let tmp = NotificationManager.getCustomNotificationContent(contactName: "Stefan", triggerDate: triggerDate, birthdate: birthday)

            print(birthday.toString())
            print(triggerDate.toString())
            print(tmp)
            print("\n")
        }
    }
}
