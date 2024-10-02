//
//  ImportContactsSummaryViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 30.11.20.
//

import UIKit

class ImportContactsSummaryViewController: UITableViewController {
    public var contactsToImport: [ContactPreviewViewModel] = []
    public var contactsToOverwrite: [ContactPreviewViewModel] = []

    @IBOutlet var importButton: UIBarButtonItem!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    @IBOutlet var valueLabel_group: UILabel!

    @IBOutlet var addGroupCellLabel: UILabel!

    private var groups: [GroupViewModel] = []
    private var selectedGroup: GroupViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "app.views.import.summary.title".localize()
        importButton.title = "app.views.import.summary.list.doneButton.title".localize()

        titleLabel.text = "app.views.import.summary.list.birthdaysCountLabel.%d".localize(values: contactsToImport.count + contactsToOverwrite.count)

        addGroupCellLabel.text = "app.views.import.summary.list.groupCell.title".localize()

        var subtitleText = "app.views.import.summary.list.birthdaysCountLabel.new.%d".localize(values: contactsToImport.count)

        if contactsToOverwrite.count > 0 {
            subtitleText += ", \("app.views.import.summary.list.birthdaysCountLabel.old.%d".localize(values: contactsToOverwrite.count))"
        }

        subtitleLabel.text = subtitleText

        updateTableData()

        loadGroups()
        updateGroupSelectionArea()
        
        //Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

    private func loadGroups() {
        let allGroups = GroupRepository.getAllGroups()

        groups.removeAll()
        groups = allGroups.map { GroupViewModel(group: $0) }.sorted(by: { $0.linkedBirthdaysCount > $1.linkedBirthdaysCount })
        selectedGroup = groups.first
    }

    private func updateGroupSelectionArea() {
        valueLabel_group.text = selectedGroup?.name
    }

    private func showGroupList(selectedGroup: GroupViewModel?) {
        if let groupViewController: GroupListViewController = UIStoryboard(type: .groups).instantiateViewController() {
            groupViewController.selectedGroupId = selectedGroup?.identifier
            groupViewController.groupsAreEditable = false
            groupViewController.delegate = self

            navigationController?.pushViewController(groupViewController, animated: true)
        }
    }

    private func startImport() {
        _ = BirthdayRepository.addFromPreviews(previews: contactsToImport, group: selectedGroup)

        _ = BirthdayRepository.updateFromPreviews(previews: contactsToOverwrite, group: selectedGroup)

        NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)

        if contactsToImport.count + contactsToOverwrite.count > 0 {
            AppUsageCounter.logEventFor(type: .contactImport)
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction func startImport(_: Any) {
        startImport()
    }

    func updateTableData() {}
}

extension ImportContactsSummaryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.tag == 1 {
            showGroupList(selectedGroup: selectedGroup)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ImportContactsSummaryViewController: EditGroupDelegate {
    func groupChangeCanceled() {}

    func groupChanged(group: GroupViewModel) {
        selectedGroup = group
        updateGroupSelectionArea()
    }
}
