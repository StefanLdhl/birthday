//
//  GroupListViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 02.12.20.
//

import Haptica
import UIKit

class GroupListViewController: UIViewController {
    @IBOutlet var groupsTableView: UITableView!

    private var groups: [GroupViewModel] = []

    public var groupsAreEditable: Bool = true
    public var delegate: EditGroupDelegate?
    public var selectedGroupId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadGroups()

        title = "app.views.groups.title".localize()
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)

        // reloadGroups()

        // Accessibility
        groupsTableView.rowHeight = UITableView.automaticDimension
        groupsTableView.estimatedRowHeight = 58
    }

    private func reloadGroups() {
        let groupModels = GroupRepository.getAllGroups()
        groups = groupModels.map { GroupViewModel(group: $0) }.sorted(by: { $0.linkedBirthdaysCount == $1.linkedBirthdaysCount ? $0.name.lowercased() < $1.name.lowercased() : $0.linkedBirthdaysCount > $1.linkedBirthdaysCount })

        // SelectedID ggf. nil setzen, wenn nicht gefunden
        selectedGroupId = selectedGroupId == nil ? selectedGroupId : (groups.filter { $0.identifier == selectedGroupId }.count == 0) ? nil : selectedGroupId

        groupsTableView.reloadData()
    }

    private func openPurchaseScreen() {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            Haptic.impact(.light).generate()
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    private func addNewGroup() {
        if !CurrentUser.isUserPro(), groups.count >= 2 {
            openPurchaseScreen()
            return
        }

        Haptic.impact(.light).generate()
        let alertController = UIAlertController(title: "app.views.groupList.button.addNew".localize(), message: "", preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = "app.views.groupList.addNewDialog.placeholder".localize()
        }

        let saveAction = UIAlertAction(title: "main.universal.save".localize(), style: .default, handler: { _ in

            if let textfields = alertController.textFields {
                let defaultGroupName = "app.views.groupList.addNewDialog.defaultGroupName".localize()

                let text = textfields[safe: 0]?.text ?? defaultGroupName
                self.createEmptyGroup(name: text.count == 0 ? defaultGroupName : text)
            }

        })

        alertController.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in }))

        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }

    private func createEmptyGroup(name: String) {
        let newGroup = GroupRepository.addNewGroup(name: name)
        selectedGroupId = newGroup.identifier

        reloadGroups()

        if let selectedGroup = groups.filter({ $0.identifier == newGroup.identifier }).first {
            delegate?.groupChanged(group: selectedGroup)
        }
    }

    private func openDetailsFor(group: GroupViewModel) {
        if isEventReadOnly(group: group), !CurrentUser.isUserPro() {
            openPurchaseScreen()
            return
        }

        Haptic.impact(.light).generate()
        if let detailsNavController: GroupDetailNavigationViewController = UIStoryboard(type: .groups).instantiateViewController() {
            if let groupViewController = detailsNavController.viewControllers.first as? GroupDetailViewController {
                groupViewController.group = group
                groupViewController.delegate = self
                present(detailsNavController, animated: true, completion: nil)
            }
        }
    }

    private func safeDeleteGroup(indexPath: IndexPath) {
        guard let groupToDelete = groups[safe: indexPath.row] else {
            return
        }

        let otherGroups = groups.filter { $0.identifier != groupToDelete.identifier }

        // If last group
        if otherGroups.count == 0 {
            groupsTableView.isEditing = false
            let alert = UIAlertController(title: "app.views.groupList.lastGroupAlert.title".localize(), message: "app.views.groupList.lastGroupAlert.desc".localize(), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .cancel, handler: { _ in

            }))

            present(alert, animated: true, completion: nil)
            return
        }

        // If no birthday linked
        if groupToDelete.linkedBirthdaysCount == 0 {
            removeGroup(indexPath: indexPath, identifier: groupToDelete.identifier)
            return
        }

        let alertTitle = "app.views.groupList.moveEntriesAlert.title".localize()
        let alertContent = "app.views.groupList.moveEntriesAlert.desc.%@.%d".localize(values: groupToDelete.name, groupToDelete.linkedBirthdaysCount)

        var alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .actionSheet)
        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .alert)
        }

        for otherGroup in otherGroups {
            alert.addAction(UIAlertAction(title: "\(otherGroup.name)".localize(), style: .default, handler: { _ in

                self.removeGroup(indexPath: indexPath, identifier: groupToDelete.identifier, newGroupId: otherGroup.identifier)
            }))
        }
        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }

    private func removeGroup(indexPath: IndexPath, identifier: String, newGroupId: String? = nil) {
        groups.remove(at: indexPath.row)
        GroupRepository.deleteGroup(identifier: identifier, moveItemsToGroupWithID: newGroupId)
        groupsTableView.deleteRows(at: [indexPath], with: .fade)

        NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)

        reloadGroups()
    }

    private func isEventReadOnly(group: GroupViewModel) -> Bool {
        guard !CurrentUser.isUserPro() else {
            return false
        }
        let sortedEvents = groups.sorted(by: { $0.creationDate < $1.creationDate })
        let index = sortedEvents.firstIndex(of: group) ?? 0
        let isReadonly = index > 1
        return isReadonly
    }
}

extension GroupListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? groups.count : 1
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath) as? GroupTableViewCell else {
                return UITableViewCell()
            }

            let group = groups[indexPath.row]
            cell.nameLabel.text = group.name

            let subtitle = group.linkedBirthdaysCount == 1 ? "app.views.groupList.cell.subtitle.singular".localize() : "app.views.groupList.cell.subtitle.plural.%d".localize(values: group.linkedBirthdaysCount)
            let groupIsReadonly = isEventReadOnly(group: group)

            cell.subtitleLabel.text = subtitle + (groupIsReadonly ? " | \("app.views.list.cell.readonly.info".localize())" : "")

            cell.accessoryType = groupsAreEditable ? .disclosureIndicator : (group.identifier == selectedGroupId ? .checkmark : .none)

            cell.circularGadientView.updateGradient(gradient: group.colorGradient)

            return cell
        }

        guard let addNewGroupCell = tableView.dequeueReusableCell(withIdentifier: "AddGroupTableViewCell", for: indexPath) as? AddGroupTableViewCell else {
            return UITableViewCell()
        }

        addNewGroupCell.infoLabel.text = "app.views.groupList.button.addNew".localize()

        return addNewGroupCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            addNewGroup()
            return
        }

        guard let selectedGroup = groups[safe: indexPath.row] else {
            return
        }

        guard !groupsAreEditable else {
            openDetailsFor(group: selectedGroup)
            return
        }

        selectedGroupId = selectedGroup.identifier
        groupsTableView.reloadData()

        delegate?.groupChanged(group: selectedGroup)
        navigationController?.popViewController(animated: true)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0, groups.count == 0 {
            return 0.01
        }

        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0, groups.count == 0 {
            return 15
        }

        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return groupsAreEditable
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            safeDeleteGroup(indexPath: indexPath)
        }
    }
}

extension GroupListViewController: EditGroupDelegate {
    func groupChangeCanceled() {
        reloadGroups()
    }

    func groupChanged(group _: GroupViewModel) {
        reloadGroups()
        NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)
    }
}

protocol EditGroupDelegate {
    func groupChanged(group: GroupViewModel)
    func groupChangeCanceled()
}
