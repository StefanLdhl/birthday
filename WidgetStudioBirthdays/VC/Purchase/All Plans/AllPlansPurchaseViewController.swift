//
//  AllPlansPurchaseViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.12.22.
//

import Haptica
import SwiftDate
import UIKit

class AllPlansPurchaseViewController: UIViewController {
    @IBOutlet var plansTableView: UITableView!
    @IBOutlet var modalDragBarView: UIView!
    @IBOutlet var countdownLabel: UILabel!
    @IBOutlet var headerCountdownView: UIView!
    @IBOutlet var headerCountdownStackView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var familySharingInfoLabel: UILabel!

    private var countdownTimer: Timer?
    private var viewAlreadyDidLayoutSubviews = false

    // Incoming
    var packages: [CatPackage] = []
    var highlightedPackage: CatPackage?
    var promoDeadline: Double?
    var highlightLifetimePlan = false
    weak var delegate: AllPlansViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        GroupedUserDefaults.set(value: true, for: .allPlansPromoHidden)
        modalDragBarView.layer.cornerRadius = 3
        modalDragBarView.clipsToBounds = true

        countdownLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)

        restartCountdown()
        titleLabel.text = highlightLifetimePlan ? "app.views.purchaseAllPlans.title.lifetimeFocus".localize() : "app.views.purchaseAllPlans.title".localize()

        familySharingInfoLabel.text = "app.views.purchaseAllPlans.footer.familySharingIinfo".localize()

        // If Lifetime is to be highlighted, set to index 0
        if highlightLifetimePlan, let lifetimePackageIndex = packages.firstIndex(where: { $0.package.packageType == .lifetime }) {
            let element = packages.remove(at: lifetimePackageIndex)
            packages.insert(element, at: 0)
        }
    }

    override func viewDidLayoutSubviews() {
        guard !viewAlreadyDidLayoutSubviews else {
            return
        }
        viewAlreadyDidLayoutSubviews = true
        setupGradientCountdown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupGradientCountdown() {
        headerCountdownStackView.isHidden = promoDeadline == nil

        headerCountdownView.layer.cornerRadius = headerCountdownView.bounds.height / 2
        headerCountdownView.clipsToBounds = true

        let backgroundGradientLayer = CAGradientLayer()

        backgroundGradientLayer.colors = [UIColor(hexString: "#B88A44").cgColor,
                                          UIColor(hexString: "#E0AA3E").cgColor,
                                          UIColor(hexString: "#E0AA3E").cgColor,
                                          UIColor(hexString: "#bb9b49").cgColor]

        backgroundGradientLayer.startPoint = CGPoint.zero
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 0)
        backgroundGradientLayer.cornerRadius = 6

        backgroundGradientLayer.frame = headerCountdownView.bounds

        headerCountdownView.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    private func restartCountdown() {
        stopCountdown()
        refreshCountdown()

        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshCountdown), userInfo: nil, repeats: true)
    }

    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    @objc func refreshCountdown() {
        guard let promoDeadline = promoDeadline else {
            stopCountdown()
            return
        }

        let interval = Date(timeIntervalSince1970: promoDeadline).timeIntervalSince(Date())

        guard interval > 0 else {
            stopCountdown()
            dismiss(animated: true)
            return
        }

        var countdownString = interval.toString {
            $0.maximumUnitCount = 4
            $0.locale = Locale.preferredLocale()
            $0.allowedUnits = [.hour, .minute, .second]
            $0.collapsesLargestUnit = true
            $0.unitsStyle = .abbreviated
            $0.zeroFormattingBehavior = .dropLeading
        }
        countdownString = countdownString.replacingOccurrences(of: " ", with: " ")

        DispatchQueue.main.async { [weak self] in
            self?.countdownLabel.text = countdownString
        }
    }

    private func handleSelectedPackage(package: CatPackage) {
        delegate?.packageSelected(package: package)
        dismiss(animated: true)
    }
}

extension AllPlansPurchaseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return packages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePlanTableViewCell", for: indexPath) as? SinglePlanTableViewCell else {
            return UITableViewCell()
        }

        guard let package = packages[safe: indexPath.row] else {
            return UITableViewCell()
        }

        cell.primaryLabel.text = package.packageName
        cell.secondaryLabel.text = package.paywallAdditionalInfo
        cell.priceLabel.text = package.purchasePriceWithPeriod
        cell.isProminent = package == highlightedPackage

        cell.priceLabel.textColor = package.referencePackage == nil ? .white : UIColor(hexString: "F9F295")

        if let trialInfo = package.trialPeriodDescription {
            let trialAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor(hexString: "F9F295"),
            ]

            let defaultAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.white,
            ]

            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(NSAttributedString(string: package.paywallAdditionalInfo + "\n", attributes: defaultAttributes))
            mutableAttributedString.append(NSAttributedString(string: trialInfo, attributes: trialAttributes))
            cell.secondaryLabel.attributedText = mutableAttributedString
        }

        if let referencePrice = package.referenceSubscriptionPrice {
            let referencePriceAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.white,
                .strikethroughStyle: 1.5,
                .strikethroughColor: UIColor.red.withAlphaComponent(0.85),
            ]
            cell.strikedPriceLabel.attributedText = NSMutableAttributedString(string: referencePrice, attributes: referencePriceAttributes)
        } else {
            cell.strikedPriceLabel.text = ""
        }

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 117
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let package = packages[safe: indexPath.row] else {
            return
        }

        Haptic.impact(.soft).generate()
        handleSelectedPackage(package: package)
    }
}

protocol AllPlansViewDelegate: AnyObject {
    func packageSelected(package: CatPackage)
}
