//
//  CircularProfilePicture.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import SwiftUI

struct CircularProfilePictureImage: View {
    @ObservedObject var profilePictureInfo: ProfilePictureUserInput

    var body: some View {
        let colorGradient = LinearGradient(gradient: Gradient(colors: [profilePictureInfo.color1, profilePictureInfo.color2]), startPoint: .topLeading, endPoint: .bottomTrailing)

        GeometryReader { geo in
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    let sideLength = min(geo.size.height, geo.size.width)

                    CircleImage(image: Image(uiImage: profilePictureInfo.profilePicture ?? UIImage()),
                                borderGradient: colorGradient, borderWidth: profilePictureInfo.fixedBorderWidth ?? geo.size.width / 30, showShadow: profilePictureInfo.showShadow)
                        .frame(width: sideLength, height: sideLength)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
        }
    }
}

struct CircleImage: View {
    var image: Image
    var borderGradient: LinearGradient
    var borderWidth: CGFloat
    var showShadow: Bool

    var body: some View {
        image
            .resizable()
            
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .foregroundColor(.clear)
            
            .if(showShadow) {
                $0.shadow(color: Color.black.opacity(0.2), radius: 5)
            }
            
            .overlay(
                Circle()
                    .strokeBorder(Color.white, lineWidth: borderWidth)
                    .gradientMask(gradient: borderGradient)
            )
        
    }
}

struct CircularProfilePictureImage_Previews: PreviewProvider {
    static var previews: some View {
        CircularProfilePictureImage(profilePictureInfo: ProfilePictureUserInput(profilePicture: UIImage(named: "colorfullBackground"), initials: "SL", color1: Color.blue, color2: Color.pink))
            .previewLayout(.fixed(width: 400, height: 600))
    }
}
