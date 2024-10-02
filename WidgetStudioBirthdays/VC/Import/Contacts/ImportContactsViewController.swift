
//  ImportContactsViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 21.11.20.
//

import Contacts
import UIKit

class ImportContactsViewController: UIViewController {
    private var hasContactsAccess = false
    private var isCurrentyImporting = false
    private var isCurrentyAskingForPermisson = false

    private lazy var contactStore = CNContactStore()

    private var contactPreviews: [ContactPreviewViewModel] = []
    private var importedContactPreviews: [ContactPreviewViewModel] = []

    private var selectedContactPreviews: [ContactPreviewViewModel] = []
    private var selectedImportedContactPreviews: [ContactPreviewViewModel] = []

    var _contactPreviewMapper = ContactPreviewViewModelMapper()

    @IBOutlet var contactsPreviewTableView: UITableView!
    @IBOutlet var importBarButton: UIBarButtonItem!
    @IBOutlet var selectAllButton: UIButton!

    let colorGradient = ColorGradientGenerator.getFallbackGradient()

    private var searchController = UISearchController(searchResultsController: nil)

    private var selectedContactIds: [String] = [] {
        didSet {
            importBarButton.isEnabled = selectedContactIds.count > 0
        }
    }

    // Incoming
    var alreadyImportedContactsCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        selectedContactIds.removeAll()

        contactsPreviewTableView.tableFooterView = UIView()
        contactsPreviewTableView.allowsMultipleSelection = true

        contactsPreviewTableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)

        hasContactsAccess = CNContactStore.authorizationStatus(for: .contacts) == .authorized

        if hasContactsAccess {
            startImport()
        } else {
            requestContactsAccess()
        }

        setupSearch()
        updateSelectAllButton()

        title = "app.views.import.title".localize()
        importBarButton.title = "app.views.import.continueButton.title".localize()

        selectAllButton.titleLabel?.adjustsFontForContentSizeCategory = true

        // Accessibility
        contactsPreviewTableView.rowHeight = UITableView.automaticDimension
        contactsPreviewTableView.estimatedRowHeight = 66.0
    }

    func showPermissonAlert() {
        let alertTitle = "app.views.import.noAccessView.infoTitle".localize()
        let alertContent = "app.views.import.noAccessView.infoText".localize()

        let alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "app.views.import.noAccessView.buttonTitle".localize(), style: .cancel, handler: { _ in

            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            self.dismiss(animated: true, completion: nil)

        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .default, handler: { _ in

            self.dismiss(animated: true, completion: nil)

        }))

        present(alert, animated: true, completion: nil)
    }

    func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.setValue("main.universal.done".localize(), forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }

    private func updateSelectAllButton() {
        DispatchQueue.main.async {
            if self.contactPreviews.count == 0 {
                self.selectAllButton.isHidden = true
                self.selectAllButton.setTitle("", for: .normal)
                return
            }

            self.selectAllButton.isHidden = false
            self.selectAllButton.setTitle(self.selectedContactIds.count == self.contactPreviews.count ? "app.views.import.list.button.deselect.title".localize() : "app.views.import.list.button.select.title".localize(), for: .normal)
        }
    }

    private func requestContactsAccess() {
        isCurrentyAskingForPermisson = true

        contactStore.requestAccess(for: CNEntityType.contacts) { [weak self] isGranted, _ in

            self?.isCurrentyAskingForPermisson = false

            if isGranted {
                DispatchQueue.main.async {
                    self?.hasContactsAccess = true
                    self?.startImport()
                }

            } else {
                DispatchQueue.main.async {
                    self?.showPermissonAlert()
                }
            }

            self?.refreshVisibleContent()
        }
    }

    private func toggleSelectAllButton(visible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.selectAllButton.alpha = visible ? 1.0 : 0.0
            self.selectAllButton.isUserInteractionEnabled = visible
        }
    }

    private func refreshVisibleContent() {
        DispatchQueue.main.async {
            self.contactsPreviewTableView.reloadData()
            self.updateSelectAllButton()
        }
    }

    private func startImport() {
        isCurrentyImporting = true
        refreshVisibleContent()
        let keys = [CNContactBirthdayKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactIdentifierKey, CNContactDatesKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey,CNContactOrganizationNameKey] as [CNKeyDescriptor]

        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }

        var rawContacts: [CNContact] = []

        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keys)
                rawContacts.append(contentsOf: containerResults)

            } catch {
                print("Error fetching results for container")
            }
        }

        // Doppelte Kontakte (wenn in mehr als 1 Container) entfernen
        var uniqueRawContacts: [CNContact] = []
        for rawContact in rawContacts {
            if !uniqueRawContacts.contains(where: { $0.identifier == rawContact.identifier }) {
                uniqueRawContacts.append(rawContact)
            }
        }

        contactPreviews.removeAll()

        let existingBirthdays = BirthdayRepository.getAllBirthdays()
        let existingBirthdayIds = existingBirthdays.map { $0.cnContactId }

        for contact in uniqueRawContacts {
            if var validBirthdayContact = _contactPreviewMapper.map(contact: contact) {
                if existingBirthdayIds.contains(validBirthdayContact.cnContactId) {
                    if let match = existingBirthdays.filter({ $0.cnContactId == validBirthdayContact.cnContactId }).first {
                        validBirthdayContact.colorGradient = BirthdayInfoViewModelMapper.map(birthday: match).group.colorGradient
                    }

                    importedContactPreviews.append(validBirthdayContact)

                } else {
                    contactPreviews.append(validBirthdayContact)
                }
            }
        }

        if GroupedUserDefaults.bool(forKey: .localUserInfo_nameFormatShowLastNameFirst) {
            importedContactPreviews = importedContactPreviews.sorted(by: { $0.lastName < $1.lastName })
            contactPreviews = contactPreviews.sorted(by: { $0.lastName < $1.lastName })
        } else {
            importedContactPreviews = importedContactPreviews.sorted(by: { $0.firstName < $1.firstName })
            contactPreviews = contactPreviews.sorted(by: { $0.firstName < $1.firstName })
        }

        selectedImportedContactPreviews = importedContactPreviews.map { $0 }
        selectedContactPreviews = contactPreviews.map { $0 }
        selectedContactIds.removeAll()

        if (CurrentUser.isUserPro()) {
            
            // Alle markieren
            selectedContactIds = selectedContactPreviews.map { $0.cnContactId }
        }
        isCurrentyImporting = false
        refreshVisibleContent()
    }

    @IBAction func closeViewAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectAllContacts(_: Any) {
        if selectedContactIds.count == contactPreviews.count {
            selectedContactIds.removeAll()
        } else {
            selectedContactIds = contactPreviews.map { $0.cnContactId }
        }

        contactsPreviewTableView.reloadData()
        updateSelectAllButton()
    }

    @IBAction func startImportAction(_: Any) {
        let contactsToImport = contactPreviews.filter { selectedContactIds.contains($0.cnContactId) }
        let contactsToOverride = importedContactPreviews.filter { selectedContactIds.contains($0.cnContactId) }

        if !CurrentUser.isUserPro() && !CurrentUser.isEarlyAdopter() {
            let availableImportSlots = max(0, 7 - alreadyImportedContactsCount)

            if availableImportSlots < contactsToImport.count {
                showPremiumWarning(availableSlots: availableImportSlots)
                return
            }
        }

        guard contactsToImport.count > 0 || contactsToOverride.count > 0 else {
            return
        }

        if let summaryView: ImportContactsSummaryViewController = UIStoryboard(type: .eventImport).instantiateViewController() {
            summaryView.contactsToImport = contactsToImport
            summaryView.contactsToOverwrite = contactsToOverride

            navigationController?.pushViewController(summaryView, animated: true)
        }
    }

    private func showPremiumWarning(availableSlots: Int) {
        let alert = UIAlertController(title: "app.views.import.limitWarningAlert.title".localize(), message: "app.views.import.limitWarningAlert.content.%d".localize(values: availableSlots), preferredStyle: .alert)

        let continueButtonText = availableSlots > 0 ? "app.views.import.limitWarningAlert.button.continue.%d".localize(values: availableSlots) : "app.views.import.limitWarningAlert.button.okay".localize()
        
        alert.addAction(UIAlertAction(title: continueButtonText, style: .default, handler: { _ in
        }))

        alert.addAction(UIAlertAction(title: "app.views.import.limitWarningAlert.button.openPurchaseScreen".localize(), style: .cancel, handler: { [self] _ in
            openPurchaseScreen()
        }))

        present(alert, animated: true, completion: nil)
    }

    private func openPurchaseScreen() {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    @IBAction func openSettingsAction(_: Any) {
        if let settingsView: ImportContacsSettingsViewController = UIStoryboard(type: .eventImport).instantiateViewController() {
            navigationController?.pushViewController(settingsView, animated: true)
        }
    }
}

extension ImportContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? selectedContactPreviews.count : selectedImportedContactPreviews.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        return selectedImportedContactPreviews.count == 0 ? 1 : 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewBirthdayTableViewCell", for: indexPath) as? PreviewBirthdayTableViewCell else {
            return UITableViewCell()
        }

        var currentPreview: ContactPreviewViewModel?
        let contactAlreadyImported = indexPath.section == 1

        if indexPath.section == 0 {
            currentPreview = selectedContactPreviews[safe: indexPath.row]
        } else {
            currentPreview = selectedImportedContactPreviews[safe: indexPath.row]
        }

        guard let preview = currentPreview else {
            return UITableViewCell()
        }

        let initials = NamesCreator.createInitials(for: preview.firstName, lastName: preview.lastName)
        let name = NamesCreator.createCombinedName(for: preview.firstName, lastName: preview.lastName)

        cell.alpha = contactAlreadyImported ? 0.4 : 1.0
        cell.nameLabel.text = name
        cell.subtitleLabel.text = ProjectDateFormatter.formatDateForBirthdayPreview(birthdate: preview.birthday)

        cell.setupPicture(parent: self, initials: initials, photo: preview.picture, colorGradient: preview.colorGradient ?? colorGradient, shadow: false)
    
        cell.accessoryType = selectedContactIds.contains(preview.cnContactId) ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "ImportBirthdayHeaderTableViewCell") as? DefaultSectionHeaderTableViewCell else {
            return nil
        }

        if section == 0, contactPreviews.count > 0 {
            headerCell.titleLabel.text = "app.views.import.list.sectionTitle.toImport".localize()
            return headerCell.contentView
        }

        if section == 1 {
            headerCell.titleLabel.text = "app.views.import.list.sectionTitle.alreadyImported".localize()
            return headerCell.contentView
        }

        return nil
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || (section == 0 && importedContactPreviews.count > 0) {
            return 28
        }

        return 0.01
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return selectedContactPreviews.count == 0 ? 0.01 : 15
        } else {
            return selectedImportedContactPreviews.count == 0 ? 0.01 : 15
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = indexPath.section == 0 ? selectedContactPreviews[indexPath.row] : selectedImportedContactPreviews[indexPath.row]

        if selectedContactIds.contains(contact.cnContactId) {
            selectedContactIds = selectedContactIds.filter { $0 != contact.cnContactId }
        } else {
            selectedContactIds.append(contact.cnContactId)
        }

        contactsPreviewTableView.reloadData()
        updateSelectAllButton()
    }
}

extension ImportContactsViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            selectedContactPreviews = contactPreviews.filter { birthday in
                birthday.firstName.localizedCaseInsensitiveContains(searchText) ||
                    birthday.lastName.localizedCaseInsensitiveContains(searchText)
            }

            selectedImportedContactPreviews = importedContactPreviews.filter { birthday in birthday.firstName.localizedCaseInsensitiveContains(searchText) ||

                birthday.lastName.localizedCaseInsensitiveContains(searchText)
            }

        } else {
            selectedContactPreviews = contactPreviews
            selectedImportedContactPreviews = importedContactPreviews
        }

        contactsPreviewTableView.reloadData()
    }

    func willDismissSearchController(_: UISearchController) {
        toggleSelectAllButton(visible: true)
    }

    func willPresentSearchController(_: UISearchController) {
        toggleSelectAllButton(visible: false)
    }
}
