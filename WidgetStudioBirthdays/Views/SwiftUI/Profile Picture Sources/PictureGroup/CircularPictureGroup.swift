//
//  CircularPictureGroup.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import SwiftUI

struct CircularPictureGroup: View {
    @ObservedObject var userInput: UserInput

    var body: some View {
        let pics = userInput.sortedBirthdays.map { createProfilePicture(birthdayInfo: $0) }

        if pics.count == 1 {
            CircularPictureGroupOne(pictureInfo: pics[0])
                .padding(.all, 8.0)
        } else if pics.count == 2 {
            CircularPictureGroupTwo(pictureInfo1: pics[0], pictureInfo2: pics[1])
                .padding(.all, 10.0)

        } else if pics.count >= 3 {
            CircularPictureGroupThree(mainPictureInfo: pics[0], pictureInfo2: pics[1], pictureInfo3: pics[2])
                .padding(.all, 4.0)
        }
    }
}

extension CircularPictureGroup {
    private func createProfilePicture(birthdayInfo: BirthdayInfoViewModel) -> ProfilePictureUserInput {

        return ProfilePictureUserInput(birthdayInfo: birthdayInfo, showShadow: true, fixedBorderWidth: 1.7)
    }
}

struct CircularPictureGroup_Previews: PreviewProvider {
    static var previews: some View {
        CircularPictureGroup(userInput: UserInput(sortedBirthdays: [BirthdayInfoViewModel(identifier: "123", name: "Preview"), BirthdayInfoViewModel(identifier: "123", name: "Preview")], title: "Test", subTitle: "Test"))
            .frame(width: nil)
            .previewLayout(.fixed(width: 400, height: 200))
    }
}
