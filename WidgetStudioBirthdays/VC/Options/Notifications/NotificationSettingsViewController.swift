//
//  NotificationSettingsViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import UIKit
import UserNotifications

class NotificationSettingsViewController: UITableViewController {
    @IBOutlet var listLabel_Active: UILabel!
    @IBOutlet var listLabel_Groups: UILabel!

    @IBOutlet var listSwitch_Active: UISwitch!
    @IBOutlet var noAccessWarningView: UIView!
    @IBOutlet var noAccessWarningLabel: UILabel!

    let notificationCenter = UNUserNotificationCenter.current()

    var userGavePermisson = false
    var userHasDeactivatedNotifications = false

    override func viewDidLoad() {
        super.viewDidLoad()

        checkUserPermisson()

        noAccessWarningLabel.text = "app.views.settings.notifications.infoFooter.missingPermisson".localize()
        title = "app.views.settings.list.title.notifications".localize()

        #if DEBUG
            UNUserNotificationCenter.current().getPendingNotificationRequests { result in

                DispatchQueue.main.async {
                    self.listLabel_Active.text = "\("app.views.settings.notifications.list.title.acitvate".localize()) (\(result.count))"
                }
            }
        #else
            listLabel_Active.text = "app.views.settings.notifications.list.title.acitvate".localize()
        #endif

        listLabel_Groups.text = "app.views.settings.notifications.list.groupsCell.title".localize()

        noAccessWarningView.layer.cornerRadius = 10
        noAccessWarningView.clipsToBounds = true
        noAccessWarningView.layer.borderColor = UIColor.orange.cgColor
        noAccessWarningView.layer.borderWidth = 1

        NotificationCenter.default.addObserver(self, selector: #selector(viewWillEnterForeground), name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        tableView.delegate = self

        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
    }

    func checkUserPermisson() {
        userHasDeactivatedNotifications = GroupedUserDefaults.bool(forKey: .localUserInfo_notificationsDeactivated)

        notificationCenter.getNotificationSettings { settings in
            self.userGavePermisson = settings.authorizationStatus == .authorized
            self.refreshActivationState()
        }
    }

    @objc private func viewWillEnterForeground() {
        checkUserPermisson()
    }

    func refreshActivationState() {
        DispatchQueue.main.async {
            self.listSwitch_Active.isOn = self.userGavePermisson && !self.userHasDeactivatedNotifications
            self.noAccessWarningView.isHidden = self.userGavePermisson
            self.tableView.reloadData()
        }
    }

    func showNotAllowedAlert() {
        let alert = UIAlertController(title: "app.views.settings.notifications.alert.missingPermisson.title".localize(), message: "app.views.settings.notifications.alert.missingPermisson.content".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "app.views.settings.notifications.alert.missingPermisson.button.cancel".localize(), style: .default, handler: { _ in

        }))

        alert.addAction(UIAlertAction(title: "app.views.settings.notifications.alert.missingPermisson.button.openSettings".localize(), style: .cancel, handler: { _ in
            self.openSettings()

        }))

        present(alert, animated: true, completion: nil)
    }

    func openSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    override func viewWillDisappear(_: Bool) {
        NotificationManager.updateAllNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }

    @IBAction func notificationsActivatedChanged(_: Any) {
        if !userGavePermisson {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        self.userGavePermisson = true
                    } else {
                        self.userGavePermisson = false
                        self.showNotAllowedAlert()
                    }

                    self.checkUserPermisson()
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }   
            }
        } else {
            userHasDeactivatedNotifications = !listSwitch_Active.isOn
            saveNotificationState()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private func saveNotificationState() {
        GroupedUserDefaults.set(value: userHasDeactivatedNotifications, for: .localUserInfo_notificationsDeactivated)

        if userHasDeactivatedNotifications {
            NotificationManager.removeAllReminders()
        }
    }

    @IBAction func noAccessWarningButtonTap(_: Any) {
        openSettings()
    }
}

extension NotificationSettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.tag == 2 {
            if let groupViewController: GroupListViewController = UIStoryboard(type: .groups).instantiateViewController() {
                navigationController?.pushViewController(groupViewController, animated: true)
            }
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return userGavePermisson ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }

        return userGavePermisson && !userHasDeactivatedNotifications ? 2 : 1
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0 else {
            return nil
        }

        var footerText = "app.views.settings.notifications.sectionFooter.text".localize()
        if userGavePermisson, !userHasDeactivatedNotifications {
            footerText = "\(footerText) \("app.views.settings.notifications.list.groupsCell.sectionFooter.text".localize())"
        }

        return footerText
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
