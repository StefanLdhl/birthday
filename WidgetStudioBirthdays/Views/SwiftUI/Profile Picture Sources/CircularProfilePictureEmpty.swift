//
//  CircularProfilePicturEmpty.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 13.01.21.
//

import SwiftUI

struct CircularProfilePictureEmpty: View {
    @ObservedObject var profilePictureInfo: ProfilePictureUserInput

    static let gradientStart = Color(hexString: "#a6a9b8")
    static let gradientEnd = Color(hexString: "#858992")

    var body: some View {
        let colorGradient = LinearGradient(gradient: Gradient(colors: [profilePictureInfo.color1, profilePictureInfo.color2]), startPoint: .topLeading, endPoint: .bottomTrailing)

        GeometryReader { g in

            HStack {
                Spacer(minLength: 0)
                VStack {
                    Spacer(minLength: 0)

                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                                startPoint: .init(x: 0.5, y: 0),
                                endPoint: .init(x: 0.5, y: 0.8)
                            ))
                        
                        
                            .if(profilePictureInfo.showShadow) {
                                $0.shadow(color: Color.black.opacity(0.2), radius: 5)
                            }


                        Image(systemName: "person")
                            .resizable()
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .aspectRatio(contentMode: .fit)

                            .frame(width: g.size.width / 2.5, height: g.size.width / 2.5, alignment: .center)

                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: profilePictureInfo.fixedBorderWidth ?? g.size.width / 30)
                                    .gradientMask(gradient: colorGradient)
                            )
                    }
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .frame(width: g.size.width, height: g.size.height, alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct CircularProfilePictureEmpty_Previews: PreviewProvider {
    static var previews: some View {
        CircularProfilePictureEmpty(profilePictureInfo: ProfilePictureUserInput(profilePicture: nil, initials: "SL", color1: Color.yellow, color2: Color.red))
            .previewLayout(.fixed(width: 200, height: 400))
    }
}
