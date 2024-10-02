//
//  StoreProduct+FormattedPrice.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.12.22.
//

import Foundation
import RevenueCat

extension StoreProduct {
    func getFormattedPricePerMonth() -> String? {
        guard let pricePerMonth = pricePerMonth, let currencyCode = currencyCode else {
            return nil
        }

        guard pricePerMonth != priceDecimalNumber else {
            return nil
        }

        let formatter = NumberFormatter()
        formatter.locale = Locale.preferredLocale()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: pricePerMonth)
    }

    func getFormattedPriceStringForType(type _: PackageType) -> String {
        return localizedPriceString
    }
}
