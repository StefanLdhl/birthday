//
//  GroupReminderDetailSelectionListViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import UIKit

class GroupReminderDetailTypeListViewController: UIViewController {
    public var types: [ReminderType] = ReminderType.allCases
    public var selectedType: ReminderType!
    public var delegate: ReminderDetailSelectionDelegate?

    @IBOutlet var typesTableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()

        typesTableView.tableFooterView = UIView()
        title = "app.views.reminderEditor.list.types.title".localize()
    }
    
    @IBAction func doneAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension GroupReminderDetailTypeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return types.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddReminderDetailListTableViewCell", for: indexPath) as? AddReminderDetailListTableViewCell else {
            return UITableViewCell()
        }

        guard let item = types[safe: indexPath.row] else {
            return UITableViewCell()
        }

        cell.itemTextLabel.text = item.localizedTitle()
        cell.accessoryType = item.rawValue == selectedType.rawValue ? .checkmark : .none
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedItem = types[safe: indexPath.row] else {
            return
        }
        selectedType = selectedItem
        delegate?.selectedTypeChanged(type: selectedItem)
        typesTableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}
