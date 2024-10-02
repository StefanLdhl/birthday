//
//  QuickActionSettingsViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import UIKit

class QuickActionSettingsViewController: UIViewController {
    var allQuickActions: [QuickAction] = QuickActionManager.getDefaultOrder()
    var selectedQuickActions: [QuickAction] = []
    var remainingQuickActions: [QuickAction] = []

    @IBOutlet var actionsTableView: UITableView!

    override func viewDidLoad() {
        selectedQuickActions = QuickActionManager.getUsersQuickActions()
        reloadTableSections()

        actionsTableView.isEditing = true

        actionsTableView.tableFooterView = UIView()

        title = "app.views.settings.advanced.list.quickActions".localize()

        // Accessibility
        actionsTableView.rowHeight = UITableView.automaticDimension
        actionsTableView.estimatedRowHeight = 53

        super.viewDidLoad()
    }

    private func saveData() {
        QuickActionManager.saveUsersQuickActions(actions: selectedQuickActions)
    }

    private func reloadTableSections() {
        remainingQuickActions = allQuickActions.filter { !selectedQuickActions.contains($0) }
        actionsTableView.reloadData()
    }

    override func viewWillDisappear(_: Bool) {
        saveData()
    }

    @IBAction func showPrivacyInfoAlert(_: Any) {
        let alert = UIAlertController(title: "app.views.birthdayDetailView.privacyInfoAlert.title".localize(), message: "app.views.birthdayDetailView.privacyInfoAlert.content".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .cancel, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }

    private func showInfoAlertFor(quickAction: QuickAction) {
        guard let info = quickAction.additionalInfo() else {
            return
        }

        let alert = UIAlertController(title: "", message: info, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "main.universal.done".localize(), style: .cancel, handler: { _ in

        }))

        present(alert, animated: true, completion: nil)
    }
}

extension QuickActionSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? selectedQuickActions.count : remainingQuickActions.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuickActionSettingsTableViewCell", for: indexPath) as? QuickActionSettingsTableViewCell else {
            return UITableViewCell()
        }

        var currentAction: QuickAction?

        if indexPath.section == 0 {
            currentAction = selectedQuickActions[indexPath.row]
        } else {
            currentAction = remainingQuickActions[indexPath.row]
        }

        guard let action = currentAction else {
            return UITableViewCell()
        }

        cell.actionTitleLabel.text = action.localizedTitle()
        cell.actionIconImage.image = action.icon()

        cell.infoButton.isHidden = action.additionalInfo() == nil

        cell.infoButtonPressed = {
            self.showInfoAlertFor(quickAction: action)
        }

        return cell
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert, indexPath.section == 1 {
            if let actionToAdd = remainingQuickActions[safe: indexPath.row] {
                selectedQuickActions.append(actionToAdd)
            }
        } else if editingStyle == .delete, indexPath.section == 0 {
            if let actionToRemove = selectedQuickActions[safe: indexPath.row], let indexToDelete = selectedQuickActions.firstIndex(of: actionToRemove) {
                selectedQuickActions.remove(at: indexToDelete)
            }
        }

        reloadTableSections()
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    func tableView(_: UITableView, shouldIndentWhileEditingRowAt _: IndexPath) -> Bool {
        return false
    }

    func tableView(_: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 0 {
            return .delete
        } else {
            return .insert
        }
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let action = selectedQuickActions[sourceIndexPath.row]
        selectedQuickActions.remove(at: sourceIndexPath.row)
        selectedQuickActions.insert(action, at: destinationIndexPath.row)
    }
}
