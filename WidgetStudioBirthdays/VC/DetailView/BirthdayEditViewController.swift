//
//  BirthdayEditViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 22.11.20.
//

import Haptica
import Mantis
import PhotosUI
import SwiftDate
import UIKit
import WidgetKit

class BirthdayEditViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var infoLabel_date: UILabel!
    @IBOutlet var valueLabel_date: UILabel!
    @IBOutlet var infoLabel_group: UILabel!
    @IBOutlet var valueLabel_group: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var profilePicture: ProfilePictureView!
    @IBOutlet var birthdatePicker: UIPickerView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var editProfilePicButton: UIButton!

    public var birthday: BirthdayInfoViewModel! {
        didSet {
            if initialWidgetLoadingDone {
                hasChanges = true
            } else {
                initialWidgetLoadingDone = true
            }
        }
    }

    public var isNew: Bool!
    public var delegate: EditBirthdayDelegate?

    private var initialWidgetLoadingDone = false
    private var hasChanges = false

    private var currentFirstName = ""
    private var currentLastName = ""

    private var maxDayCount = 0
    private var maxMonthCount = 0
    private var availableYears: [Int] = []

    private var selectedDay: Int = 1
    private var selectedMonth: Int = 1
    private var selectedYear: Int = 1
    private var selectedDate = Date()

    private var monthSymbols: [String] = []
    private var daysInSelectedYear: Int = 0

    private var birthdayCellVisible = false

    private var nameIsValid = true

    override func viewDidLoad() {
        super.viewDidLoad()

        AppUsageCounter.logEventFor(type: .editViewOpened)
        isModalInPresentation = true
        navigationController?.presentationController?.delegate = self

        if isNew {
            firstNameTextField.becomeFirstResponder()
        }
        setData()

        checkIfIsValidName()

        // Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        editProfilePicButton.accessibilityLabel = "app.accessibility.views.editView.editPicButton.title".localize()
        firstNameTextField.accessibilityLabel = "app.views.birthdayEditor.list.placeholder.firstName".localize()
        lastNameTextField.accessibilityLabel = "app.views.birthdayEditor.list.placeholder.lastName".localize()
    }

    private func setData() {
        firstNameTextField.text = birthday.firstName
        lastNameTextField.text = birthday.lastName
        infoLabel_group.text = "app.views.birthdayEditor.list.title.group".localize()
        infoLabel_date.text = "app.views.birthdayEditor.list.title.birthday".localize()
        firstNameTextField.placeholder = "app.views.birthdayEditor.list.placeholder.firstName".localize()
        lastNameTextField.placeholder = "app.views.birthdayEditor.list.placeholder.lastName".localize()

        doneButton.setTitle("main.universal.done".localize(), for: .normal)
        cancelButton.setTitle("main.universal.cancel".localize(), for: .normal)

        // Pic
        updateProfilePic()

        // Group
        updateGroupSelectionArea()

        // Picker
        maxDayCount = 31
        maxMonthCount = 12
        availableYears = Array(100 ... Date().year)
        availableYears.append(1)
        monthSymbols = DateFormatter().monthSymbols

        selectedDate = birthday.birthdate

        setDateToPicker(date: selectedDate, animated: false)
        updateDaysInMonth()
        updateDateValueLabel()
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    private func updateGroupSelectionArea() {
        valueLabel_group.text = birthday.group.name
    }

    private func updateProfilePic() {
        profilePicture.preparePicture(initials: birthday.initials, photo: birthday.profilePicture, colorGradient: birthday.group.colorGradient, shadow: false)
        profilePicture.renderPicture()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    private func openImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return
        }

        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .automatic

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        Haptic.impact(.light).generate()
        present(picker, animated: true, completion: nil)
    }

    private func openCamera(selfie: Bool) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }

        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.cameraCaptureMode = .photo
        vc.cameraDevice = selfie ? .front : .rear
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }

    private func openImageCrop(image: UIImage) {
        var config = Mantis.Config()
        config.cropShapeType = .roundedRect(radiusToShortSide: 1, maskOnly: true)
        config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
        config.ratioOptions = .square

        let cropViewController = Mantis.cropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.config = config

        cropViewController.modalPresentationStyle = .overFullScreen

        present(cropViewController, animated: true, completion: nil)
    }

    private func saveAll() {
        birthday.birthdate = selectedDate
        birthday.birthdateInYear = selectedDate.dateWithTodaysYear

        if let savedModel = BirthdayRepository.updateFromViewModel(birthdayViewModel: birthday), let identifier = savedModel.identifier {
            birthday.identifier = identifier
        }

        delegate?.birthdayChanged(updatedBirthday: birthday)
    }

    @IBAction func editProfilePhotoAction(_: Any) {
        let alertTitle = "app.views.birthdayEditor.photoPicker.menu.title".localize()

        var alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .actionSheet)

        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        }

        let noPhotoSelected = birthday.profilePicture == nil

        if !noPhotoSelected {
            alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.photoPicker.menu.option.delete".localize(), style: .destructive, handler: { _ in
                self.birthday.profilePicture = nil
                self.birthday.pictureCnOverriden = false
                self.updateProfilePic()
            }))
        }

        alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.photoPicker.menu.option.gallery".localize(), style: .default, handler: { _ in
            self.openImagePicker()
        }))

        alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.photoPicker.menu.option.takePhoto".localize(), style: .default, handler: { _ in
            self.openCamera(selfie: false)
        }))

        alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.photoPicker.menu.option.takeSelfie".localize(), style: .default, handler: { _ in
            self.openCamera(selfie: true)

        }))

        /*
         if birthday.cnProfilePicture != birthday.profilePicture, let cnPic = birthday.cnProfilePicture {
             alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.photoPicker.menu.option.useContactPic".localize(), style: .default, handler: { _ in
                 self.birthday.profilePicture = cnPic
                 self.updateProfilePic()
             }))
         }*/

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in }))
        present(alert, animated: true, completion: nil)
    }

    private func dismissView(closeView: Bool = false) {
        if isNew || closeView {
            dismiss(animated: true, completion: nil)
            return
        }

        delegate?.birthdayChangeCanceled()
        navigationController?.popBackWithFade()
    }

    @IBAction func doneAction(_: Any) {
        if !nameIsValid {
            let alert = UIAlertController(title: "app.views.birthdayEditor.saveDialog.new.missingName.title".localize(), message: "app.views.birthdayEditor.saveDialog.new.missingName.subtitle".localize(), preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.saveDialog.actions.discard".localize(), style: .default, handler: { _ in
                self.dismissView(closeView: true)

            }))

            alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in

            }))

            present(alert, animated: true, completion: nil)

            return
        }

        saveAll()
        navigationController?.popBackWithFade()
    }

    @IBAction func cancelAction(_: Any) {
        dismissView()
    }

    @IBAction func firstNameChanged(_: Any) {
        let newValue = firstNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let oldValue = birthday.firstName
        checkIfIsValidName()

        birthday.firstName = newValue

        if newValue.prefix(1) != oldValue.prefix(1) {
            updateProfilePic()
        }
    }

    @IBAction func lastNameChanged(_: Any) {
        let newValue = lastNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let oldValue = birthday.lastName
        checkIfIsValidName()

        birthday.lastName = newValue

        if newValue.prefix(1) != oldValue.prefix(1) {
            updateProfilePic()
        }
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    private func showGroupList(selectedGroup: GroupViewModel?) {
        if let groupViewController: GroupListViewController = UIStoryboard(type: .groups).instantiateViewController() {
            groupViewController.selectedGroupId = selectedGroup?.identifier
            groupViewController.groupsAreEditable = false
            groupViewController.delegate = self

            navigationController?.pushViewController(groupViewController, animated: true)
        }
    }

    private func updateDaysInMonth() {
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)

        if let localizedDate = DateInRegion(components: dateComponents, region: .current), let range = Calendar.current.range(of: .day, in: .month, for: localizedDate.date) {
            daysInSelectedYear = range.count

        } else {
            daysInSelectedYear = 28
        }

        if selectedYear == 1 {
            if [2].contains(selectedMonth) {
                daysInSelectedYear = 28
            }

            if [4, 6, 9, 11].contains(selectedMonth) {
                daysInSelectedYear = 30
            }

            if [1, 3, 5, 7, 8, 10, 12].contains(selectedMonth) {
                daysInSelectedYear = 31
            }
        }

        birthdatePicker.reloadComponent(0)
    }

    private func modifyDateInPickerIfInvalid() -> Bool {
        if selectedDay > daysInSelectedYear {
            selectedDay = daysInSelectedYear

            birthdatePicker.selectRow(daysInSelectedYear - 1, inComponent: 0, animated: true)
            updateDateValueLabel()

            return true
        }

        return false
    }

    private func setDateToPicker(date: Date, animated: Bool) {
        let dateInRegion = DateInRegion(date, region: Region.current)
        selectedDay = dateInRegion.day
        selectedMonth = dateInRegion.month
        selectedYear = dateInRegion.year

        setPicker(to: selectedDay, month: selectedMonth, year: selectedYear, animated: animated)
    }

    private func updateDateValueLabel() {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = Locale.preferredLocale()
        dateStringFormatter.timeZone = .init(identifier: "UTC")

        guard let date = dateStringFormatter.date(from: String(format: "%04d-%02d-%02d", selectedYear, selectedMonth, selectedDay)) else {
            return
        }
        selectedDate = Date(timeInterval: 0, since: date)
        valueLabel_date.text = ProjectDateFormatter.formatDate(date: selectedDate)
    }

    private func setPicker(to day: Int, month: Int, year: Int, animated: Bool) {
        // Tag
        let dayIndex = day - 1

        birthdatePicker.selectRow(dayIndex, inComponent: 0, animated: animated)

        // Monat
        var monthIndex = month - 1

        if monthIndex < 0 {
            monthIndex = 11
        }

        if monthIndex > 11 {
            monthIndex = 0
        }

        birthdatePicker.selectRow(monthIndex, inComponent: 1, animated: animated)

        // Jahr
        if year <= 1 {
            birthdatePicker.selectRow(availableYears.count - 1, inComponent: 2, animated: animated)
        } else {
            let yearIndex = availableYears.firstIndex(of: year) ?? availableYears.count - 1
            birthdatePicker.selectRow(yearIndex, inComponent: 2, animated: animated)
        }
    }

    func checkIfIsValidName() {
        let firstNameCount = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
        let lastNameCount = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0

        let isValid = firstNameCount > 0 || lastNameCount > 0

        if isValid != nameIsValid {
            DispatchQueue.main.async {
                self.doneButton.isEnabled = isValid
            }
            nameIsValid = isValid
        }
    }

    func checkForChanges() {
        if !isNew, !hasChanges {
            dismiss(animated: true, completion: nil)
        }

        var alertTile = "\(birthday.firstName) \(birthday.lastName)"
        var alertContent = ""

        if isNew {
            alertContent = "app.views.birthdayEditor.saveDialog.new.subtitle".localize()

        } else if hasChanges {
            alertContent = "app.views.birthdayEditor.saveDialog.edit.subtitle".localize()
        }

        if !nameIsValid {
            alertContent += "\n\("app.views.birthdayEditor.saveDialog.new.missingName.subtitle".localize())"
            alertTile = "app.views.birthdayEditor.saveDialog.new.missingName.title".localize()
        }

        var alert = UIAlertController(title: alertTile, message: alertContent, preferredStyle: .actionSheet)
        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTile, message: alertContent, preferredStyle: .alert)
        }

        alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.saveDialog.actions.discard".localize(), style: .destructive, handler: { _ in

            self.dismissView(closeView: true)

        }))

        if nameIsValid {
            alert.addAction(UIAlertAction(title: "app.views.birthdayEditor.saveDialog.actions.save".localize(), style: .default, handler: { _ in
                self.saveAll()
                self.dismissView(closeView: true)
            }))
        }

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }
}

// TableView
extension BirthdayEditViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if indexPath.section == 1, indexPath.row == 0 {
            Haptic.impact(.light).generate()
            birthdayCellVisible = !birthdayCellVisible
            tableView.reloadData()
        }

        if cell.reuseIdentifier == "editGroupActionCell" {
            showGroupList(selectedGroup: birthday.group)
            return
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return birthdayCellVisible ? 2 : 1
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension BirthdayEditViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_: UIPresentationController) {
        checkForChanges()
    }
}

extension BirthdayEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }

        openImageCrop(image: image)
    }
}

extension BirthdayEditViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation _: Transformation) {
        birthday.profilePicture = cropped.resizeToSquare(sideLength: 50)
        birthday.pictureCnOverriden = true
        updateProfilePic()
        cropViewController.dismiss(animated: true, completion: nil)
    }

    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original _: UIImage) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension BirthdayEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let image = image as? UIImage {
                        picker.dismiss(animated: true) {
                            self.openImageCrop(image: image)
                        }

                    } else {
                        picker.dismiss(animated: true)

                        let alert = UIAlertController(title: "Error".localize(), message: "...", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "OK".localize(), style: .cancel, handler: { _ in

                        }))

                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension BirthdayEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return maxDayCount

        case 1:
            return maxMonthCount

        case 2:
            return availableYears.count

        default:
            return 0
        }
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        hasChanges = true

        if component == 0 {
            selectedDay = row + 1

        } else if component == 1 {
            selectedMonth = row + 1
            updateDaysInMonth()

        } else if component == 2 {
            if let year = availableYears[safe: row] {
                selectedYear = year

            } else {
                selectedYear = 1
            }

            updateDaysInMonth()
        }

        if modifyDateInPickerIfInvalid() {
            return
        } else {
            updateDateValueLabel()
        }
    }

    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""

        switch component {
        case 0:
            title = "\(row + 1)"

        case 1:
            title = monthSymbols[safe: row] ?? ""

        case 2: do {
                if let year = availableYears[safe: row] {
                    title = (year <= 1 ? "----" : "\(year)")
                }
            }

        default:
            title = ""
        }

        let attributes = [NSAttributedString.Key.foregroundColor: component == 0 && row >= daysInSelectedYear ? UIColor.lightGray : UIColor.label]
        return NSAttributedString(string: title, attributes: attributes)
    }
}

extension BirthdayEditViewController: EditGroupDelegate {
    func groupChangeCanceled() {}

    func groupChanged(group: GroupViewModel) {
        birthday.group = group
        updateGroupSelectionArea()
        updateProfilePic()
    }
}

protocol EditBirthdayDelegate {
    func birthdayChanged(updatedBirthday: BirthdayInfoViewModel)
    func birthdayChangeCanceled()
}
