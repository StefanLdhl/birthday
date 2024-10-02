//
//  CircularProfilePicture.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import SwiftUI

struct CircularProfilePicture: View {
    @ObservedObject var profilePictureInfo: ProfilePictureUserInput

    var body: some View {
        GeometryReader { g in
            
        VStack {
            if profilePictureInfo.profilePicture != nil {
                CircularProfilePictureImage(profilePictureInfo: profilePictureInfo)
                    .accessibility(label: Text("app.accessibility.views.list.profilePicture.pic".localize()))

            } else if profilePictureInfo.initals != nil {
                CircularProfilePictureText(profilePictureInfo: profilePictureInfo)
                    .accessibility(label: Text("app.accessibility.views.list.profilePicture.initials".localize()))

            } else {
                CircularProfilePictureEmpty(profilePictureInfo: profilePictureInfo)
                    .accessibility(label: Text("app.accessibility.views.list.profilePicture.pic".localize()))
            }
            
        }
        .frame(width: profilePictureInfo.fixedSize?.width ?? g.size.width, height: profilePictureInfo.fixedSize?.height ?? g.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    }
}

struct CircularProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        CircularProfilePicture(profilePictureInfo: ProfilePictureUserInput(profilePicture: UIImage(named: "colorfullBackground"), initials: "SL", color1: Color.yellow, color2: Color.red))
            .previewLayout(.fixed(width: 1000, height: 2000))
    }
}
