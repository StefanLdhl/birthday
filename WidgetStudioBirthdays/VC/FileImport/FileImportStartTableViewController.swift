//
//  FileImportStartTableViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.01.21.
//

import CoreServices
import Haptica
import ProgressHUD
import UIKit

class FileImportStartTableViewController: UIViewController {
    @IBOutlet var fileImportTableView: UITableView!
    @IBOutlet var continueBarButtonItem: UIBarButtonItem!
    @IBOutlet var helpButton: UIBarButtonItem!

    private var importMode = false
    private var mappingPairs: [MappingPair] = []
    private var mappingTypes: [ContactMappingType] = ContactMappingType.allCases

    public var pathToOpen: String?
    public var currentFile: ImportFileInfo?

    private var somethingToSave = false

    private var userIsPro = false
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "app.views.fileImport.title".localize()
        navigationController?.navigationBar.prefersLargeTitles = true

        continueBarButtonItem.title = "main.universal.continue".localize()
        refreshProUserState()

        if let validPathToOpen = pathToOpen {
            handlePath(path: validPathToOpen)
        }

        updateContinueButtonState()
        isModalInPresentation = true
        navigationController?.presentationController?.delegate = self

        NotificationCenter.default.addObserver(forName: Notification.Name("UserProStateChanged"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async { [weak self] in
                self?.refreshProUserState()
            }
        }
    }

    private func refreshProUserState() {
        userIsPro = CurrentUser.isUserPro()

        helpButton.isEnabled = userIsPro
        helpButton.tintColor = userIsPro ? UIColor.systemBlue : UIColor.clear
    }

    private func handlePath(path: String) {
        guard userIsPro else {
            openPurchaseScreen()
            return
        }

        do {
            let url = URL(fileURLWithPath: path)
            let fileContent = try String(contentsOf: url, encoding: .utf8)

            guard url.pathExtension.lowercased().contains("csv") else {
                showErrorAlert(title: "app.views.fileImport.errorHandling.fileError.title".localize(), content: "app.views.fileImport.errorHandling.fileError.format.desc.%@".localize(values: url.pathExtension))
                return
            }

            somethingToSave = true
            currentFile = ImportFileInfo(content: fileContent, name: url.lastPathComponent, type: url.pathExtension)
            updateViewForCurrentFile()
        } catch {
            showErrorAlert(title: "app.views.fileImport.errorHandling.fileError.title".localize(), content: "app.views.fileImport.errorHandling.fileError.desc".localize())
        }
    }

    private func openPurchaseScreen() {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            Haptic.impact(.light).generate()
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    private func openDocumentPicker() {
        
        guard userIsPro else {
            openPurchaseScreen()
            return
        }
        
    
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }

    private func resetAll() {
        currentFile = nil
        updateViewForCurrentFile()
        somethingToSave = false
    }

    private func updateViewForCurrentFile() {
        guard let validFile = currentFile else {
            mappingPairs.removeAll()
            importMode = false
            fileImportTableView.reloadData()
            updateContinueButtonState()
            return
        }

        importMode = false
        startAnalysingTable(data: validFile.content)
        fileImportTableView.reloadData()
        updateContinueButtonState()
    }

    private func updateContinueButtonState() {
        let inputValid = checkIfInputIsValid()

        if continueBarButtonItem.isEnabled != inputValid {
            DispatchQueue.main.async {
                self.continueBarButtonItem.isEnabled = inputValid
            }
        }
    }

    private func checkIfInputIsValid() -> Bool {
        guard currentFile != nil else {
            return false
        }

        guard mappingPairs.count > 0 else {
            return false
        }

        let mappingItems = mappingPairs.map { $0.mappingValue }

        let valid = (mappingItems.contains(.birthdate) || (mappingItems.contains(.day) && mappingItems.contains(.month))) && (mappingItems.contains(.fullName) || mappingItems.contains(.firstName) || mappingItems.contains(.lastName))

        return valid
    }

    private func deleteCurrentFile() {
        let alert = UIAlertController(title: "app.views.fileImport.start.table.cells.upload.removeFileAlert.title".localize(), message: "app.views.fileImport.start.table.cells.upload.removeFileAlert.desc".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .default, handler: { _ in

            self.resetAll()
        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in

        }))

        present(alert, animated: true, completion: nil)
    }

    private func startAnalysingTable(data: String) {
        let importResult = ExcelImporter.getColumnNames(fileContent: data)

        if let error = importResult.error {
            resetAll()
            showErrorAlert(title: "app.views.fileImport.errorHandling.importProcessError.default.title".localize(), content: "\("app.views.fileImport.errorHandling.importProcessError.errorFile.desc".localize())\n\n\(error)")
            return
        }

        let pairs = importResult.result
        guard pairs.count > 0 else {
            resetAll()
            showErrorAlert(title: "app.views.fileImport.errorHandling.importProcessError.default.title".localize(), content: "app.views.fileImport.errorHandling.importProcessError.emptyFile.desc".localize())
            return
        }

        mappingPairs.removeAll()
        mappingPairs = pairs
        importMode = true
    }

    private func openMappingMenuForPair(pair: MappingPair) {
        let usedTypes = mappingPairs.compactMap { $0.mappingValue }
        let avaliableTypes = mappingTypes.filter { !usedTypes.contains($0) }

        if avaliableTypes.count == 0, pair.mappingValue == .none {
            return
        }

        let alertTitle = "app.views.fileImport.start.table.mappingMenu.title".localize()
        let alertContent = "app.views.fileImport.start.table.mappingMenu.desc.%@".localize(values: pair.columnName)
        
        var alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .actionSheet)

        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .alert)
        }
        
        for avaliableType in avaliableTypes {
            alert.addAction(UIAlertAction(title: avaliableType.localizedName(), style: .default, handler: { _ in
                self.mapItems(pair: pair, type: avaliableType)
                self.updateContinueButtonState()
                self.fileImportTableView.reloadData()
            }))
        }

        if pair.mappingValue != .none {
            alert.addAction(UIAlertAction(title: "app.views.fileImport.start.table.mappingMenu.action.removeLink.title".localize(), style: .destructive, handler: { _ in
                self.removeLinkedItem(pair: pair)
                self.updateContinueButtonState()

                self.fileImportTableView.reloadData()
            }))
        }

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in }))
        present(alert, animated: true, completion: nil)
    }

    private func mapItems(pair: MappingPair, type: ContactMappingType) {
        guard let pairIndex = mappingPairs.firstIndex(where: ({ $0.columnName == pair.columnName })) else {
            return
        }

        mappingPairs[pairIndex].mappingValue = type
    }

    private func removeLinkedItem(pair: MappingPair) {
        guard let pairIndex = mappingPairs.firstIndex(where: ({ $0.columnName == pair.columnName })) else {
            return
        }
        mappingPairs[pairIndex].mappingValue = .none
    }

    private func showErrorAlert(title: String, content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .cancel, handler: { _ in

        }))

        present(alert, animated: true, completion: nil)
    }

    private func startImportAction() {
        ProgressHUD.show(nil, interaction: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
            self.startImport()
        }
    }

    private func startImport() {
        let alertTitle = "app.views.fileImport.errorHandling.importProcessError.default.title".localize()

        guard checkIfInputIsValid() else {
            showErrorAlert(title: "app.views.fileImport.errorHandling.importProcessError.input.title".localize(), content: "app.views.fileImport.errorHandling.importProcessError.input.title".localize())
            ProgressHUD.dismiss()
            return
        }

        guard let validFile = currentFile else {
            showErrorAlert(title: alertTitle, content: "app.views.fileImport.errorHandling.importProcessError.missingFile.desc".localize())
            ProgressHUD.dismiss()
            return
        }

        ExcelImporter.getContactPreviews(fileContent: validFile.content, pairs: mappingPairs) { previewResult in

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ProgressHUD.dismiss()
            }

            if let error = previewResult.error {
                self.showErrorAlert(title: alertTitle, content: "\("app.views.fileImport.errorHandling.importProcessError.processingError.desc".localize()).\n\n\(error)")
                return
            }
            guard previewResult.previews.count > 0 else {
                self.showErrorAlert(title: alertTitle, content: "\("app.views.fileImport.errorHandling.importProcessError.processingErrorLines.desc".localize())\n\n\(previewResult.logBook.joined(separator: "\n"))")
                return
            }
            self.pushToPreviewList(result: previewResult, fileName: validFile.name)
        }
    }

    private func pushToPreviewList(result: PreviewImportResult, fileName: String) {
        if let previewListViewController: FileImportPreviewListViewController = UIStoryboard(type: .fileImport).instantiateViewController() {
            previewListViewController.importResult = result
            previewListViewController.fileName = fileName

            navigationController?.pushViewController(previewListViewController, animated: true)
        }
    }

    func checkForChanges() {
        if !somethingToSave {
            dismiss(animated: true, completion: nil)
            return
        }

        let alertTitle = "app.views.fileImport.start.saveMenu.title".localize()
        let alertContent = "app.views.fileImport.start.saveMenu.desc".localize()

        var alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .actionSheet)
        
        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .alert)
        }

        alert.addAction(UIAlertAction(title: "app.views.fileImport.start.saveMenu.action.discard".localize(), style: .destructive, handler: { _ in

            self.dismiss(animated: true, completion: nil)

        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }

    @IBAction func continueButtonAction(_: Any) {
        startImportAction()
    }

    @IBAction func cancelButtonAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func helpButtonTapped(_: Any) {
        
        guard userIsPro else {
            openPurchaseScreen()
            return
        }
        
        if let webViewController: FileImportWebViewController = UIStoryboard(type: .fileImport).instantiateViewController() {
            webViewController.urlToLoad = "https://martingo.studio/birthday-import.html"

            let navController = UINavigationController(rootViewController: webViewController)
            navController.navigationBar.prefersLargeTitles = false
            present(navController, animated: true, completion: nil)
        }
    }
}

extension FileImportStartTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : mappingPairs.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        importMode ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FileImportUploadTableViewCell", for: indexPath) as? FileImportUploadTableViewCell else {
                return UITableViewCell()
            }

            if let validFile = currentFile {
                cell.fileNameLabel.text = validFile.name
                cell.fakeButtonUploadLabel.text = "app.views.fileImport.start.table.cells.upload.deleteButton.title".localize()
                cell.fileNameLabel.textColor = .label
                cell.fakeButtonUploadLabel.textColor = UIColor(named: "defaultColor1") ?? .red

            } else {
                cell.fileNameLabel.text = "app.views.fileImport.start.table.cells.upload.noFileLabel.text".localize()
                cell.fakeButtonUploadLabel.text = "app.views.fileImport.start.table.cells.upload.uploadButton.title".localize()
                cell.fileNameLabel.textColor = .lightGray
                cell.fakeButtonUploadLabel.textColor = .systemBlue
            }

            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FileImportMappingTableViewCell", for: indexPath) as? FileImportMappingTableViewCell else {
                return UITableViewCell()
            }

            guard let pair = mappingPairs[safe: indexPath.row] else {
                return UITableViewCell()
            }

            cell.columnNameLabel.text = pair.columnName
            cell.mappingValueView.layer.cornerRadius = 7
            cell.mappingValueView.clipsToBounds = true

            cell.mappingFakeButtonLabel.text = "app.views.fileImport.start.table.cells.mapping.mapButton.title".localize()
            if pair.mappingValue != .none {
                cell.mappingLabel.text = pair.mappingValue.localizedName()
                cell.mappingFakeButtonLabel.isHidden = true
                cell.mappingValueView.isHidden = false

            } else {
                let usedTypes = mappingPairs.compactMap { $0.mappingValue }
                let avaliableTypes = mappingTypes.filter { !usedTypes.contains($0) }

                cell.mappingFakeButtonLabel.alpha = avaliableTypes.count > 0 ? 1.0 : 0.3
                cell.mappingFakeButtonLabel.isHidden = false
                cell.mappingValueView.isHidden = true
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            if currentFile == nil {
                openDocumentPicker()

            } else {
                deleteCurrentFile()
            }
            return
        }

        guard let pair = mappingPairs[safe: indexPath.row] else {
            return
        }

        openMappingMenuForPair(pair: pair)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "FileImportHeaderCell") as? FileImportHeaderCell else {
                return nil
            }

            headerCell.titleLabel.text = "1. \("app.views.fileImport.start.table.header.upload.title".localize())"
            return headerCell.contentView
        }

        if section == 1 {
            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "FileImportHeaderCellWithDescription") as? FileImportHeaderCellWithDescription else {
                return nil
            }

            headerCell.titleLabel.text = "2. \("app.views.fileImport.start.table.header.mapping.title".localize())"
            headerCell.columnInfoTitleLabel.text = "↓" + "app.views.fileImport.start.table.header.mapping.additionalTitle1".localize()
            headerCell.typeInfoTitleLabel.text = "↓" + "app.views.fileImport.start.table.header.mapping.additionalTitle2".localize()

            return headerCell.contentView
        }

        return nil
    }

    func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "app.views.fileImport.start.table.footer.upload.content".localize()
        }

        return "app.views.fileImport.start.table.footer.mapping.content".localize()
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 28 : 69
    }
}

extension FileImportStartTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_: UIPresentationController) {
        checkForChanges()
    }
}

extension FileImportStartTableViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            handlePath(path: url.path)
        }

        controller.dismiss(animated: true, completion: nil)
    }
}

struct ImportFileInfo {
    var content: String
    var name: String
    var type: String
}
