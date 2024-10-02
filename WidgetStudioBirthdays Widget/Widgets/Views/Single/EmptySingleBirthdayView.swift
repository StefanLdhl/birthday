//
//  SingleBirthdayView.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Foundation
import SwiftUI
import WidgetKit

public struct EmptySingleBirthdayView: View {
    public var body: some View {
        ZStack {
            Color.defaultWidgetBackgroundColor()

            VStack(spacing: 0) {
                Image("defaultIcon2")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("widgetPlaceholderGray"))
                    .frame(width: 40, height: 40, alignment: .center)

                Text("\n\("widget.single.placeholder.defaultText".localize())")
                    .font(.system(size: 10))
                    .foregroundColor(Color("widgetPlaceholderGray"))
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .padding(0)
            }
            .padding([.leading, .trailing])
            .padding([.bottom], 7.0)
            .padding([.top], 3.0)
        }
        .lineSpacing(0)
        .widgetBackground(Color(uiColor: .systemBackground))
    }
}

struct EmptySingleBirthdayViewPreview: PreviewProvider {
    static var previews: some View {
        EmptySingleBirthdayView()
            .frame(width: nil)
            .previewLayout(.fixed(width: 150, height: 150))
    }
}
