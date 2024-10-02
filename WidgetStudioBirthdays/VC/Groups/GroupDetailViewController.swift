//
//  GroupDetailViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 02.12.20.
//

import Haptica
import SwiftUI
import UIKit

class GroupDetailViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var widgetUIPreview: UIView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var widgetUIPreviewHolder: UIView!
    @IBOutlet var customColorGradientView: UIView!
    @IBOutlet var customColorGradientColor1: UIView!
    @IBOutlet var customColorGradientColor2: UIView!

    @IBOutlet var colorsCollectionView: UICollectionView!

    @IBOutlet var changeColorInfoLabel: UILabel!

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var addColor1Button: UIButton!
    @IBOutlet var addColor2Button: UIButton!

    @IBOutlet var infoLabel_color: UILabel!

    @IBOutlet var infoLabel_reminders: UILabel!
    @IBOutlet var infoLabel_remindersCount: UILabel!

    @IBOutlet var infoLabel_messages: UILabel!
    @IBOutlet var infoLabel_messagesValue: UILabel!

    let currentGradientLayer = CAGradientLayer()
    var selectedCustomColor = 0

    private var gradients = ColorGradientGenerator.getDefaultGradients()
    private var premiumGradientIds = ColorGradientGenerator.getPremiumGradientIds()

    private var currentCustomGradientSelection: ColorGradient?

    var selectedColorBeforeColorPicker: ColorGradient?
    var viewAlreadyDidLayoutSubviews = false

    private var hasChanges = false

    private var showCustomGradientSlider = false

    var groupPicHostingController = UIHostingController(rootView: CircularGroupPicture(groupPictureInfo: GroupPictureUserInput(color1: nil, color2: nil)))

    // Input
    var group: GroupViewModel!
    var delegate: EditGroupDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        infoLabel_color.text = "app.views.groupEditor.list.title.colors".localize()
        changeColorInfoLabel.text = "app.views.groupEditor.list.colorPicker.infoText".localize()
        nameTextField.placeholder = "app.views.groupEditor.list.placeholder.name".localize()
        infoLabel_reminders.text = "app.views.groupEditor.list.title.reminders".localize()

        infoLabel_messages.text = "app.views.groupEditor.list.title.messages".localize()

        doneButton.setTitle("main.universal.done".localize(), for: .normal)
        cancelButton.setTitle("main.universal.cancel".localize(), for: .normal)

        setupWidgetPreview()
        setData()
        updateReminderCountLabel()

        isModalInPresentation = true
        navigationController?.presentationController?.delegate = self

        NotificationCenter.default.addObserver(forName: Notification.Name("UserProStateChanged"), object: nil, queue: nil) { _ in
            self.premiumGradientIds = ColorGradientGenerator.getPremiumGradientIds()
            self.colorsCollectionView.reloadData()
        }

        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func setData() {
        DispatchQueue.main.async { [weak self] in
            self?.nameTextField.text = self?.group.name
            self?.infoLabel_messagesValue.text = self?.group.preferredMessageTemplate?.title ?? "-"
        }
    }

    private func updateReminderCountLabel() {
        DispatchQueue.main.async { [weak self] in

            self?.infoLabel_remindersCount.text = "\(self?.group.reminders.count ?? 0)"
        }
    }

    func setupWidgetPreview() {
        addChild(groupPicHostingController)
        groupPicHostingController.view.backgroundColor = .clear
        groupPicHostingController.view.frame = widgetUIPreview.bounds
        widgetUIPreview.addSubview(groupPicHostingController.view)
        groupPicHostingController.didMove(toParent: self)

        refreshWidgetPreview()
    }

    /// Aktualisiert den Widget SwiftUI View
    private func refreshWidgetPreview() {
        guard widgetUIPreview != nil else {
            return
        }

        groupPicHostingController.rootView.groupPictureInfo = GroupPictureUserInput(color1: group.colorGradient.color1.color, color2: group.colorGradient.color2.color)
    }

    override func viewDidLayoutSubviews() {
        guard !viewAlreadyDidLayoutSubviews else {
            return
        }

        scrollToCurrentColor()

        setupCustomGradientView()
        viewAlreadyDidLayoutSubviews = true
    }

    private func saveAll() {
        group.name = nameTextField.text ?? ""

        _ = GroupRepository.updateFromViewModel(groupViewModel: group)
        delegate?.groupChanged(group: group)
    }

    private func discardAll() {
        delegate?.groupChangeCanceled()
    }

    private func setupCustomGradientView() {
        customColorGradientColor1.layer.cornerRadius = customColorGradientColor1.bounds.width / 2
        customColorGradientColor2.layer.cornerRadius = customColorGradientColor2.bounds.width / 2

        customColorGradientColor1.clipsToBounds = true
        customColorGradientColor2.clipsToBounds = true

        customColorGradientView.layer.cornerRadius = customColorGradientView.bounds.height / 2

        customColorGradientView.clipsToBounds = true

        currentGradientLayer.frame = view.frame
        currentGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        currentGradientLayer.endPoint = CGPoint(x: 1, y: 0)
        customColorGradientView.layer.insertSublayer(currentGradientLayer, at: 0)

        updateGradientColors()
    }

    @IBAction func nameDidChange(_: Any) {
        hasChanges = true
    }

    @IBAction func setCustomColor1(_: Any) {
        if !CurrentUser.isUserPro() {
            openPurchaseScreen()
            return
        }
        Haptic.impact(.light).generate()

        selectedCustomColor = 1
        openPicker(color: group.colorGradient.color1.uiColor, isFirstColor: true)
    }

    @IBAction func setCustomColor2(_: Any) {
        if !CurrentUser.isUserPro() {
            openPurchaseScreen()
            return
        }
        Haptic.impact(.light).generate()

        selectedCustomColor = 2
        openPicker(color: group.colorGradient.color2.uiColor, isFirstColor: false)
    }

    private func openPurchaseScreen() {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            Haptic.impact(.light).generate()
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    @IBAction func cancelAction(_: Any) {
        discardAll()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveAction(_: Any) {
        saveAll()

        dismiss(animated: true, completion: nil)
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "app.views.settings.notifications.list.groupsCell.sectionFooter.text".localize()
        }

        if section == 3 {
            return "app.views.settings.notifications.list.messagesCell.sectionFooter.text".localize()
        }
        return nil
    }

    private func scrollToCurrentColor() {
        colorsCollectionView.layoutIfNeeded()

        if group.colorGradient.gradientId == 999 {
            colorsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .right, animated: false)
        } else if let iconIndex = gradients.firstIndex(where: { $0.gradientId == group.colorGradient.gradientId }), gradients.indices.contains(iconIndex) {
            colorsCollectionView.scrollToItem(at: IndexPath(item: iconIndex, section: 0), at: .left, animated: false)
        }
    }

    private func openPicker(color: UIColor, isFirstColor: Bool) {
        let picker = UIColorPickerViewController()

        if UIDevice.current.userInterfaceIdiom == .phone {
            picker.title = "app.views.groupEditor.list.colorPicker.swipeToSave".localize()
        }

        picker.navigationController?.navigationBar.items?.removeAll()
        picker.delegate = self
        picker.supportsAlpha = false
        picker.selectedColor = color

        picker.modalPresentationStyle = .popover
        picker.preferredContentSize = CGSize(width: 200, height: 100)

        if let presentationController = picker.popoverPresentationController {
            if isFirstColor {
                presentationController.permittedArrowDirections = [.left]
                presentationController.sourceView = addColor1Button
                presentationController.sourceRect = addColor1Button.frame
            } else {
                presentationController.permittedArrowDirections = [.right]
                presentationController.sourceView = addColor2Button
                presentationController.sourceRect = addColor2Button.frame
            }
        }

        selectedColorBeforeColorPicker = group.colorGradient

        present(picker, animated: true, completion: nil)
    }

    private func updateGradientColors(refreshCollectionView: Bool = true) {
        currentGradientLayer.colors = [group.colorGradient.color1.uiColor.cgColor, group.colorGradient.color2.uiColor.cgColor]

        if refreshCollectionView {
            colorsCollectionView.reloadSections([1])
        }

        refreshWidgetPreview()
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
}

extension GroupDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.tag == 5 {
            if let groupReminderList: GroupReminderListViewController = UIStoryboard(type: .groups).instantiateViewController() {
                groupReminderList.reminders = group.reminders
                groupReminderList.delegate = self
                navigationController?.pushViewController(groupReminderList, animated: true)
            }
        }

        if cell.tag == 9 {
            if let messagesList: MessagesListViewController = UIStoryboard(type: .messages).instantiateViewController() {
                messagesList.delegate = self
                messagesList.messagesAreEditable = false
                messagesList.selectedMessageId = group.preferredMessageTemplate?.identifier
                navigationController?.pushViewController(messagesList, animated: true)
            }
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return showCustomGradientSlider ? 2 : 1
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension GroupDetailViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ picker: UIColorPickerViewController) {
        if group.colorGradient.gradientId != 999 {
            group.colorGradient.gradientId = 999
            scrollToCurrentColor()
        }

        if selectedCustomColor == 1 {
            group.colorGradient.color1 = ProjectColor(value: picker.selectedColor.hexString)
            group.colorGradient.color2 = ProjectColor(value: group.colorGradient.color2.uiColor.hexString)

        } else if selectedCustomColor == 2 {
            group.colorGradient.color1 = ProjectColor(value: group.colorGradient.color1.uiColor.hexString)
            group.colorGradient.color2 = ProjectColor(value: picker.selectedColor.hexString)
        }

        group.colorGradient.gradientId = 999
        updateGradientColors()
    }

    // If Cancel button in picker is pressed, fall back to original color
    func colorPickerViewControllerDidFinish(_: UIColorPickerViewController) {
        if let colorFallback = selectedColorBeforeColorPicker {
            group.colorGradient.color1 = colorFallback.color1
            group.colorGradient.color2 = colorFallback.color2
            group.colorGradient.gradientId = colorFallback.gradientId

            updateGradientColors()
        }
    }

    func checkForChanges() {
        if !hasChanges {
            dismiss(animated: true, completion: nil)
        }

        let alertTile = "\(group.name)"
        var alertContent = ""

        alertContent = "app.views.groupEditor.saveDialog.edit.subtitle".localize()

        var alert = UIAlertController(title: alertTile, message: alertContent, preferredStyle: .actionSheet)
        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTile, message: alertContent, preferredStyle: .alert)
        }

        alert.addAction(UIAlertAction(title: "app.views.groupEditor.saveDialog.actions.discard".localize(), style: .destructive, handler: { _ in
            self.discardAll()
            self.dismiss(animated: true, completion: nil)

        }))

        alert.addAction(UIAlertAction(title: "app.views.groupEditor.saveDialog.actions.save".localize(), style: .default, handler: { _ in
            self.saveAll()
            self.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }
}

extension GroupDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? gradients.count : 1
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsCollectionViewCell", for: indexPath) as! ColorsCollectionViewCell

            let gradient = gradients[indexPath.row]

            cell.lockedOverlayImage.isHidden = true
            cell.alpha = 1.0

            if premiumGradientIds.contains(gradient.gradientId) {
                cell.alpha = 0.5
                cell.lockedOverlayImage.isHidden = false
            }

            DispatchQueue.main.async {
                cell.editOverlayImage.isHidden = gradient.gradientId != self.group.colorGradient.gradientId
                cell.circularGadientView.updateGradient(gradient: gradient)
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpecialColorsCollectionViewCell", for: indexPath) as! SpecialColorsCollectionViewCell

            cell.circularGadientView.layer.borderColor = UIColor.label.cgColor

            var colorGradient = group.colorGradient

            if let customColorSelection = currentCustomGradientSelection {
                colorGradient = customColorSelection
            }

            DispatchQueue.main.async {
                cell.circularGadientView.layer.borderWidth = self.group.colorGradient.gradientId == 999 ? 2 : 0
                cell.circularGadientView.updateGradient(gradient: colorGradient, systemImageName: "pencil")
            }

            return cell
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var showSlider = false

        hasChanges = true

        if indexPath.section == 1 {
            Haptic.impact(.light).generate()

            showSlider = true

            var color1 = group.colorGradient.color1
            var color2 = group.colorGradient.color2

            if let fallback = currentCustomGradientSelection {
                color1 = fallback.color1
                color2 = fallback.color2
            }

            group.colorGradient = ColorGradient(color1: ProjectColor(value: color1.uiColor.hexString), color2: ProjectColor(value: color2.uiColor.hexString), gradientId: 999)

        } else {
            if premiumGradientIds.contains(gradients[indexPath.row].gradientId) {
                openPurchaseScreen()
                return
            }

            if group.colorGradient.gradientId == gradients[indexPath.row].gradientId {
                // Info Popup aublenden
                /* if colorInfoPopUp.isVisible {
                     GroupedUserDefaults.set(value: true, for: "localUserInfo_didShowCustomColorInfo")
                     colorInfoPopUp.hide()
                 }*/

                // Toggle
                showSlider = !showCustomGradientSlider

            } else {
                showSlider = showCustomGradientSlider
                Haptic.impact(.light).generate()
            }

            group.colorGradient = gradients[indexPath.row]
        }

        let itemsToReload = colorsCollectionView.indexPathsForVisibleItems
        // Doppeltes Laden verhindern
        updateGradientColors(refreshCollectionView: !itemsToReload.contains(IndexPath(item: 0, section: 1))) //
        colorsCollectionView.reloadItems(at: itemsToReload)

        if showCustomGradientSlider != showSlider {
            showCustomGradientSlider = showSlider

            Haptic.play("o", delay: 0.10)

            tableView.reloadData()
        }
    }
}

extension GroupDetailViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_: UIPresentationController) {
        checkForChanges()
    }
}

extension GroupDetailViewController: GroupRemindersDelegate {
    func remindersChanged(reminders: [ReminderViewModel]) {
        hasChanges = true
        group.reminders = reminders
        updateReminderCountLabel()
    }
}

extension GroupDetailViewController: EditMessageDelegate {
    func messageChanged(message: MessagesViewModel?) {
        group.preferredMessageTemplate = message
        hasChanges = true
        setData()
    }

    func messageChangeCanceled() {}
}
