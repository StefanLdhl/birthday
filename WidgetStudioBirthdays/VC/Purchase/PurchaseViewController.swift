//
//  PurchaseViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import AMPopTip
import Haptica
import ProgressHUD
import RevenueCat
import SwiftDate
import SwiftUI
import UIKit
import WidgetKit

class PurchaseViewController: UIViewController {
    @IBOutlet var buyButton: PurchaseButton!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var featureLabel1: UILabel!
    @IBOutlet var featureLabel2: UILabel!
    @IBOutlet var featureLabel3: UILabel!
    @IBOutlet var featureLabel4: UILabel!
    @IBOutlet var featureLabel5: UILabel!
    @IBOutlet var footerLabel: UILabel!
    @IBOutlet var featureViewInStack: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var appIconImageView: UIImageView!
    @IBOutlet var allPlansButton: UIButton!
    @IBOutlet var helpButton: UIButton!
    @IBOutlet var allPlansButtonLabel: UILabel!
    @IBOutlet var helpButtonLabel: UILabel!
    @IBOutlet var additionPointLabel: UILabel!

    private var userIsAlreadyPro = CurrentUser.isUserPro()
    private var salesManager = SalesManager()
    private var proPackage: CatPackage?
    private var proPackagePromoDeadline: Double?
    private var fullPackagesList: [CatPackage] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let showPlans = self.fullPackagesList.count > 1
                self.additionPointLabel.isHidden = !showPlans
                self.allPlansButtonLabel.isHidden = !showPlans
                self.allPlansButton.isEnabled = showPlans
            }
        }
    }

    private var infoPopUp: PopTip {
        var popTip = PopTip()
        popTip = PopTip()
        popTip.bubbleColor = UIColor(named: "defaultColor7") ?? .systemRed
        popTip.textColor = UIColor.white
        popTip.edgeMargin = 20
        popTip.actionAnimation = .bounce(2)
        popTip.shouldDismissOnTapOutside = false
        popTip.shouldDismissOnTap = true
        popTip.font = .systemFont(ofSize: 15, weight: .medium)
        popTip.shadowRadius = 6
        popTip.shadowOpacity = 0.1
        popTip.shadowColor = UIColor.black.withAlphaComponent(0.6)
        return popTip
    }

    private var coundownTimer: Timer?
    private var isPromo: Bool = false
    private var userHasBoughtOtherApp: Bool = false

    var purchaseModeActive = false {
        didSet {
            if purchaseModeActive {
                let text = proPackage?.package.packageType == .lifetime ? "app.storePackageType.info.lifetime.prgressHud".localize() : nil
                ProgressHUD.show(text, interaction: false)
            } else {
                ProgressHUD.dismiss()
            }

            buyButton.isUserInteractionEnabled = !purchaseModeActive
            buyButton.alpha = purchaseModeActive ? 0.8 : 1.0
        }
    }

    // Incoming
    var isFirstAppStart = false
    var activeTap = false

    override func viewDidLoad() {
        super.viewDidLoad()

        appIconImageView.layer.shadowColor = UIColor.black.cgColor
        appIconImageView.layer.shadowRadius = 12
        appIconImageView.layer.shadowOpacity = 0.3
        appIconImageView.clipsToBounds = false
        appIconImageView.layer.masksToBounds = false

        refreshAll()
        setupGradients()

        fullPackagesList = []

        AppUsageCounter.logEventFor(type: .purchaseScreenOpened)

        dismissButton.alpha = 0
        dismissButton.isUserInteractionEnabled = false

        isModalInPresentation = true

        ProgressHUD.animationType = .circleRippleMultiple
        ProgressHUD.colorHUD = UIColor.gray.withAlphaComponent(0.2)
    }

    private func startButtonAnimation() {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: [.autoreverse, .repeat, .allowUserInteraction],
                       animations: {
                           self.buyButton.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
                       },
                       completion: nil)
    }

    override func viewDidDisappear(_: Bool) {
        stopCountdown()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_: Bool) {
        makeDismissButtonVisibleWithDelay()
        startButtonAnimation()
    }

    private func makeDismissButtonVisibleWithDelay() {
        UIView.animate(withDuration: 0.5, delay: 2.7, options: [], animations: {
            self.dismissButton.alpha = 0.4
        }, completion: { _ in
            self.dismissButton.isUserInteractionEnabled = true
        })
    }

    private func refreshAll() {
        isPromo = !userHasBoughtOtherApp && salesManager.isPromoActive()

        updatePurchaseButton()
        updateFooterInfoLabel()
        loadProduct()
        fillTableInfoContent()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    private func fillTableInfoContent() {
        DispatchQueue.main.async { [self] in
            var titleString = ""
            var subtitleString = ""

            if isFirstAppStart, isPromo, !userIsAlreadyPro {
                titleString = "app.views.purchase.title.earlyDiscount".localize()
                subtitleString = "app.views.purchase.subtitle.earlyDiscount".localize()
            } else if userHasBoughtOtherApp, !userIsAlreadyPro {
                titleString = "app.views.purchase.title.discount.existingProUser".localize()
                subtitleString = "app.views.purchase.subtitle.discount.existingProUser".localize()
            } else if isPromo, !userIsAlreadyPro {
                titleString = "app.views.purchase.title.discount".localize()
                subtitleString = "app.views.purchase.subtitle.discount".localize()
            } else {
                titleString = "app.views.purchase.title".localize()
                subtitleString = "app.views.purchase.subtitle".localize()
            }

            titleLabel.text = titleString
            subTitleLabel.text = subtitleString

            titleLabel.textColor = isPromo ? UIColor(named: "defaultColor3") ?? .yellow : UIColor.white

            featureLabel1.text = "app.views.purchase.featureList.iCloud".localize()
            featureLabel2.text = "app.views.purchase.featureList.fileImport".localize()
            featureLabel3.text = "app.views.purchase.featureList.customColors".localize()
            featureLabel4.text = "app.views.purchase.featureList.unlimitedGroups".localize()
            featureLabel5.text = "app.views.purchase.featureList.otherApps".localize()
        }
    }

    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    private func setupGradients() {
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor(hexString: "#FF3B30").cgColor, UIColor(hexString: "#FF9500").cgColor]
        backgroundGradientLayer.locations = [0.0, 1.0]
        backgroundGradientLayer.frame = view.bounds

        backgroundView.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    private func loadProduct() {
        salesManager.getPackages(isFirstStart: isFirstAppStart, userIsVIP: userHasBoughtOtherApp) { [weak self] result in
            guard let self = self else { return }
            guard case let .success(data) = result else { return }
            guard case let firstPackage = data.packages.first else { return }

            self.fullPackagesList = data.packages
            self.proPackage = firstPackage
            self.proPackagePromoDeadline = data.deadline

            self.isPromo = !self.userHasBoughtOtherApp && self.salesManager.isPromoActive()
            self.updatePurchaseButton()
            self.updateFooterInfoLabel()
            self.checkForPlansPopup()
        }
    }

    private func makePurchase(package: CatPackage, isSecondaryPaywall: Bool) {
        guard !purchaseModeActive else {
            return
        }

        purchaseModeActive = true

        salesManager.makePurchase(package: package.package, isSecondaryPaywall: isSecondaryPaywall) { result in

            switch result {
            case .success:
                self.purchaseSuccess(package: package)

            case let .failure(failure):
                self.errorOccured(error: failure)
            }

            self.purchaseModeActive = false
        }
    }

    // Einkäufe wiederherstellen

    private func restorePurchases() {
        guard !purchaseModeActive else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.purchaseModeActive = true

            Purchases.shared.restorePurchases { [weak self] _, _ in
                self?.salesManager.restorePurchase { result in
                    switch result {
                    case .success:
                        self?.purchaseSuccess()
                    case let .failure(failure):
                        self?.errorOccured(error: failure)
                    }

                    self?.purchaseModeActive = false
                }
            }
        }
    }

    // Kauf oder Wiederherstellung war erfolgreich
    func purchaseSuccess(package _: CatPackage? = nil) {
        GroupedUserDefaults.set(value: true, for: .localUserInfo_userIsPro)

        GroupedUserDefaults.set(value: true, for: .localUserInfo_iCloudActivated)
        CoreDataStack.defaultStack.reinitializePersistentCloudKitContainer()

        NotificationCenter.default.post(name: Notification.Name("UserProStateChanged"), object: nil)
        WidgetCenter.shared.reloadAllTimelines()

        dismiss(animated: true, completion: nil)
    }

    func errorOccured(error: Error) {
        let rcError = error as? RevenueCat.ErrorCode
        switch rcError {
        case .purchaseNotAllowedError:
            displayErrorMessage(message: "app.views.purchase.revenueCat.error.desc.1".localize(), userCanReportBug: false)

        case .purchaseInvalidError:
            displayErrorMessage(message: "app.views.purchase.revenueCat.error.desc.2".localize(), userCanReportBug: false)

        case .networkError:
            displayErrorMessage(message: "app.views.purchase.revenueCat.error.desc.3".localize(), userCanReportBug: false)

        default:
            displayErrorMessage(message: "\(error.localizedDescription)", userCanReportBug: true)
        }
    }

    func displayErrorMessage(message: String, userCanReportBug _: Bool) {
        let alert = UIAlertController(title: "app.views.purchase.purchaseError.title".localize(), message: "app.views.purchase.purchaseError.content.%@".localize(values: message), preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        present(alert, animated: true, completion: nil)
    }

    private func updatePurchaseButton() {
        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            if self.userIsAlreadyPro {
                self.stopCountdown()
                self.buyButton.isEnabled = false
                self.buyButton.alpha = 0.5
                self.buyButton.setPrice(title: "app.views.purchase.buyButton.title.alreadyProUser".localize(), subtitle: nil)
                return
            }

            guard let proPackage = self.proPackage else {
                self.stopCountdown()
                self.buyButton.setPrice(title: "app.views.purchase.buyButton.title.loading".localize(), subtitle: nil)
                self.buyButton.alpha = 0.5
                self.buyButton.isEnabled = false
                return
            }

            self.buyButton.isEnabled = true
            self.buyButton.alpha = 1.0

            self.buyButton.setPrice(title: proPackage.buyButtonTitle, subtitle: nil, isPromo: false, originalPrice: proPackage.referenceSubscriptionPrice)

            if self.isPromo, self.proPackagePromoDeadline != nil {
                self.updateCountdown()
            } else {
                self.stopCountdown()
            }
        }
    }

    private func updateFooterInfoLabel() {
        var text = ""

        if let proPackage = proPackage {
            text = proPackage.footerLabelContent
        }

        DispatchQueue.main.async { [weak self] in
            self?.footerLabel.text = text
        }
    }

    private func checkForPlansPopup() {
        guard !GroupedUserDefaults.bool(forKey: .allPlansPromoHidden) else {
            return
        }

        guard fullPackagesList.count > 1, !CurrentUser.isUserPro() else {
            return
        }

        guard AppUsageCounter.getLogCountFor(type: .purchaseScreenOpened) > 1,
              AppUsageCounter.getLogCountFor(type: .newBirthday) > 0 ||
              AppUsageCounter.getLogCountFor(type: .contactImport) > 0 ||
              AppUsageCounter.getLogCountFor(type: .fileImport) > 0,
              let firstSeen = CurrentUser.firstSeenDate(),
              (Date().timeIntervalSince1970 - firstSeen.timeIntervalSince1970) > 250_000
        else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.showColorPopUp()
        }
    }

    private func showColorPopUp() {
        Haptic.play("o--o", delay: 0)

        infoPopUp.show(text: "app.views.purchase.allPlansPromo.title".localize(),
                       direction: .down,
                       maxWidth: view.bounds.width - 40,
                       in: view,
                       from: allPlansButton.convert(allPlansButton.frame, to: view))
    }

    private func updateCountdown() {
        coundownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            guard let title = self.proPackage?.buyButtonTitle, let deadline = self.proPackagePromoDeadline else {
                self.stopCountdown()
                return
            }

            let interval = Date(timeIntervalSince1970: deadline).timeIntervalSince(Date())
            if interval < 0 {
                timer.invalidate()
                self.isPromo = false
                self.stopCountdown()
                self.refreshAll()
                return
            }

            let countdownString = interval.toString {
                $0.maximumUnitCount = 4
                $0.locale = Locale.preferredLocale()
                $0.allowedUnits = [.day, .hour, .minute, .second]
                $0.collapsesLargestUnit = true
                $0.unitsStyle = .abbreviated
                $0.zeroFormattingBehavior = .dropLeading
            }

            self.buyButton.setPrice(title: title,
                                    subtitle: countdownString,
                                    isPromo: true,
                                    originalPrice: self.proPackage?.referenceSubscriptionPrice)
        }
    }

    private func stopCountdown() {
        coundownTimer?.invalidate()
        coundownTimer = nil
    }

    private func handleDismiss() {
        if GroupedUserDefaults.date(forKey: .localUserInfo_lastAllPlansShownDate)?.isToday ?? false {
            dismiss(animated: true, completion: nil)
            return
        }

        guard fullPackagesList.count > 0, !CurrentUser.isUserPro() else {
            dismiss(animated: true, completion: nil)
            return
        }

        GroupedUserDefaults.set(value: Date(), for: .localUserInfo_lastAllPlansShownDate)
        let currentPackageIsSubscription = proPackage?.package.packageType != .lifetime
        showAllPlans(highlightLifetimePlan: currentPackageIsSubscription)
    }

    private func showAllPlans(highlightLifetimePlan: Bool) {
        guard let allPlansView: AllPlansPurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() else {
            return
        }

        if #available(iOS 15.0, *) {
            if let presentationController = allPlansView.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                allPlansView.modalTransitionStyle = .crossDissolve
            }
        }

        allPlansView.packages = fullPackagesList
        allPlansView.promoDeadline = proPackagePromoDeadline
        allPlansView.delegate = self
        allPlansView.highlightedPackage = fullPackagesList.first(where: { $0.package.packageType == .annual })
        allPlansView.highlightLifetimePlan = highlightLifetimePlan
        present(allPlansView, animated: true)
    }

    private func handlePackageChangeFromOutside(package: CatPackage) {
        guard fullPackagesList.contains(package) else {
            return
        }

        proPackage = package
        updatePurchaseButton()
        updateFooterInfoLabel()

        makePurchase(package: package, isSecondaryPaywall: true)
    }

    @IBAction func dismissButtonClick(_: Any) {
        handleDismiss()
    }

    @IBAction func helpCenterButtonClicked(_: Any) {
        guard !purchaseModeActive else {
            return
        }
        openHelpCenterWebView()
    }

    @IBAction func allPlansButtonAction(_: Any) {
        showAllPlans(highlightLifetimePlan: false)
    }

    @IBAction func buyButtonClicked(_: Any) {
        buyButtonAction()
    }

    private func buyButtonAction() {
        guard !purchaseModeActive, let package = proPackage else {
            return
        }

        if Config.appConfiguration == .TestFlight {
            if GroupedUserDefaults.date(forKey: .TestFlightFreeTrialEndTime3) != nil {
                let alert = UIAlertController(title: "Your free trial has expired.", message: "How did you like the full version? Please share your feedback using the feedback feature in TestFlight. :)\n\nUnfortunately you can't purchase this item on a beta version. If you like Widget Studio Pro, please download the version from the App Store.\n\nThank you so much for your help!", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in }))

                present(alert, animated: true, completion: nil)
                return
            }

            let alert = UIAlertController(title: "Great! You just found the new features!", message: "Unfortunately you can't purchase this item on a beta version. To test the new features anyway, you can use this free, one-day trial.\n\nThank you so much for your help!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Start trial (5 days)", style: .default, handler: { _ in

                GroupedUserDefaults.set(value: Date() + 5.days, for: .TestFlightFreeTrialEndTime3)
                NotificationCenter.default.post(name: Notification.Name("UserProStateChanged"), object: nil)
                self.dismiss(animated: true, completion: nil)

            }))

            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in }))

            present(alert, animated: true, completion: nil)
            return
        }

        makePurchase(package: package, isSecondaryPaywall: false)
    }

    private func openHelpCenterWebView() {
        guard let helpVC: HelpCenterWebViewController = UIStoryboard(type: .purchases).instantiateViewController() else {
            return
        }

        helpVC.delegate = self
        let navController = UINavigationController(rootViewController: helpVC)
        present(navController, animated: true, completion: nil)
    }
}

extension PurchaseViewController: HelpCenterViewDelegate {
    func restoreActionRequested() {
        guard !purchaseModeActive else {
            return
        }
        restorePurchases()
    }
}

extension PurchaseViewController: AllPlansViewDelegate {
    func packageSelected(package: CatPackage) {
        handlePackageChangeFromOutside(package: package)
    }
}
