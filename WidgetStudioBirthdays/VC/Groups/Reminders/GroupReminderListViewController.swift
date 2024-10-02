//
//  GroupReminderListViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import UIKit

class GroupReminderListViewController: UIViewController {
    @IBOutlet var remindersTableView: UITableView!

    var reminders: [ReminderViewModel] = []
    var delegate: GroupRemindersDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        remindersTableView.tableFooterView = UIView()

        title = "app.views.remindersList.title".localize()
        
        
        // Accessibility
        remindersTableView.rowHeight = UITableView.automaticDimension
        remindersTableView.estimatedRowHeight = 58
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isHidden = false
    }

    private func addNewReminder() {
        let newEntry = ReminderViewModel(identifier: "new")
        showReminderDetails(reminder: newEntry, isNew: true)
    }

    private func showReminderDetails(reminder: ReminderViewModel, isNew: Bool = false) {
        if let groupReminderDetails: GroupReminderDetailsViewController = UIStoryboard(type: .groups).instantiateViewController() {
            groupReminderDetails.reminder = reminder
            groupReminderDetails.isNew = isNew
            groupReminderDetails.delegate = self

            let navController = UINavigationController(rootViewController: groupReminderDetails)
            present(navController, animated: true, completion: nil)
        }
    }

    private func deleteReminder(indexPath: IndexPath) {
        guard let _ = reminders[safe: indexPath.row] else {
            return
        }
        reminders.remove(at: indexPath.row)
        remindersTableView.deleteRows(at: [indexPath], with: .fade)
        delegate?.remindersChanged(reminders: reminders)
    }
}

extension GroupReminderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? reminders.count : 1
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderListTableViewCell", for: indexPath) as? ReminderListTableViewCell else {
                return UITableViewCell()
            }

            guard let reminder = reminders[safe: indexPath.row] else {
                return UITableViewCell()
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let formattedTime = formatter.string(from: reminder.time)

            cell.reminderTitleLabel.text = "\(reminder.type.localizedTitle()), \(formattedTime)"

            return cell
        }

        guard let addNewReminderCell = tableView.dequeueReusableCell(withIdentifier: "AddReminderTableViewCell", for: indexPath) as? AddReminderTableViewCell else {
            return UITableViewCell()
        }

        addNewReminderCell.infoLabel.text = "app.views.reminderList.button.addNew".localize()

        return addNewReminderCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            addNewReminder()
            return
        }

        if let reminder = reminders[safe: indexPath.row] {
            showReminderDetails(reminder: reminder)
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0, reminders.count == 0 {
            return 0.01
        }

        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0, reminders.count == 0 {
            return 15
        }

        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteReminder(indexPath: indexPath)
        }
    }
}

extension GroupReminderListViewController: EditReminderDelegate {
    func reminderEdited(reminder: ReminderViewModel, isNew: Bool) {
        if isNew {
            reminders.append(reminder)
        } else {
            if let row = reminders.firstIndex(where: { $0.identifier == reminder.identifier }) {
                reminders[row] = reminder
            }
        }

        delegate?.remindersChanged(reminders: reminders)

        remindersTableView.reloadData()
    }
}

protocol GroupRemindersDelegate {
    func remindersChanged(reminders: [ReminderViewModel])
}
