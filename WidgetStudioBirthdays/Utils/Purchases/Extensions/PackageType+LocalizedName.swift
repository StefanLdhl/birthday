//
//  PackageType+LocalizedName.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.12.22.
//

import Foundation
import RevenueCat

extension PackageType {
    var localizedName: String {
        switch self {
        case .lifetime:
            return "app.storePackageType.lifetime".localize()
        case .annual:
            return "app.storePackageType.annual".localize()
        case .threeMonth:
            return "app.storePackageType.threeMonth".localize()
        case .monthly:
            return "app.storePackageType.monthly".localize()
        default:
            return "Pro"
        }
    }
}
