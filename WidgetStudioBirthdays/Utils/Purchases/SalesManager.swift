//
//  SalesManager.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.12.22.
//

import Foundation
import RevenueCat
import SwiftDate

class SalesManager {
    func getPackages(isFirstStart: Bool, userIsVIP: Bool, completion: @escaping (Result<CatPurchaseInfo, CatError>) -> Void) {
        let promo = getLocalPromoInterval(forcePromo: isFirstStart)

        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                completion(.failure(.init(error: error)))
                return
            }

            guard let offerings = offerings else {
                completion(.failure(.noOfferings))
                return
            }

            guard let defaultPackages = offerings.offering(identifier: CatOfferName.standard.rawValue)?.availablePackages,
                  let promoPackages = offerings.offering(identifier: CatOfferName.promo.rawValue)?.availablePackages
            else {
                completion(.failure(CatError.noPackages))
                return
            }
            let shouldIncludePromoPackages = promo != nil || userIsVIP
            var catPackages: [CatPackage] {
                var packages: [CatPackage] = []
                for (index, package) in defaultPackages.enumerated() {
                    if shouldIncludePromoPackages, let promoPackage = promoPackages[safe: index] {
                        packages.append(.init(package: promoPackage, referencePackage: package))
                    } else {
                        packages.append(.init(package: package, referencePackage: nil))
                    }
                }
                return packages
            }

            if shouldIncludePromoPackages, let promoInterval = promo {
                completion(.success(.init(packages: catPackages, countdownDeadline: promoInterval)))
            } else {
                completion(.success(.init(packages: catPackages, countdownDeadline: nil)))
            }
        }
    }

    func makePurchase(package: Package, isSecondaryPaywall _: Bool, completion: @escaping (Result<Package, CatError>) -> Void) {
        Purchases.shared.purchase(package: package) { _, customerInfo, error, userCancelled in

            if userCancelled {
                completion(.failure(.userCanceled))
                return
            }

            if let currentError = error {
                let error = CatError(error: currentError)
                completion(.failure(error))
                return
            }

            if customerInfo?.entitlements[CatConstants.entitlementName]?.isActive == true {
                completion(.success(package))
            } else {
                completion(.failure(.entitlementError))
            }
        }
    }

    func restorePurchase(completion: @escaping (Result<Bool, CatError>) -> Void) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let currentError = error {
                completion(.failure(CatError(error: currentError)))
                return
            }

            if customerInfo?.entitlements[CatConstants.entitlementName]?.isActive == true {
                completion(.success(true))
            } else {
                completion(.failure(.entitlementError))
            }
        }
    }

    public func isPromoActive() -> Bool {
        if CurrentUser.isUserPro() {
            resetPromo()
        }

        if let promoDeadline = GroupedUserDefaults.double(forKey: .widgetStudioDiscounts_currentPromoDeadlineInterval) {
            if Date(timeIntervalSince1970: promoDeadline).timeIntervalSince(Date()) < 0 {
                return false
            }

            return true
        }
        return false
    }

    // MARK: - PRIVATE

    private func getLocalPromoInterval(forcePromo: Bool) -> Double? {
        guard !CurrentUser.isUserPro(), Config.appConfiguration != .TestFlight else {
            resetPromo()
            return nil
        }

        // Überprüfen, ob aktuell Promo läuft
        if let promoDeadline = GroupedUserDefaults.double(forKey: .widgetStudioDiscounts_currentPromoDeadlineInterval) {
            if Date(timeIntervalSince1970: promoDeadline).timeIntervalSince(Date()) < 0 {
                resetPromo()
                return nil
            }

            return promoDeadline
        }

        // Ansonsten checken, ob User für Promo berechtigt ist
        return createNewLocalPromoIntervalIfEligable(forcePromo: forcePromo)
    }

    private func createNewLocalPromoIntervalIfEligable(forcePromo: Bool) -> Double? {
        let promosCount = GroupedUserDefaults.integer(forKey: .widgetStudioDiscounts_allPromoCount)

        if !forcePromo {
            let createdTask = AppUsageCounter.getLogCountFor(type: .newBirthday)
            let birthdayImport = AppUsageCounter.getLogCountFor(type: .contactImport)

            let proInterest = AppUsageCounter.getLogCountFor(type: .purchaseScreenOpened)
            let lastDiscountInterval = GroupedUserDefaults.double(forKey: .widgetStudioDiscounts_lastPromoDeadlineInterval) ?? 0.0

            guard proInterest > 1, createdTask > 2 || birthdayImport > 0 else {
                return nil
            }

            // Calculate required minutes based on interest in purchase and number of previous promos
            var minutesNeeded = 35280.0
            if proInterest >= 3 {
                minutesNeeded = 22000.0 + Double(promosCount) * 15120.0
            } else {
                minutesNeeded = 35280.0 + Double(promosCount) * 15120.0
            }

            // Enough time since last promo
            let secondsSinceLastDiscount = Date().timeIntervalSince1970 - lastDiscountInterval
            guard secondsSinceLastDiscount > minutesNeeded * 60 else {
                return nil
            }

            // Enough time since initial launch
            var firstKnownDate: Date?
            if let firstSeenDate = CurrentUser.firstSeenDate() {
                firstKnownDate = firstSeenDate

            } else if let firstStartDate = GroupedUserDefaults.date(forKey: .localUserInfo_firstAppStartDate) {
                firstKnownDate = firstStartDate
            }

            guard let validDate = firstKnownDate else {
                return nil
            }

            let timeSinceFirstStart = Date().timeIntervalSince(validDate)

            guard timeSinceFirstStart > minutesNeeded * 60 else {
                return nil
            }
        }

        // Create Promo
        let newDeadline = getNewDeadline(shortDeadline: forcePromo)

        GroupedUserDefaults.set(value: newDeadline, for: .widgetStudioDiscounts_lastPromoDeadlineInterval)
        GroupedUserDefaults.set(value: newDeadline, for: .widgetStudioDiscounts_currentPromoDeadlineInterval)
        GroupedUserDefaults.set(value: promosCount + 1, for: .widgetStudioDiscounts_allPromoCount)

        return newDeadline
    }

    private func getNewDeadline(shortDeadline: Bool) -> Double {
        return (Date() + (shortDeadline ? Int.random(in: 12 ... 14) : Int.random(in: 13 ... 22)).hours + Int.random(in: 0 ... 55).minutes + Int.random(in: 0 ... 55).seconds).timeIntervalSince1970
    }

    private func resetPromo() {
        GroupedUserDefaults.removeObject(forKey: .widgetStudioDiscounts_currentPromoDeadlineInterval)
        GroupedUserDefaults.synchronize()
    }
}

enum PurchaseReason: String {
    case unknown
    case widgetFeatures
    case iCloudSync
    case onboarding
}
