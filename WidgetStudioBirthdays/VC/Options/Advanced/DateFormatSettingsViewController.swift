//
//  DateFormatSettingsViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 14.01.21.
//

import UIKit

class DateFormatSettingsViewController: UIViewController {
    public var customDateFormatTypes: [CustomDateFormatType] = []
    public var selectedCustomType: CustomDateFormatType?

    @IBOutlet var formatsTableView: UITableView!

    let currentLocale = Locale.preferredLocale()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let customFormatId = GroupedUserDefaults.string(forKey: .crossDeviceUserInfo_customDateFormattingId), let customFormat = CustomDateFormatType(rawValue: customFormatId) {
            selectedCustomType = customFormat
        }

        customDateFormatTypes = CustomDateFormatType.allCases
        formatsTableView.tableFooterView = UIView()
        title = "app.views.settings.advanced.list.dateFormat".localize()

        // Accessibility
        formatsTableView.rowHeight = UITableView.automaticDimension
        formatsTableView.estimatedRowHeight = 53
    }
}

extension DateFormatSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return customDateFormatTypes.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateFromatSettingsListTableViewCell", for: indexPath) as? DateFromatSettingsListTableViewCell else {
            return UITableViewCell()
        }

        let dateFormatter = DateFormatter()

        if indexPath.row == 0 {
            dateFormatter.locale = Locale.preferredLocale()
            dateFormatter.dateStyle = .medium

            cell.itemTextLabel.text = "app.views.settings.advanced.dateFormat.auto".localize()
            cell.itemExampleLabel.text = dateFormatter.string(from: Date())
            cell.itemTextLabel.textColor = .systemBlue
            cell.accessoryType = selectedCustomType == nil ? .checkmark : .none
            return cell
        }

        let realIndexRow = indexPath.row - 1

        guard let item = customDateFormatTypes[safe: realIndexRow] else {
            return UITableViewCell()
        }

        cell.accessoryType = selectedCustomType == item ? .checkmark : .none

        let formatWithYear = item.getFormat().withYear
        dateFormatter.dateFormat = formatWithYear

        cell.itemTextLabel.text = "\(formatWithYear)"
        cell.itemExampleLabel.text = "\(dateFormatter.string(from: Date()))"
        cell.itemTextLabel.textColor = .label

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedCustomType = nil
            GroupedUserDefaults.removeObject(forKey: .crossDeviceUserInfo_customDateFormattingId)
        } else {
            let realIndexRow = indexPath.row - 1

            guard let selectedItem = customDateFormatTypes[safe: realIndexRow] else {
                return
            }

            GroupedUserDefaults.set(value: selectedItem.rawValue, for: .crossDeviceUserInfo_customDateFormattingId)
            selectedCustomType = selectedItem
        }

        formatsTableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)
        navigationController?.popViewController(animated: true)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
