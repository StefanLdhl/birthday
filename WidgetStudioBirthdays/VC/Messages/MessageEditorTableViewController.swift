//
//  MessageEditorTableViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.01.21.
//

import UIKit

class MessageEditorTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    // Outlets
    @IBOutlet var messagesTextView: UITextView!
    @IBOutlet var titleTextfield: UITextField!
    @IBOutlet var placeholdersCollectionView: UICollectionView!

    @IBOutlet var ownNameTextfield: UITextField!

    @IBOutlet var isDefaultSwitch: UISwitch!
    @IBOutlet var isDefaultInfoLabel: UILabel!

    // Input
    public var message: MessagesViewModel!
    public var delegate: EditMessageDelegate?

    var defaultStyle: [NSAttributedString.Key: Any] = [:]
    var highlightedStyle: [NSAttributedString.Key: Any] = [:]

    var originalTitle = ""
    var originalContent = ""
    var shownOwnNameField = false

    private var availablePlaceholder: [MessageTemplatePlaceholder] = [.firstName, .lastName, .ownName, .birthday, .age, .agePlus1, .ordinal, .ordinalPlus1]
    override func viewDidLoad() {
        super.viewDidLoad()

        if let flowLayout = placeholdersCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        title = "app.views.messageEditor.title".localize()

        originalTitle = message.title
        originalContent = message.content

        messagesTextView.text = originalContent
        titleTextfield.text = originalTitle

        isDefaultSwitch.setOn(message.isDefault, animated: false)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3

        let globalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), .paragraphStyle: paragraphStyle]

        defaultStyle = [.foregroundColor: UIColor.label].merging(globalAttributes) { current, _ in current }
        highlightedStyle = [.backgroundColor: (UIColor(named: "defaultColor7") ?? .purple).withAlphaComponent(1.0), .foregroundColor: UIColor.white].merging(globalAttributes) { current, _ in current }

        messagesTextView.addDoneButtonOnKeyboard()

        titleTextfield.placeholder = "app.views.messageEditor.list.namTextfield.placeholder".localize()
        isDefaultInfoLabel.text = "app.views.messageEditor.list.isDefaultSwitch.infoLabel.text".localize()

        ownNameTextfield.text = GroupedUserDefaults.string(forKey: .crossDeviceUserInfo_ownName)
        ownNameTextfield.placeholder = "app.views.messageEditor.list.ownNameTextfield.placeholder".localize()

        reformatAttributedText()
        
        
        //Accessibility
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 58
    }

    override func viewDidAppear(_: Bool) {
        placeholdersCollectionView.flashScrollIndicators()
    }

    private func saveAll() {
        if originalContent != messagesTextView.text || originalTitle != titleTextfield.text {
            message.content = messagesTextView.text
            message.title = titleTextfield.text ?? ""
            message.localizable = false
        }

        GroupedUserDefaults.set(value: ownNameTextfield.text, for: .crossDeviceUserInfo_ownName)
        message.isDefault = isDefaultSwitch.isOn

        if let savedModel = MessageRepository.updateFromViewModel(messageViewModel: message), let identifier = savedModel.identifier {
            message.identifier = identifier
        }

        delegate?.messageChanged(message: message)
    }

    override func viewWillDisappear(_: Bool) {
        saveAll()
    }

    private func insertPlaceholderAtCursorPosition(placeholder: MessageTemplatePlaceholder) {
        setTextToCurrentCursorPosition(text: placeholder.getPlaceholderString())
    }

    private func reformatAttributedText() {
        // Cursor Position speichern
        let cursorPosition: UITextRange? = messagesTextView.selectedTextRange

        var attributedString = NSMutableAttributedString(string: messagesTextView.text, attributes: defaultStyle)

        for placeholder in availablePlaceholder {
            attributedString = generateAttributedString(with: placeholder.getPlaceholderString(), targetString: attributedString) ?? attributedString
        }

        messagesTextView.attributedText = attributedString

        // Cursorposition setzen
        if let validCursorPosition = cursorPosition, let newPosition = messagesTextView.position(from: validCursorPosition.start, offset: 0)
        {
            messagesTextView.selectedTextRange = messagesTextView.textRange(from: newPosition, to: newPosition)
        }

        // OwnNameTextfield ein und aublenden
        let ownNameFieldUsed = messagesTextView.text.contains("[ownName]")

        if shownOwnNameField != ownNameFieldUsed {
            shownOwnNameField = ownNameFieldUsed

            let isFirstResponder = messagesTextView.isFirstResponder
            tableView.reloadData()

            if shownOwnNameField, ownNameTextfield.text?.count ?? 0 == 0 {
                ownNameTextfield.becomeFirstResponder()
            } else if isFirstResponder {
                messagesTextView.becomeFirstResponder()
            }
        }
    }

    func textViewDidChange(_: UITextView) {
        reformatAttributedText()
    }

    private func setTextToCurrentCursorPosition(text: String) {
        if let textRange = messagesTextView.selectedTextRange {
            messagesTextView.replace(textRange, withText: "\(text)")
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return shownOwnNameField ? 1 : 0
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "app.views.messageEditor.list.sectionHeader.content.title".localize()
        }

        return nil
    }

    override func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.01
        }

        if section == 3, !shownOwnNameField {
            return 0.01
        }

        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0.01
        }

        if section == 3, !shownOwnNameField {
            return 0.01
        }

        return super.tableView(tableView, heightForFooterInSection: section)
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 4 {
            return "app.views.messageEditor.list.sectionFooter.isDefault.title".localize()
        }

        if section == 3, shownOwnNameField {
            return "app.views.messageEditor.list.sectionFooter.ownName.title".localize()
        }

        if section == 2 {
            return "app.views.messageEditor.list.sectionFooter.placeHolderInfo.title".localize()
        }

        return nil
    }

    override func tableView(_: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 2 {
            let footer: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            footer.textLabel?.textAlignment = .right
        }
    }
    
    
    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func generateAttributedString(with searchTerm: String, targetString: NSMutableAttributedString) -> NSMutableAttributedString? {
        let attributedString = targetString
        do {
            let regex = try NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: searchTerm).trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .regularExpression, locale: .current), options: .caseInsensitive)

            for match in regex.matches(in: targetString.string.folding(options: .regularExpression, locale: .current), options: .withTransparentBounds, range: NSRange(location: 0, length: targetString.string.utf16.count)) {
                attributedString.addAttributes(highlightedStyle, range: match.range)
            }
            return attributedString
        } catch {
            NSLog("Error creating regular expresion: \(error)")
            return nil
        }
    }
}

extension MessageEditorTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return availablePlaceholder.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageTemplatePlaceholderCollectionViewCell", for: indexPath) as? MessageTemplatePlaceholderCollectionViewCell else {
            return UICollectionViewCell()
        }

        guard let placeholder = availablePlaceholder[safe: indexPath.row] else {
            return UICollectionViewCell()
        }

        cell.flexTitleLabel.text = placeholder.localizedName()
        cell.roundBackgroundView.layer.cornerRadius = 5
        cell.clipsToBounds = true

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let placeholder = availablePlaceholder[safe: indexPath.row] else {
            return
        }

        insertPlaceholderAtCursorPosition(placeholder: placeholder)
    }
}

enum MessageTemplatePlaceholder: String, CaseIterable {
    case firstName
    case lastName
    case birthday
    case ownName
    case age
    case agePlus1
    case ordinal
    case ordinalPlus1

    public func localizedName() -> String {
        return "app.messageTemplates.placeholderTitle.\(rawValue)".localize()
    }

    public func getPlaceholderString() -> String {
        return "[\(rawValue)]"
    }

    public static func fillPlaceholderOfText(text: String, birthday: BirthdayInfoViewModel) -> String {
        var returnString = text

        for placeholderType in MessageTemplatePlaceholder.allCases {
            returnString = returnString.replacingOccurrences(of: placeholderType.getPlaceholderString(), with: placeholderType.getValueForPlaceholder(birthday: birthday))
        }

        return returnString
    }

    public func getValueForPlaceholder(birthday: BirthdayInfoViewModel) -> String {
        switch self {
        case .firstName:
            return birthday.firstName
        case .lastName:
            return birthday.lastName
        case .birthday:
            return ProjectDateFormatter.formatDate(date: birthday.birthdate, showYearIfAvailable: false)
        case .ownName:
            return GroupedUserDefaults.string(forKey: .crossDeviceUserInfo_ownName) ?? ""
        case .age:
            return birthday.currentAge == nil ? "" : "\(birthday.currentAge ?? 0)"
        case .agePlus1:
            return birthday.currentAge == nil ? "" : "\((birthday.currentAge ?? 0) + 1)"
        case .ordinal: do {
                guard let validAge = birthday.currentAge else {
                    return ""
                }

                return getOrdinalAgeFor(age: validAge)
            }

        case .ordinalPlus1: do {
                guard let validAge = birthday.currentAge else {
                    return ""
                }

                return getOrdinalAgeFor(age: validAge + 1)
            }
        }
    }

    private func getOrdinalAgeFor(age: Int) -> String {
  
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: age)) ?? ""
    }
}
