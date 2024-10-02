//
//  SingleImageCounter.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.02.21.
//

import Foundation
import SwiftUI
import WidgetKit

public struct SingleImageCounter: View {
    @ObservedObject var countdownInfo: MultiUserInputCountdown

    public var body: some View {
        let colorGradient = LinearGradient(gradient: Gradient(colors: [countdownInfo.color1, countdownInfo.color2]), startPoint: .topLeading, endPoint: .bottomTrailing)

        GeometryReader { geo in

            ZStack {
                Color.clear

                let shortSide = min(geo.size.height, geo.size.width)
                let height = shortSide * 1.1 <= geo.size.height ? shortSide * 1.1 : shortSide
                    
                    
                ZStack {
                    VStack {
                        CircularProfilePicture(profilePictureInfo: ProfilePictureUserInput(birthdayInfo: countdownInfo.birthday, showShadow: true, fixedBorderWidth: 1.7))
                    }
                    .frame(width: .infinity, height: .infinity, alignment: .center)
                    .padding(.bottom, shortSide / 12)

                    VStack {
                        Spacer()

                        let pillHeight = shortSide / 3
                        let pillWidth = shortSide / 2.6

                        VStack {
                            Spacer()
                            let isBirthday = countdownInfo.daysLeft == 0
                            let daysLeftText = isBirthday ? "🎂" : "\(countdownInfo.daysLeft)"
                            Text(daysLeftText)

                                .foregroundColor(.white)
                                .font(.system(size: isBirthday ? pillHeight * 0.63 : pillHeight * 0.82))
                                .fontWeight(.bold)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(1)
                                .layoutPriority(1)
                                .minimumScaleFactor(0.4)
                            Spacer()
                        }

                        .frame(width: pillWidth, height: pillHeight, alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
                        .padding(.horizontal, pillWidth / 5)
                        .padding(.vertical, 0)
                        .background(colorGradient)
                        .cornerRadius(pillHeight / 2)
                    }
                    .padding(.bottom, 0)
                }

                .frame(width: shortSide, height: height, alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

struct SingleImageCounterPreview: PreviewProvider {
    static var previews: some View {
        SingleImageCounter(countdownInfo: MultiUserInputCountdown(birthday: BirthdayInfoViewModel(identifier: "123", name: "Stefan")))
            .frame(width: nil)
            .previewLayout(.fixed(width: 300, height:300))
    }
}
