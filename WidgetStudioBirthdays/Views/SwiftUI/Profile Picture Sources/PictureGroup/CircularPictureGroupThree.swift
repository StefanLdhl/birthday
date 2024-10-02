//
//  CircularPictureGroupThree.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import SwiftUI

struct CircularPictureGroupThree: View {
    @ObservedObject var mainPictureInfo: ProfilePictureUserInput
    @ObservedObject var pictureInfo2: ProfilePictureUserInput
    @ObservedObject var pictureInfo3: ProfilePictureUserInput

    var body: some View {
        GeometryReader { g in

            let sideLength = g.size.width / 3

            Spacer()
            ZStack {
                HStack {
                    CircularProfilePicture(profilePictureInfo: pictureInfo2)
                        .frame(height: g.size.height)
                        .frame(maxWidth: sideLength)

                    Spacer()
                }

                HStack {
                    Spacer()
                    CircularProfilePicture(profilePictureInfo: mainPictureInfo)
                        .frame(height: g.size.height)
                        .frame(width: sideLength * 1.4)

                    Spacer()
                }.zIndex(1)

                HStack {
                    Spacer()
                    CircularProfilePicture(profilePictureInfo: pictureInfo3)
                        .frame(height: g.size.height)
                        .frame(width: sideLength)
                }
            }
            Spacer()
        }
    }
}

struct CircularPictureGroupThree_Previews: PreviewProvider {
    static var previews: some View {
        CircularPictureGroupThree(mainPictureInfo: ProfilePictureUserInput(profilePicture: UIImage(named: "colorfullBackground"), initials: "SL", color1: .red, color2: .green), pictureInfo2: ProfilePictureUserInput(profilePicture: nil, initials: "ML", color1: .red, color2: .green), pictureInfo3: ProfilePictureUserInput(profilePicture: nil, initials: "ML", color1: .red, color2: .green))
            .frame(width: nil)
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
