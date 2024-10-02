//
//  LockMultiBirthdayInlineView.swift
//  WidgetStudioBirthdays Intent
//
//  Created by Stefan Liesendahl on 08.09.22.
//

import Foundation
import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
public struct LockBirthdayInlineView: View {
    @ObservedObject var userInput: UserInput

    public var body: some View {
        ZStack {
            if userInput.sortedBirthdays.count > 0 {
                if userInput.birthdayIsToday {
                    Label {
                        Text("\(userInput.title)")
                    } icon: {
                        Image(systemName: "party.popper.fill")
                    }

                } else {
                    Label {
                        Text("\(userInput.title)")
                    } icon: {
                        Image("defaultIcon2")
                    }
                }

            } else {
                Label {
                    Text("widget.single.placeholder.defaultText".localize())
                } icon: {
                    Image("defaultIcon2")
                }
            }
        }.widgetBackground(Color(uiColor: .clear))
    }
}

@available(iOS 16.0, *)
struct LockBirthdayInlineViewPreview: PreviewProvider {
    static var previews: some View {
        LockBirthdayInlineView(userInput: UserInput(sortedBirthdays: [
            .init(identifier: "test", name: "Stefan"),
            .init(identifier: "test", name: "Stefan"),
            .init(identifier: "test", name: "Stefan"),
        ], title: "", subTitle: ""))

            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
