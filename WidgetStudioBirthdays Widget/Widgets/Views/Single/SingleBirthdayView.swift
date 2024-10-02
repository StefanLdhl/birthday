//
//  SingleBirthdayView.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import SwiftUI
import WidgetKit

public struct SingleBirthdayView: View {
    @ObservedObject var userInput: UserInput

    public var body: some View {
        GeometryReader { geo in

            ZStack {
                Color.defaultWidgetBackgroundColor()

                if userInput.birthdayIsToday {
                    Image("Confetti")
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                }

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(userInput.header)
                            .font(.system(size: 12))
                            .foregroundColor(Color.defaultWidgetFontColor())
                            .fontWeight(.semibold)

                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .frame(height: 20)
                            .padding(0)
                        Spacer(minLength: 4)

                        Text("\(userInput.sortedBirthdays.count)")

                            .font(.system(size: 11))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.1)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)

                            .frame(width: 18, height: 18, alignment: .center)

                            .background(
                                Circle()
                                    .fill(Color.gray)
                            )
                    }
                    .frame(height: 20)
                    .padding([.leading], 14)
                    .padding([.trailing], 11)
                    .padding([.top], 12)
                    .padding([.bottom], 1)

                    GeometryReader { _ in

                        VStack {
                            CircularPictureGroup(userInput: userInput)
                                .padding(.horizontal, 10.0)
                                .padding(.vertical, 0)
                                .edgesIgnoringSafeArea(.all)
                        }
                        .edgesIgnoringSafeArea(.all)
                    }

                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text(userInput.title)
                                .font(.system(size: 14))
                                .foregroundColor(Color.defaultWidgetFontColor())
                                .fontWeight(.bold)
                                .fixedSize(horizontal: false, vertical: true)
                                .minimumScaleFactor(0.7)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                            Spacer()
                        }
                        .frame(width: .infinity, height: 15, alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
                        .padding(.bottom, 4)

                        HStack {
                            Spacer()
                            Text(userInput.subTitle)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .fontWeight(.medium)
                                .fixedSize(horizontal: false, vertical: true)
                                .minimumScaleFactor(0.4)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 13.0)
                    .padding([.top], 3.0)

                    .frame(height: 45)
                }
                .lineSpacing(0)
            }.widgetBackground(Color(uiColor: .systemBackground))
        }
    }
}

struct SingleBirthdayViewPreview: PreviewProvider {
    static var previews: some View {
        SingleBirthdayView(userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test", header: "Nächsten Monat"))
            .frame(width: nil)
            .previewLayout(.fixed(width: 150, height: 150))
    }
}
