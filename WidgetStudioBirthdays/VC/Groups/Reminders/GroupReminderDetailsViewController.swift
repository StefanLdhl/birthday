//
//  GroupReminderDetailsViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import Haptica
import UIKit

class GroupReminderDetailsViewController: UITableViewController {
    @IBOutlet var timePicker: UIDatePicker!

    @IBOutlet var infoLabelSound: UILabel!
    @IBOutlet var infoLabelType: UILabel!
    @IBOutlet var infoLabelTime: UILabel!

    @IBOutlet var valueLabelSound: UILabel!
    @IBOutlet var valueLabelType: UILabel!
    @IBOutlet var valueLabelTime: UILabel!

    public var reminder: ReminderViewModel!
    public var delegate: EditReminderDelegate?
    public var isNew: Bool = false

    private var timeCellVisible = true

    override func viewDidLoad() {
        super.viewDidLoad()

        timePicker.setDate(reminder.time, animated: false)
        updateLabels()

        title = "app.views.editReminders.title".localize()

        infoLabelType.text = "app.views.reminderEditor.list.title.typ".localize()
        infoLabelSound.text = "app.views.reminderEditor.list.title.sound".localize()
        infoLabelTime.text = "app.views.reminderEditor.list.title.time".localize()

        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 58
    }

    private func updateLabels() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let formattedTime = formatter.string(from: timePicker.date)

        DispatchQueue.main.async {
            self.valueLabelSound.text = self.reminder.sound.localizedTitle()
            self.valueLabelType.text = self.reminder.type.localizedTitle()
            self.valueLabelTime.text = formattedTime
        }
    }

    private func saveAll() {
        reminder.time = timePicker.date

        reminder.modified = true
        delegate?.reminderEdited(reminder: reminder, isNew: isNew)
        isNew = false
    }

    @IBAction func cancelAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveAction(_: Any) {
        saveAll()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func timePickerChanged(_: Any) {
        updateLabels()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return timeCellVisible ? 2 : 1
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.tag == 3 {
            Haptic.impact(.light).generate()
            timeCellVisible = !timeCellVisible
            tableView.reloadData()
            return
        }

        if cell.tag == 1 {
            if let typeView: GroupReminderDetailTypeListViewController = UIStoryboard(type: .groups).instantiateViewController() {
                typeView.delegate = self
                typeView.selectedType = reminder.type

                let navController = UINavigationController(rootViewController: typeView)
                present(navController, animated: true, completion: nil)
            }
            return
        }

        if cell.tag == 2 {
            if let soundView: GroupReminderDetailSoundListViewController = UIStoryboard(type: .groups).instantiateViewController() {
                soundView.delegate = self
                soundView.selectedSound = reminder.sound

                let navController = UINavigationController(rootViewController: soundView)
                present(navController, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension GroupReminderDetailsViewController: ReminderDetailSelectionDelegate {
    func selectedSoundChanged(sound: ReminderSound) {
        reminder.sound = sound
        updateLabels()
    }

    func selectedTypeChanged(type: ReminderType) {
        reminder.type = type
        updateLabels()
    }
}

protocol EditReminderDelegate {
    func reminderEdited(reminder: ReminderViewModel, isNew: Bool)
}

protocol ReminderDetailSelectionDelegate {
    func selectedSoundChanged(sound: ReminderSound)
    func selectedTypeChanged(type: ReminderType)
}
