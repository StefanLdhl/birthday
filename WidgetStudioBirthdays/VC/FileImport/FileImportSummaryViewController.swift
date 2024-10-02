//
//  FileImportSummaryViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.01.21.
//

import ProgressHUD
import UIKit

class FileImportSummaryViewController: UITableViewController {
    public var previewsToImport: [FileImportContactPreviewViewModel]!
    public var fileName: String = ""

    @IBOutlet var importButton: UIBarButtonItem!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    @IBOutlet var valueLabel_group: UILabel!

    @IBOutlet var addGroupCellLabel: UILabel!

    private var groups: [GroupViewModel] = []
    private var selectedGroup: GroupViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "app.views.fileImportSummary.header.title.%d".localize(values: previewsToImport.count)
        subtitleLabel.text = "\(fileName)"

        title = "app.views.fileImportSummary.title".localize()
        importButton.title = "app.views.import.summary.list.doneButton.title".localize()

        addGroupCellLabel.text = "app.views.import.summary.list.groupCell.title".localize()

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
        if previewsToImport.count > 0 {
            AppUsageCounter.logEventFor(type: .fileImport)
        }

        ProgressHUD.show(nil, interaction: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = BirthdayRepository.addFromFileImportPreviews(previews: self.previewsToImport, group: self.selectedGroup, fileName: self.fileName)
            NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ProgressHUD.showSucceed()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func startImport(_: Any) {
        startImport()
    }
}

extension FileImportSummaryViewController {
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

extension FileImportSummaryViewController: EditGroupDelegate {
    func groupChangeCanceled() {}

    func groupChanged(group: GroupViewModel) {
        selectedGroup = group
        updateGroupSelectionArea()
    }
}
