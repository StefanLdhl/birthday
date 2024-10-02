//
//  MultiBirthdayView.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 25.01.21.
//

import Foundation
import SwiftUI
import WidgetKit

public struct MultiBirthdayView: View {
    @ObservedObject var userInput: UserInput

    public var body: some View {
        let hideTimeline = userInput.additionalInfo1 == nil && userInput.additionalInfo2 == nil

        GeometryReader { _ in

            Color.defaultWidgetBackgroundColor()

            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Text(userInput.title)
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .foregroundColor(Color.defaultWidgetFontColor()
                            )
                        Spacer()
                    }
                    .frame(height: 20, alignment: .leading)
                    .padding(.top, 1)

                    HStack {
                        Text("widget.multi.subtitle.default".localize())
                            .font(.system(size: 13))
                            .fontWeight(.medium)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .foregroundColor(Color.gray)
                        Spacer()
                    }
                    .frame(height: 20, alignment: .leading)
                    .padding(.bottom, 3)

                    // --- Bilder
                    VStack(spacing: 0) {
                        Spacer()
                        HStack(spacing: 0) {
                            HorizontalImageCounterRow(userInput: userInput)
                        }
                        .frame(maxHeight: .infinity)
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)

                    HStack {
                        VStack {
                            Spacer()
                            Text(userInput.additionalInfo1 ?? "")
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                                .foregroundColor(Color.gray)
                                .frame(alignment: .leading)
                        }
                        .frame(height: 17, alignment: .leading)

                        VStack {
                            Spacer()

                            Line()
                                .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [2.5]))
                                .frame(height: 1)
                                .foregroundColor(hideTimeline ? .clear : Color.gray.opacity(0.5))

                                .frame(width: .infinity, height: 0.5, alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 17, maxHeight: 17, alignment: .bottomLeading)
                        .padding(.bottom, 4)

                        VStack {
                            Spacer()
                            Text(userInput.additionalInfo2 ?? "")
                                .fontWeight(.medium)
                                .font(.system(size: 10))
                                .foregroundColor(Color.gray)
                                .frame(alignment: .leading)
                        }
                        .frame(height: 17, alignment: .trailing)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 17, maxHeight: 17, alignment: .topLeading)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 16)
            }
            .widgetBackground(Color(uiColor: .systemBackground))
        }
    }
}

struct MultiBirthdayViewPreview: PreviewProvider {
    static var previews: some View {
        MultiBirthdayView(userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test"))
            .frame(width: nil)
            .previewLayout(.fixed(width: 300, height: 150))
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
