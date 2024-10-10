//
//  OptionsTableViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import MessageUI
import SwiftUI
import UIKit

class OptionsTableViewController: UITableViewController {
    @IBOutlet var footerLabel1: UILabel!
    @IBOutlet var footerLabel2: UILabel!

    @IBOutlet var listLabel_Notifications: UILabel!
    @IBOutlet var listLabel_PrivacyPolicy: UILabel!
    @IBOutlet var listLabel_Twitter: UILabel!
    @IBOutlet var listLabel_Insta: UILabel!
    @IBOutlet var listLabel_Support: UILabel!
    @IBOutlet var listLabel_advancedSettings: UILabel!
    @IBOutlet var listLabel_groups: UILabel!
    @IBOutlet var listLabel_messages: UILabel!
    @IBOutlet var listLabel_supportUs: UILabel!
    @IBOutlet var listLabel_about: UILabel!
    @IBOutlet var listLabel_exportCsv: UILabel!
    @IBOutlet var listLabel_removeDuplicates: UILabel!
    @IBOutlet var listLabel_terms: UILabel!

    @IBOutlet var listLabel_appStoreReview: UILabel!
    @IBOutlet var exportCsvLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var doneButton: UIBarButtonItem!

    @IBOutlet var listLabelDetails_messages: UILabel!
    @IBOutlet var listLabelDetails_groups: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "app.views.settings.title".localize()

        listLabel_Support.text = "app.views.settings.list.title.support".localize()
        listLabel_Twitter.text = "Twitter"
        listLabel_Insta.text = "Instagram"

        listLabel_PrivacyPolicy.text = "app.views.settings.list.title.privacyPolicy".localize()
        listLabel_advancedSettings.text = "app.views.settings.list.title.advancedSettings".localize()
        listLabel_groups.text = "app.views.settings.list.title.groups".localize()
        listLabel_messages.text = "app.views.settings.list.title.messages".localize()
        listLabel_Notifications.text = "app.views.settings.list.title.notifications".localize()

        listLabel_supportUs.text = "app.views.settings.list.title.purchase".localize()
        listLabel_about.text = "app.views.settings.list.title.about".localize()

        listLabelDetails_groups.text = "app.views.settings.list.title.groups.subtitle".localize()
        listLabelDetails_messages.text = "app.views.settings.list.title.messages.subtitle".localize()
        listLabel_exportCsv.text = "app.views.settings.list.title.exportBirthdays".localize()
        listLabel_removeDuplicates.text = "app.views.settings.list.title.removeDuplicates".localize()
        listLabel_appStoreReview.text = "app.views.settings.list.title.appStoreReview".localize()
        listLabel_terms.text = "app.views.settings.list.title.terms".localize()

        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 11, right: 0)

        updateFooterLabel()

        NotificationCenter.default.addObserver(self, selector: #selector(userProStateChanged), name: Notification.Name("UserProStateChanged"), object: nil)

        doneButton.title = "main.universal.done".localize()

        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
    }

    private func updateFooterLabel() {
        let year = Calendar.current.component(.year, from: Date())
        var footerText1 = "Widget Studio \(year)"

        if CurrentUser.isUserPro() {
            if CurrentUser.userHasLifetimeAccess() {
                footerText1 += " | Pro 👑 (Lifetime)"
            } else {
                footerText1 += " | Pro 👑"
            }
        }

        var footerText2 = ""

        if let version = Bundle.main.releaseVersionNumber {
            footerText2 = "v.\(version)"
        }

        footerLabel1.text = footerText1
        footerLabel2.text = footerText2
    }

    @objc private func userProStateChanged() {
        tableView.reloadData()
        updateFooterLabel()
    }

    override func viewWillAppear(_: Bool) {
        tableView.reloadData()
    }

    @IBAction func close(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 11, right: 0)
    }

    private func openTwitter() {
        AppUsageCounter.logEventFor(type: .twitterInterest)
        guard let url = URL(string: "https://twitter.com/andremartingo") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func openInsta() {
        AppUsageCounter.logEventFor(type: .instaInterest)

        guard let url = URL(string: "https://instagram.com/widgetstudio") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func openTerms() {
        guard let url = URL(string: "https://martingo.studio/terms") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func openPrivacyPolicy() {
        AppUsageCounter.logEventFor(type: .privacyPolicyOpened)

        guard let url = URL(string: "https://martingo.studio/privacy") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func openFAQ() {
        if let faqView: FAQViewController = UIStoryboard(type: .options).instantiateViewController() {
            navigationController?.pushViewController(faqView, animated: true)
        }
    }

    private func openPurchaseScreen() {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            purchaseScreen.activeTap = true

            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    private func openAboutScreen() {
        if let aboutView: AboutTableViewController = UIStoryboard(type: .options).instantiateViewController() {
            present(aboutView, animated: true, completion: nil)
        }
    }

    private func openiCloudSettings() {
        if let iCloudSettings: CloudSettingsViewController = UIStoryboard(type: .options).instantiateViewController() {
            navigationController?.pushViewController(iCloudSettings, animated: true)
        }
    }

    private func openAdvancedSettings() {
        if let iCloudSettings: AdvancedSettingsTableViewController = UIStoryboard(type: .options).instantiateViewController() {
            navigationController?.pushViewController(iCloudSettings, animated: true)
        }
    }

    private func openNotificationSettings() {
        if let notificationSettingsController: NotificationSettingsViewController = UIStoryboard(type: .options).instantiateViewController() {
            navigationController?.pushViewController(notificationSettingsController, animated: true)
        }
    }

    private func openAppStoreReviewPage() {
        let alert = UIAlertController(title: "app.views.settings.list.title.appStoreReview".localize(), message: "app.views.settings.list.appStoreReview.alert.content".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "app.views.settings.list.appStoreReview.alert.alreadyDone".localize(), style: .default, handler: { [weak self] _ in
            self?.showAppStoreReviewThankYouAlert()
            hideSection()
        }))

        alert.addAction(UIAlertAction(title: "app.views.settings.list.appStoreReview.alert.criticism".localize(), style: .default, handler: { [weak self] _ in
            self?.openMail()
            hideSection()
        }))

        alert.addAction(UIAlertAction(title: "app.views.settings.list.appStoreReview.alert.openStore".localize(), style: .cancel, handler: { [weak self] _ in

            AppUsageCounter.logEventFor(type: .appStoreReview)

            guard let url = URL(string: "https://apps.apple.com/de/app/geburtstags-app-widget/id1550516996?action=write-review") else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self?.showAppStoreReviewThankYouAlert()
            hideSection()

        }))

        present(alert, animated: true, completion: nil)

        func hideSection() {
            GroupedUserDefaults.set(value: true, for: .crossDeviceUserInfo_userWroteReview)
            tableView.reloadData()
        }
    }

    private func showAppStoreReviewThankYouAlert() {
        let alert = UIAlertController(title: "app.views.settings.list.appStoreReview.alert.done.thanksYou".localize(), message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "main.universal.done".localize(), style: .cancel, handler: { _ in }))

        present(alert, animated: true, completion: nil)
    }

    private func openMail() {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let device = UIDevice.modelName

        let mailcontent = "\n\n\n---\nOS: \(systemVersion)\nApp: \(appVersion)\nDevice: \(device)"

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@martingo.studio"])
            mail.setSubject("app.feedbackMail.subject".localize())
            mail.setMessageBody(mailcontent, isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            guard let url = URL(string: "https://martingo.studio") else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func openManual() {
        let urlString: String = {
            if "app.appCountryCode".localize() == "DE" {
                return "https://support.apple.com/de-de/HT207122"
            } else {
                return "https://support.apple.com/en-us/HT207122"
            }
        }()

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func openRemoveDuplicatesView() {
        if let removeDuplicatesNavView: RemoveDuplicatesNavigationController = UIStoryboard(type: .options).instantiateViewController() {
            present(removeDuplicatesNavView, animated: true, completion: nil)
        }
    }

    private func openGroups() {
        if let groupViewController: GroupListViewController = UIStoryboard(type: .groups).instantiateViewController() {
            navigationController?.pushViewController(groupViewController, animated: true)
        }
    }

    private func openMessages() {
        if let messagesViewController: MessagesListViewController = UIStoryboard(type: .messages).instantiateViewController() {
            navigationController?.pushViewController(messagesViewController, animated: true)
        }
    }

    private func showErrorAlert(title: String, content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .cancel, handler: { _ in }))
        present(alert, animated: true, completion: nil)
    }

    private func startBirthdayExport(cell: UITableViewCell, sorting: CsvExporterSort) {
        guard let fileUrl = CsvEporter.exportAllBirthdays(sortBy: sorting) else {
            showErrorAlert(title: "app.views.settings.list.title.exportBirthdays".localize(), content: "app.views.settings.exportBirthdays.error.content.otherError".localize())
            return
        }

        guard CurrentUser.isUserPro() else {
            openPurchaseScreen()
            return
        }

        exportCsvLoadingIndicator.startAnimating()

        let items = [fileUrl]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [self] in
            ac.popoverPresentationController?.sourceView = cell
            present(ac, animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [self] in
            exportCsvLoadingIndicator.stopAnimating()
        }
    }

    private func exportBirthdays(cell: UITableViewCell) {
        let alertTitle = "app.views.settings.exportBirthdays.sortingAlert.title".localize()
        let alertContent = "app.views.settings.exportBirthdays.sortingAlert.desc".localize()

        var alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .actionSheet)

        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .alert)
        }

        alert.addAction(UIAlertAction(title: "app.views.settings.exportBirthdays.sortingAlert.sorting.birthday".localize(), style: .default, handler: { _ in
            self.startBirthdayExport(cell: cell, sorting: .birthday)

        }))

        alert.addAction(UIAlertAction(title: "app.views.settings.exportBirthdays.sortingAlert.sorting.firstName".localize(), style: .default, handler: { _ in
            self.startBirthdayExport(cell: cell, sorting: .firstName)

        }))

        alert.addAction(UIAlertAction(title: "app.views.settings.exportBirthdays.sortingAlert.sorting.lastName".localize(), style: .default, handler: { _ in
            self.startBirthdayExport(cell: cell, sorting: .lastName)

        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in }))

        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.tag == 1 {
            openTwitter()
        }

        if cell.tag == 3 {
            openPrivacyPolicy()
        }

        if cell.tag == 4 {
            openManual()
        }

        if cell.tag == 5 {
            openNotificationSettings()
        }

        if cell.tag == 6 {
            openGroups()
        }

        if cell.tag == 7 {
            openAdvancedSettings()
        }

        if cell.tag == 8 {
            openPurchaseScreen()
        }

        if cell.tag == 9 {
            openAboutScreen()
        }

        if cell.tag == 10 {
            openInsta()
        }

        if cell.tag == 15 {
            openiCloudSettings()
        }

        if cell.tag == 16 {
            openMessages()
        }

        if cell.tag == 17 {
            openFAQ()
        }

        if cell.tag == 20 {
            exportBirthdays(cell: cell)
        }

        if cell.tag == 21 {
            openRemoveDuplicatesView()
        }

        if cell.tag == 22 {
            openAppStoreReviewPage()
        }

        if cell.tag == 30 {
            openTerms()
        }
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return CurrentUser.isUserPro() ? 0 : 1
        }

        if section == 3 {
            return ((GroupedUserDefaults.integer(forKey: .localUserInfo_usersLastStarRating) == 5) && !GroupedUserDefaults.bool(forKey: .crossDeviceUserInfo_userWroteReview)) ? 2 : 1
        }

        if section == 5, !SessionState.shared.databaseHasPossibleDuplicateEntries {
            return 0
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2, CurrentUser.isUserPro() {
            return 0.1
        }

        if section == 5, !SessionState.shared.databaseHasPossibleDuplicateEntries {
            return 0.1
        }

        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2, CurrentUser.isUserPro() {
            return 0.1
        }

        if section == 5, !SessionState.shared.databaseHasPossibleDuplicateEntries {
            return 0.1
        }

        return super.tableView(tableView, heightForFooterInSection: section)
    }
}

extension OptionsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

final class HostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.setNeedsUpdateConstraints()
    }
}
