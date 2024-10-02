//
//  AboutTableViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import Haptica
import UIKit

class AboutTableViewController: UITableViewController {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var thankYouTextLabel: UILabel!
    @IBOutlet var supportUsLabel: UILabel!
    @IBOutlet var moreAppsLabel: UILabel!
    @IBOutlet var showLibrariesLabel: UILabel!
    @IBOutlet var proUserThankYouLabel: UILabel!
    // @IBOutlet var crashReportsLabel: UILabel!

    // @IBOutlet var crashReportsSwitch: UISwitch!

    private var userIsPro = CurrentUser.isUserPro()

    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.text = "app.views.settings.about.headline".localize()
        thankYouTextLabel.text = "app.views.settings.about.thankyouText".localize()
        supportUsLabel.text = "app.views.settings.aboutt.list.supportUs".localize()
        showLibrariesLabel.text = "app.views.settings.aboutt.list.libraries".localize()
        proUserThankYouLabel.text = "app.views.settings.aboutt.proUserText".localize()
        moreAppsLabel.text = "app.views.settings.aboutt.list.moreApp".localize()

        // crashReportsLabel.text = "app.views.settings.about.crashReportText".localize()
        NotificationCenter.default.addObserver(self, selector: #selector(userProStateChanged), name: Notification.Name("UserProStateChanged"), object: nil)

        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 53

        // crashReportsSwitch.setOn(Crashlytics.crashlytics().isCrashlyticsCollectionEnabled(), animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 8, right: 0)
    }

    @objc private func userProStateChanged() {
        userIsPro = CurrentUser.isUserPro()
        tableView.reloadData()
    }

    @IBAction func thankYouCellTap(_: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            Haptic.impact(.medium).generate()
            let confettiView = ConfettiView()
            self.view.addSubview(confettiView)

            confettiView.emit(with: [
                .text("🧡", 8, nil),
                .text("💙", 8, nil)


            ], for: 3) { _ in
                confettiView.removeFromSuperview()
            }
        }
    }

    @IBAction func crashReportSwitchAction(_: Any) {
        // Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(crashReportsSwitch.isOn)
    }

    @IBAction func dismissButtonClick(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func openPurchaseScreen() {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            purchaseScreen.activeTap = true
            Haptic.impact(.light).generate()
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    private func openAppStoreDev() {
        if let url = URL(string: "https://apps.apple.com/us/developer/stefan-liesendahl/id820491345") {
            UIApplication.shared.open(url)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.tag == 1 {
            openPurchaseScreen()
        }

        if cell.tag == 2 {
            openAppStoreDev()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return userIsPro ? 1 : 2
        }

        if section == 3 {
            return userIsPro ? 1 : 0
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2, userIsPro {
            return 0.1
        }

        if section == 3, !userIsPro {
            return 0.1
        }

        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2, userIsPro {
            return 0.1
        }

        if section == 3, !userIsPro {
            return 0.1
        }

        return super.tableView(tableView, heightForFooterInSection: section)
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
