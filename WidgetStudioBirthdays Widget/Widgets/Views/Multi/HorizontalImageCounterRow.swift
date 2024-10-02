//
//  HorizontalImageCounterRow.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 12.02.21.
//

import Foundation
import SwiftUI
import WidgetKit

public struct HorizontalImageCounterRow: View {
    @ObservedObject var userInput: UserInput

    public var body: some View {
        // --- Bilder

        let birthdays = userInput.sortedBirthdays

        ZStack {
            GeometryReader { geo2 in
                HStack(spacing: 0) {
                    let numberOfItems = 5
                    let size = geo2.size.width / CGFloat(numberOfItems + 1)

                    ForEach(0 ..< numberOfItems) { i in
                        if i > 0 {
                            Spacer(minLength: 0)
                        }

                        if let birthday3 = birthdays[safe: i] {
                            VStack(spacing: 0) {
                                let widgetURL = URL(string: "widgetstudiobirthdays://?open=\(birthday3.identifier)")!
                                Link(destination: widgetURL) {
                                    GeometryReader { geoInnen in
                                        ZStack {
                                            SingleImageCounter(countdownInfo: MultiUserInputCountdown(birthday: birthday3))
                                                .frame(width: geoInnen.size.height, height: geoInnen.size.width, alignment: .center)

                                            if birthday3.birthdayIsToday {
                                                Image("ConfettiCell")
                                                    .frame(width: geoInnen.size.height, height: geoInnen.size.width, alignment: .center)
                                            }
                                        }
                                        .frame(width: .infinity, height: .infinity, alignment: .center)
                                    }
                                }
                            }
                            .frame(width: size, height: size, alignment: .center)
                            .padding(0)

                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: size, height: size, alignment: .center)
                                .padding(0)
                        }

                        if i != numberOfItems - 1 {
                            Spacer()
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding(0)
    }
}

struct HorizontalImageCounterRowPreview: PreviewProvider {
    static var previews: some View {
        HorizontalImageCounterRow(userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test"))
            .frame(width: nil)
            .previewLayout(.fixed(width: 300, height: 150))
    }
}
