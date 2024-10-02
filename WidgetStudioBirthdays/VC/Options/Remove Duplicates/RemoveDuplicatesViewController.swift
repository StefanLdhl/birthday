//
//  RemoveDuplicatesViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 06.04.21.
//

import UIKit

class RemoveDuplicatesViewController: UIViewController {
    @IBOutlet var birthdaysTableView: UITableView!
    @IBOutlet var deleteBarButtonItem: UIBarButtonItem!
    @IBOutlet var noDataInfoLabel: UILabel!

    private var duplicateBirthdays: [DuplicateBirthdays] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        duplicateBirthdays = BirthdayRepository.getAllDuplicateBirthdays()
        updateDeleteButton()

        if duplicateBirthdays.count == 0 {
            birthdaysTableView.isHidden = true
            noDataInfoLabel.isHidden = false
        }

        title = "app.views.removeDuplicates.title".localize()
        deleteBarButtonItem.title = "app.views.removeDuplicates.barButton.continue".localize()
        noDataInfoLabel.text = "app.views.removeDuplicates.table.noDataLabel".localize()
        
        
        birthdaysTableView.rowHeight = UITableView.automaticDimension
        birthdaysTableView.estimatedRowHeight = 60
    }

    private func updateDeleteButton() {
        DispatchQueue.main.async { [self] in
            deleteBarButtonItem.isEnabled = duplicateBirthdays.filter { $0.isSelected }.count > 0
        }
    }

    @IBAction func deleteAction(_: Any) {
        removeDuplicates()
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)
    }

    private func removeDuplicates() {
        for duplicateGroup in duplicateBirthdays.filter({ $0.isSelected }) {
            var birthdays = duplicateGroup.birthdays.sorted(by: { $0.creationDate ?? Date() < $1.creationDate ?? Date() })

            if birthdays.count <= 1 {
                return
            }

            birthdays.removeFirst()

            for birthdayToDelete in birthdays {
                CoreDataStack.defaultStack.managedObjectContext.delete(birthdayToDelete)

                BirthdayRepository.deleteBirthday(birthday: birthdayToDelete)
            }
        }

        CoreDataStack.defaultStack.saveContext()
    }
}

extension RemoveDuplicatesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return duplicateBirthdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DuplicateBirthdayTableViewCell", for: indexPath) as? DuplicateBirthdayTableViewCell else {
            return UITableViewCell()
        }

        guard let duplicateBirthday = duplicateBirthdays[safe: indexPath.row], let firstBirthday = duplicateBirthday.birthdays.first else {
            return UITableViewCell()
        }

        cell.titleLabel.text = "\(firstBirthday.firstName ?? "") \(firstBirthday.lastName ?? "")"

        let birthdaysCount = duplicateBirthday.birthdays.count
        let birthdaysToDeleteCount = max(0, birthdaysCount - 1)

        cell.subtitleLabel.text = "app.views.removeDuplicates.table.subtitle.%d.%d".localize(values: birthdaysCount, birthdaysToDeleteCount)

        cell.accessoryType = duplicateBirthday.isSelected ? .checkmark : .none

        return cell
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let birthday = duplicateBirthdays[safe: indexPath.row] else {
            return
        }

        duplicateBirthdays[indexPath.row].isSelected = !birthday.isSelected
        birthdaysTableView.reloadData()
        updateDeleteButton()
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
