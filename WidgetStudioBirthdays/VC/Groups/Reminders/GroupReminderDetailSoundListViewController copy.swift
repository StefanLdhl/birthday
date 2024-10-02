//
//  GroupReminderDetailSelectionListViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 11.01.21.
//

import AVFoundation
import UIKit

class GroupReminderDetailSoundListViewController: UIViewController {
    public var sounds: [ReminderSound] = ReminderSound.allCases
    public var selectedSound: ReminderSound!
    public var delegate: ReminderDetailSelectionDelegate?

    private var soundAudioPlayer: AVAudioPlayer?

    @IBOutlet var soundsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        soundsTableView.tableFooterView = UIView()
        title = "app.views.reminderEditor.list.sounds.title".localize()
    }

    @IBAction func doneAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func playSelectedSound() {
        guard let soundFile = selectedSound.getSourceFileName() else {
            return
        }

        let path = Bundle.main.path(forResource: soundFile, ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            soundAudioPlayer = try AVAudioPlayer(contentsOf: url)
            soundAudioPlayer?.play()
        } catch {}
    }
}

extension GroupReminderDetailSoundListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return sounds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddReminderDetailListTableViewCell", for: indexPath) as? AddReminderDetailListTableViewCell else {
            return UITableViewCell()
        }

        guard let item = sounds[safe: indexPath.row] else {
            return UITableViewCell()
        }

        cell.itemTextLabel.text = item.localizedTitle()
        cell.accessoryType = item.rawValue == selectedSound.rawValue ? .checkmark : .none

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedItem = sounds[safe: indexPath.row] else {
            return
        }
        selectedSound = selectedItem
        delegate?.selectedSoundChanged(sound: selectedItem)

        playSelectedSound()
        soundsTableView.reloadData()
    }
}
