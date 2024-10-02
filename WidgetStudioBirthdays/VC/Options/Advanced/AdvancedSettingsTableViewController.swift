//
//  AdvancedSettingsTableViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import UIKit
import WidgetKit

class AdvancedSettingsTableViewController: UITableViewController {
    @IBOutlet var selectedCustomFormatLabel: UILabel!

    @IBOutlet var quickActionsLabel: UILabel!
    @IBOutlet var backgroundStilLabel: UILabel!
    @IBOutlet var dateFormatLabel: UILabel!
    
    @IBOutlet var namesortingLabel: UILabel!
    @IBOutlet var namesortingValueLabel: UILabel!

    @IBOutlet var backgroundStyleSegmentedControl: UISegmentedControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "app.views.settings.list.title.advancedSettings.short".localize()

        dateFormatLabel.text = "app.views.settings.advanced.list.dateFormat".localize()
        quickActionsLabel.text = "app.views.settings.advanced.list.quickActions".localize()
        backgroundStilLabel.text = "app.views.settings.advanced.list.backgroundStil".localize()
        namesortingLabel.text = "app.views.settings.advanced.list.nameFormat".localize()

        
        let backgroundStyle = GroupedUserDefaults.integer(forKey: .localUserInfo_backgroundStyleId)
        backgroundStyleSegmentedControl.selectedSegmentIndex = min(2, backgroundStyle)
        
        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        
    }
    
    @IBAction func backgroundStyleChanged(_: Any) {
        GroupedUserDefaults.set(value: backgroundStyleSegmentedControl.selectedSegmentIndex, for: .localUserInfo_backgroundStyleId)
        reloadTimelines()
    }
    
    func reloadTimelines() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "app.views.settings.advanced.list.sectionTitle.profile".localize()

        case 1:
            return "app.views.settings.advanced.list.sectionTitle.localization".localize()
            
        case 2:
            return "Widget"

        default:
            return nil
        }
    }

    override func viewWillAppear(_: Bool) {
        updateData()
    }

    private func updateData() {
        DispatchQueue.main.async {
            if let customFormatId = GroupedUserDefaults.string(forKey: .crossDeviceUserInfo_customDateFormattingId), let customFormat = CustomDateFormatType(rawValue: customFormatId) {
                self.selectedCustomFormatLabel.text = customFormat.getFormat().withYear

            } else {
                self.selectedCustomFormatLabel.text = "app.views.settings.advanced.dateFormat.auto".localize()
            }
            
            
            
            if GroupedUserDefaults.bool(forKey: .localUserInfo_nameFormatShowLastNameFirst) {
                self.namesortingValueLabel.text = "app.views.settings.advanced.nameFormatting.list.lastFirst".localize()
            } else {
                self.namesortingValueLabel.text = "app.views.settings.advanced.nameFormatting.list.firstLast".localize()
            }

        }
    }
    
    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
