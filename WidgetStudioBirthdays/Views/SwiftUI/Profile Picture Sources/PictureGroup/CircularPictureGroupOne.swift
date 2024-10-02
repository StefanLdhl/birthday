//
//  CircularPictureGroupOne.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//
import SwiftUI

struct CircularPictureGroupOne: View {
    @ObservedObject var pictureInfo: ProfilePictureUserInput

    var body: some View {
        GeometryReader { g in

            let sideLength = g.size.width / 1.5

            Spacer()
            ZStack {
                HStack {
                    Spacer()
                    CircularProfilePicture(profilePictureInfo: pictureInfo)
                        .frame(height: g.size.height)
                        .frame(width: sideLength)

                    Spacer()
                }.zIndex(1)
            }
            Spacer()
        }
    }
}

struct CircularPictureGroupOne_Previews: PreviewProvider {
    static var previews: some View {
        CircularPictureGroupOne(pictureInfo: ProfilePictureUserInput(profilePicture: nil, initials: "SL", color1: .red, color2: .green))
            .frame(width: nil)
            .previewLayout(.fixed(width: 400, height: 200))
    }
}



