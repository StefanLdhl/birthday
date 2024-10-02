//
//  CircularPictureGroupTwo.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import SwiftUI

struct CircularPictureGroupTwo: View {
    @ObservedObject var pictureInfo1: ProfilePictureUserInput
    @ObservedObject var pictureInfo2: ProfilePictureUserInput

    var body: some View {
        GeometryReader { g in

            let sideLength = g.size.width / 1.5

            Spacer()
            ZStack {
                HStack {
                    CircularProfilePicture(profilePictureInfo: pictureInfo1)
                        .frame(height: g.size.height)
                        .frame(width: sideLength)

                    Spacer()
                }.zIndex(1)

                HStack {
                    Spacer()
                    CircularProfilePicture(profilePictureInfo: pictureInfo2)
                        .frame(height: g.size.height)
                        .frame(width: sideLength)
                }
            }
            Spacer()
        }
    }
}

struct CircularPictureGroupTwo_Previews: PreviewProvider {
    static var previews: some View {
        CircularPictureGroupTwo(pictureInfo1: ProfilePictureUserInput(profilePicture: nil, initials: "SL", color1: .red, color2: .green), pictureInfo2: ProfilePictureUserInput(profilePicture: UIImage(named: "colorfullBackground"), initials: "ML", color1: .red, color2: .green))
            .frame(width: nil)
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
