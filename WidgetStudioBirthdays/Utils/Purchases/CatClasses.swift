//
//  CatClasses.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.12.22.
//

import Foundation
import RevenueCat

enum CatConstants {
    static let entitlementName = "pro"
    static let apiKey = "LJMoUaQrTyjRWXvenvJkxCbhLAGadNXt"
}

enum CatOfferName: String {
    case standard
    case promo
}

struct CatPurchaseInfo {
    let packages: [CatPackage]
    let deadline: Double?

    init(packages: [CatPackage], countdownDeadline: Double?) {
        self.packages = packages
        deadline = countdownDeadline
    }
}

struct CatPackage {
    let package: Package
    let referencePackage: Package?

    var packageName: String {
        return package.packageType.localizedName
    }

    var referenceSubscriptionPrice: String? {
        return referencePackage?.storeProduct.getFormattedPriceStringForType(type: package.packageType)
    }

    var subscriptionPrice: String {
        return package.storeProduct.getFormattedPriceStringForType(type: package.packageType)
    }

    var subscriptionPeriod: String? {
        guard let subPeriod = package.storeProduct.subscriptionPeriod else { return nil }
        return subPeriod.unit.getLocalizedName(plural: subPeriod.value > 1)
    }

    var paywallAdditionalInfo: String {
        if package.packageType == .monthly {
            return "app.storePackageType.info.subscriptions.singleMonth".localize()
        } else if let monthlyPrice = formattedMonthlyPrice {
            return "app.storePackageType.info.subscriptions.monthly.%@".localize(values: monthlyPrice)
        } else if package.packageType == .lifetime {
            return "app.storePackageType.info.lifetime".localize()
        } else {
            return "app.views.purchase.title".localize() // Fallback
        }
    }

    var purchasePriceWithPeriod: String {
        guard let subscriptionPeriod = subscriptionPeriod else {
            return "app.storePackageType.lifetime.addition.%@".localize(values: subscriptionPrice)
        }
        return "\(subscriptionPrice)/\(subscriptionPeriod)"
    }

    var trialPeriod: String? {
        guard let freePeriod = package.storeProduct.introductoryDiscount?.subscriptionPeriod else { return nil }
        guard let localizedUnit = freePeriod.unit.getLocalizedName(plural: freePeriod.value > 1) else { return nil }
        return "\(freePeriod.value) \(localizedUnit)"
    }

    var trialPeriodDescription: String? {
        guard let trialPeriod = trialPeriod else { return nil }
        return "app.storePackageType.info.trial.%@".localize(values: trialPeriod)
    }

    var formattedMonthlyPrice: String? {
        guard let price = package.storeProduct.getFormattedPricePerMonth() else {
            return nil
        }
        return "\(price)"
    }

    var buyButtonTitle: String {
        if subscriptionPeriod == nil {
            return "app.views.purchase.buyButton.title.new.default".localize()
        } else if trialPeriod == nil {
            return "app.views.purchase.buyButton.title.freeTrialText.alternative".localize()
        } else {
            return "app.views.purchase.buyButton.title.freeTrialText.alternative.2".localize()
        }
    }

    var footerLabelContent: String {
        if subscriptionPeriod == nil {
            return "app.views.purchase.buyButton.title.new.default.%@".localize(values: subscriptionPrice)
        }

        if let trialPeriod = trialPeriod {
            return "app.views.purchase.buyButton.title.new.sub.withTrial.%@.%@".localize(values: trialPeriod, purchasePriceWithPeriod)
        } else {
            return "app.views.purchase.buyButton.title.new.sub.%@".localize(values: purchasePriceWithPeriod)
        }
    }
}

extension CatPackage: Equatable {
    static func == (lhs: CatPackage, rhs: CatPackage) -> Bool {
        return lhs.package.identifier == rhs.package.identifier
    }
}

/// Enum for CoreData related errors
enum CatError: Error, LocalizedError, Equatable {
    case noOfferings
    case noPackages
    case notAllowed
    case invalid
    case networkError
    case entitlementError
    case restoreError
    case otherCatError(Int)
    case userCanceled
    case nonRCError(String)

    case unknown

    init(error: Error) {
        if let error = error as? RevenueCat.ErrorCode {
            switch error {
            case .purchaseNotAllowedError:
                self = .notAllowed
            case .purchaseInvalidError:
                self = .invalid
            case .unknownError:
                self = .unknown
            default:
                self = .otherCatError(error.rawValue)
            }
        } else {
            self = .nonRCError(error.localizedDescription)
        }
    }

    public var errorDescription: String? {
        switch self {
        case .noPackages:
            return "No packages found."
        case .notAllowed:
            return "Action not allowed"
        case .invalid:
            return "Invalid request"
        case .networkError:
            return "Network issue"
        case let .otherCatError(catRawValue):
            return "App Store problem (\(catRawValue))"
        case .unknown:
            return "Unknown error"
        case .entitlementError:
            return "Entitlement error"
        case .userCanceled:
            return "Action canceled"
        case .restoreError:
            return "Restore error"
        case let .nonRCError(errorText):
            return "non RC: \(errorText)"
        case .noOfferings:
            return "No offerings found."
        }
    }
}
