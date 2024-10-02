//
//  CircularProfilePicture.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import SwiftUI

struct CircularGroupPicture: View {
    @ObservedObject var groupPictureInfo: GroupPictureUserInput

    var body: some View {
        let colorGradient = LinearGradient(gradient: Gradient(colors: [groupPictureInfo.color1, groupPictureInfo.color2]), startPoint: .topLeading, endPoint: .bottomTrailing)

        GeometryReader { g in

            ZStack {
                Image(uiImage: UIImage(named: "colorfullBackground")!)
                    .resizable()
                    .foregroundColor(.red)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())

                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle()
                        .strokeBorder(Color.red, lineWidth: g.size.width / 30)
                        .gradientMask(gradient: colorGradient))

                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        Image(systemName: "person.3")
                            .resizable()
                            .foregroundColor(.red)
                            .accessibility(label: Text("app.accessibility.views.groupDetailsView.groupPicture.title".localize()))
                            .aspectRatio(contentMode: .fit)
                            .gradientMask(gradient: colorGradient)
                            .frame(width: g.size.width / 1.5, height: g.size.width / 1.5, alignment: .center)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .background(Color.clear)
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct CircularGroupPicture_Previews: PreviewProvider {
    static var previews: some View {
        CircularGroupPicture(groupPictureInfo: GroupPictureUserInput(color1: Color.red, color2: Color.orange))
            .previewLayout(.fixed(width: 100, height: 100))
    }
}
