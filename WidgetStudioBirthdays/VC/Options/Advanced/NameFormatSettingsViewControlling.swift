//
//  NameFormatSettingsViewControlling.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 04.02.21.
//

import UIKit

class NameFormatSettingsViewController: UIViewController {
    public var nameFormattingTypes: [String] = []
    @IBOutlet var formatsTableView: UITableView!

    private var showLastNameFirst = false
    override func viewDidLoad() {
        super.viewDidLoad()

        nameFormattingTypes.append("app.views.settings.advanced.nameFormatting.list.firstLast".localize())
        nameFormattingTypes.append("app.views.settings.advanced.nameFormatting.list.lastFirst".localize())

        showLastNameFirst = GroupedUserDefaults.bool(forKey: .localUserInfo_nameFormatShowLastNameFirst)
        formatsTableView.tableFooterView = UIView()
        title = "app.views.settings.advanced.list.nameFormat".localize()
        
        // Accessibility
        formatsTableView.rowHeight = UITableView.automaticDimension
        formatsTableView.estimatedRowHeight = 53
    }
}

extension NameFormatSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return nameFormattingTypes.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NameFormatSettingsListTableViewCell", for: indexPath) as? NameFormatSettingsListTableViewCell else {
            return UITableViewCell()
        }

        if showLastNameFirst && indexPath.row == 1 || !showLastNameFirst && indexPath.row == 0 {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.itemTextLabel.text = nameFormattingTypes[safe: indexPath.row]

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLastNameFirst = indexPath.row == 1
        GroupedUserDefaults.set(value: showLastNameFirst, for: .localUserInfo_nameFormatShowLastNameFirst)

        formatsTableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
