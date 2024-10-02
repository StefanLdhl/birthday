//
//  LockMultiBirthdayView.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 08.09.22.
//

import Foundation
import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
public struct LockMultiBirthdayRectangleView: View {
    @ObservedObject var userInput: UserInput

    public var body: some View {
        let birthdays = userInput.sortedBirthdays.prefix(3)
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(birthdays, id: \.self) { birthday in
                        let cellHeight = geo.size.height / 3
                        let iconHeight = cellHeight * 0.9

                        HStack {
                            Image("defaultIcon2").resizable().aspectRatio(contentMode: .fit)
                                .frame(height: iconHeight)

                            Spacer(minLength: 2)
                                .frame(width: 4)

                            if birthday.birthdayIsToday {
                                Text(birthday.firstName).fontWeight(.bold)
                                    .lineLimit(1)
                                Spacer(minLength: 2)
                                Image(systemName: "party.popper.fill").resizable().aspectRatio(contentMode: .fit)
                                    .frame(width: 16.0, height: 16.0)

                            } else {
                                Text(birthday.firstName).fontWeight(.medium)
                                    .lineLimit(1)
                                Spacer(minLength: 2)
                                Text("\(birthday.daysLeftToBirthday)").fontWeight(.medium)
                                    .lineLimit(1)
                                Spacer()
                                    .frame(width: 1)
                                Text("↓").font(.system(size: 10)).fontWeight(.medium)
                                    .lineLimit(1)
                            }
                        }
                        .frame(height: cellHeight)
                    }
                }
            }.widgetBackground(Color(uiColor: .clear))
        }
    }
}

@available(iOS 16.0, *)
public struct LockMultiEmptyBirthdayRectangleView: View {
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Image("defaultIcon2").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 16.0, height: 16.0)
                    Spacer(minLength: 2)
                        .frame(width: 4)
                    Text("widget.single.placeholder.defaultText".localize()).fontWeight(.medium)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
            }
        }
    }
}

@available(iOS 16.0, *)
struct LockMultiBirthdayRectangleViewPreview: PreviewProvider {
    static var previews: some View {
        LockMultiBirthdayRectangleView(userInput: UserInput(sortedBirthdays: [
            .init(identifier: "test", name: "Stefan"),
            .init(identifier: "test", name: "Stefan"),
            .init(identifier: "test", name: "Stefan"),
        ], title: "", subTitle: ""))

            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
