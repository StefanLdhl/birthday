//
//  CloudSettingsViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import Haptica
import MessageUI
import ProgressHUD
import UIKit
import Zip

class CloudSettingsViewController: UITableViewController {
    private var iCloudActivated = false
    private var userIsPro = false

    @IBOutlet var descLabel_iCloud: UILabel!
    @IBOutlet var descLabel_SendBugReport: UILabel!
    @IBOutlet var descLabel_Report: UILabel!
    @IBOutlet var descLabel_Delete: UILabel!

    @IBOutlet var reportTableViewCell: UITableViewCell!

    @IBOutlet var icloudEnabledSwitch: UISwitch!

    private var exportURL: URL? {
        do {
            let fileManager = FileManager()
            let documentsDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let exportPath = documentsDirectoryURL.appendingPathComponent("ExportFiles")

            // Alten Order löschen
            if fileManager.fileExists(atPath: exportPath.path) {
                try fileManager.removeItem(at: exportPath)
            }

            // Neu anlegen
            try fileManager.createDirectory(atPath: exportPath.path, withIntermediateDirectories: true, attributes: nil)

            return exportPath
        } catch {
            return nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        descLabel_iCloud.text = "app.views.settings.iCloud.activateSwitch.title".localize()
        descLabel_SendBugReport.text = "app.views.settings.iCloud.problem.title".localize()
        descLabel_Report.text = "app.views.settings.iCloud.report.title".localize()
        descLabel_Delete.text = "app.views.settings.iCloud.delete.title".localize()

        refreshState()

        ProgressHUD.animationType = .activityIndicator

        NotificationCenter.default.addObserver(forName: Notification.Name("UserProStateChanged"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async { [weak self] in
                self?.refreshState()
            }
        }

        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
    }

    private func refreshState() {
        iCloudActivated = GroupedUserDefaults.bool(forKey: .localUserInfo_iCloudActivated)
        userIsPro = CurrentUser.isUserPro()

        icloudEnabledSwitch.setOn(iCloudActivated, animated: false)
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 10, right: 0)
    }

    private func deleteAllFromCloud() {
        GroupedUserDefaults.set(value: false, for: .localUserInfo_iCloudActivated)
        iCloudActivated = false

        refreshState()
        CoreDataStack.defaultStack.deleteContainer()
    }

    private func openProblemMail() {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let device = UIDevice.modelName

        let mailcontent = "\("app.views.settings.iCloud.problem.mail.prefix".localize())\n\n\n---\nOS: \(systemVersion)\nApp: \(appVersion)\nDevice: \(device)"

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@cranberry.app"])
            mail.setSubject("Problem with iCloud Sync")
            mail.setMessageBody(mailcontent, isHTML: false)

            present(mail, animated: true, completion: nil)
        } else {
            guard let url = URL(string: "https://cranberry.app/contact") else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func deleteAll() {
        let alert = UIAlertController(title: "app.views.settings.iCloud.delete.title".localize(), message: "app.views.settings.iCloud.delete.alert.desc".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "app.views.settings.iCloud.delete.alert.ok".localize(), style: .destructive, handler: { [weak self] _ in

            CoreDataStack.defaultStack.deleteContainer()
            self?.iCloudActivated = false
            GroupedUserDefaults.set(value: self?.iCloudActivated, for: .localUserInfo_iCloudActivated)
            self?.refreshState()
            CoreDataStack.defaultStack.reinitializePersistentCloudKitContainer()

        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in

        }))

        present(alert, animated: true, completion: nil)
    }

    private func processError(content: String) {
        let message = "The request could not be processed.\n\(content)\n\nIf this error occurs again, please file a bug report."

        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in

        }))

        present(alert, animated: true, completion: nil)

        ProgressHUD.dismiss()
    }

    private func getCloudReport() {
        ProgressHUD.show("Creating report", interaction: false)

        guard let exportPath = exportURL else {
            processError(content: "Missing path.")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in

            let birthdays = BirthdayRepository.getAllDataAsDictionary()
            let birthdaysImageDataArray = birthdays.imageData

            let birthdaysDataArray = birthdays.content
            let groupsDataArray = GroupRepository.getAllDataAsDictionary()
            let remindersDataArray = ReminderRepository.getAllDataAsDictionary()
            let messagesDataArray = MessageRepository.getAllDataAsDictionary()

            var allDataDict: [String: [[String: String]]] = [:]
            allDataDict["birthdays"] = birthdaysDataArray
            allDataDict["groups"] = groupsDataArray
            allDataDict["reminders"] = remindersDataArray
            allDataDict["messages"] = messagesDataArray

            // Bilder
            for (i, imageData) in birthdaysImageDataArray.enumerated() {
                do {
                    try imageData.write(to: exportPath.appendingPathComponent("contactPic_\(i).png"))
                } catch {
                    print("error saving file with error", error)
                }
            }

            // Inhalte
            let encoder = JSONEncoder()

            guard let jsonData = try? encoder.encode(["data": allDataDict]) else {
                self?.processError(content: "Error creating json file.")
                return
            }

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let fileURL = exportPath.appendingPathComponent("content.json")
                do {
                    try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)

                } catch {
                    self?.processError(content: "Error writing json file.")
                    return
                }
            }

            // Zip
            do {
                let zipFilePath = try Zip.quickZipFiles([exportPath], fileName: "WidgetStudioCloudExport")
                self?.openActivityVC(fileUrl: zipFilePath)
            } catch {
                self?.processError(content: "Zip error.")
            }
            ProgressHUD.dismiss()
        }
    }

    func openActivityVC(fileUrl: URL) {
        let items = [fileUrl]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)

        ac.popoverPresentationController?.sourceView = reportTableViewCell

        present(ac, animated: true)
    }

    @IBAction func icloudEnabledStateChanged(_: Any) {
        if !userIsPro {
            iCloudActivated = false
            icloudEnabledSwitch.setOn(false, animated: true)
            openPurchaseScreen()
            return
        }

        iCloudActivated = icloudEnabledSwitch.isOn
        GroupedUserDefaults.set(value: iCloudActivated, for: .localUserInfo_iCloudActivated)

        CoreDataStack.defaultStack.reinitializePersistentCloudKitContainer()

        tableView.reloadData()
    }

    private func openPurchaseScreen() {
        Haptic.impact(.light).generate()

        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return iCloudActivated ? "app.views.settings.iCloud.description.Activated".localize() : "app.views.settings.iCloud.description.Deactivated".localize()
        }

        if section == 2, iCloudActivated {
            return "app.views.settings.iCloud.report.desc".localize()
        }

        if section == 3, iCloudActivated {
            return "app.views.settings.iCloud.problem.desc".localize()
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.tag == 2 {
            openProblemMail()
        }

        if cell.tag == 3 {
            deleteAll()
        }

        if cell.tag == 4 {
            getCloudReport()
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return iCloudActivated ? 2 : 0
        }

        if section == 3 {
            return iCloudActivated ? 1 : 0
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CloudSettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error _: Error?) {
        if result.rawValue == MFMailComposeResult.sent.rawValue || result.rawValue == MFMailComposeResult.saved.rawValue {
            _ = navigationController?.popViewController(animated: true)
        }

        controller.dismiss(animated: true, completion: nil)
    }
}
