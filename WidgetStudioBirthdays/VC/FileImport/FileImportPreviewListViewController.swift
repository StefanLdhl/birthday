//
//  FileImportPreviewListViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.01.21.
//

import UIKit

class FileImportPreviewListViewController: UIViewController {
    @IBOutlet var importBarButton: UIBarButtonItem!
    @IBOutlet var contactsPreviewTableView: UITableView!
    @IBOutlet var selectAllButton: UIButton!
    @IBOutlet var infoButton: UIButton!

    private var searchController = UISearchController(searchResultsController: nil)

    public var fileName: String!
    public var importResult: PreviewImportResult!

    private var previews: [FileImportContactPreviewViewModel] = []
    private var visiblePreviews: [FileImportContactPreviewViewModel] = []

    let colorGradient = ColorGradientGenerator.getFallbackGradient()

    private var selectedContactIds: [String] = [] {
        didSet {
            importBarButton.isEnabled = selectedContactIds.count > 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if GroupedUserDefaults.bool(forKey: .localUserInfo_nameFormatShowLastNameFirst) {
            previews = importResult.previews.sorted(by: { $0.lastName < $1.lastName })

        } else {
            previews = importResult.previews.sorted(by: { $0.firstName < $1.firstName })
        }

        importBarButton.title = "main.universal.continue".localize()
        title = "app.views.fileImportPreview.title.%d".localize(values: previews.count)

        selectedContactIds = previews.map { $0.identifier }
        visiblePreviews = previews.map { $0 }

        updateSelectedEntriesCount()

        infoButton.isHidden = importResult.logBook.count == 0

        updateSelectAllButton()

        setupSearch()
        
        //Accessibility
        contactsPreviewTableView.rowHeight = UITableView.automaticDimension
        contactsPreviewTableView.estimatedRowHeight = 66
    }

    private func updateSelectedEntriesCount() {
        DispatchQueue.main.async {
            self.title = "app.views.fileImportPreview.title.%d".localize(values: self.selectedContactIds.count)
        }
    }

    func showLogBookInfo() {
        let alert = UIAlertController(title: "app.views.fileImportPreview.logBookButton.alert.title".localize(), message: "\("app.views.fileImportPreview.logBookButton.alert.desc".localize())\n\n\(importResult.logBook.joined(separator: "\n"))", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .cancel, handler: { _ in

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

    private func pushToSummary() {
        let contactsToImport = previews.filter { selectedContactIds.contains($0.identifier) }

        guard contactsToImport.count > 0 else {
            return
        }

        if let previewListViewController: FileImportSummaryViewController = UIStoryboard(type: .fileImport).instantiateViewController() {
            previewListViewController.previewsToImport = contactsToImport
            previewListViewController.fileName = fileName
            navigationController?.pushViewController(previewListViewController, animated: true)
        }
    }

    private func updateSelectAllButton() {
        DispatchQueue.main.async {
            self.selectAllButton.setTitle(self.selectedContactIds.count == self.previews.count ? "app.views.import.list.button.deselect.title".localize() : "app.views.import.list.button.select.title".localize(), for: .normal)
        }
    }

    private func toggleSelectAllButton(visible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.selectAllButton.alpha = visible ? 1.0 : 0.0
            self.selectAllButton.isUserInteractionEnabled = visible
        }
    }

    @IBAction func selectAllContacts(_: Any) {
        if selectedContactIds.count == previews.count {
            selectedContactIds.removeAll()
        } else {
            selectedContactIds = previews.map { $0.identifier }
        }

        contactsPreviewTableView.reloadData()
        updateSelectAllButton()
        updateSelectedEntriesCount()
    }

    @IBAction func infoButtonAction(_: Any) {
        showLogBookInfo()
    }

    @IBAction func continueButtonAction(_: Any) {
        pushToSummary()
    }
}

extension FileImportPreviewListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        visiblePreviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewBirthdayTableViewCell", for: indexPath) as? PreviewBirthdayTableViewCell else {
            return UITableViewCell()
        }

        guard let preview = visiblePreviews[safe: indexPath.row] else {
            return UITableViewCell()
        }

        let initials = NamesCreator.createInitials(for: preview.firstName, lastName: preview.lastName)
        let name = NamesCreator.createCombinedName(for: preview.firstName, lastName: preview.lastName)

        cell.nameLabel.text = name
        cell.subtitleLabel.text = ProjectDateFormatter.formatDateForBirthdayPreview(birthdate: preview.birthday)

        cell.setupPicture(parent: self, initials: initials, photo: nil, colorGradient: colorGradient, shadow: false)

        cell.accessoryType = selectedContactIds.contains(preview.identifier) ? .checkmark : .none

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let preview = visiblePreviews[safe: indexPath.row] else {
            return
        }

        if selectedContactIds.contains(preview.identifier) {
            selectedContactIds = selectedContactIds.filter { $0 != preview.identifier }
        } else {
            selectedContactIds.append(preview.identifier)
        }

        contactsPreviewTableView.reloadData()
        updateSelectedEntriesCount()
        updateSelectAllButton()
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension FileImportPreviewListViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            visiblePreviews = previews.filter { birthday in
                birthday.firstName.localizedCaseInsensitiveContains(searchText) ||
                    birthday.lastName.localizedCaseInsensitiveContains(searchText)
            }

        } else {
            visiblePreviews = previews
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
