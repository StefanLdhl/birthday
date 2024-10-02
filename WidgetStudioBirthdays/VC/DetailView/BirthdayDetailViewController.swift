//
//  BirthdayDetailViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 22.11.20.
//

import ContactsUI
import Haptica
import MessageUI
import SwiftDate
import UIKit

class BirthdayDetailViewController: UITableViewController, UIGestureRecognizerDelegate {
    public var birthday: BirthdayInfoViewModel!
    public var isNew = false
    public var isForPreview = false
    public var redirectToEditMode = false

    @IBOutlet var profilePictureTopSpace: NSLayoutConstraint!
    @IBOutlet var headerActionButtons: [UIButton]!

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var editButton: UIButton!

    @IBOutlet var headerCountdownView: UIView!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var groupNameView: UIView!
    @IBOutlet var groupNameLabel: UILabel!

    @IBOutlet var confettiImage: UIImageView!
    @IBOutlet var milestoneImageView: UIImageView!

    @IBOutlet var countdownLabel: UILabel!
    @IBOutlet var countdownDetailLabel: UILabel!

    @IBOutlet var countdownLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet var actionsCollectionView: UICollectionView!

    @IBOutlet var profilePicture: ProfilePictureView!
    @IBOutlet var readOnlyHeaderLabel: UILabel!

    let countdownGradientLayer = CAGradientLayer()

    var countdownTimer = Timer()
    var partyDate = Date()
    var quickActions: [QuickAction] = QuickActionManager.getUsersQuickActions()
    var viewAlreadyDidLayoutSubviews = false
    var isReadonlyEvent = false

    override func viewDidLoad() {
        super.viewDidLoad()

        headerCountdownView.layer.cornerRadius = 6
        headerCountdownView.clipsToBounds = true

        groupNameView.layer.cornerRadius = 6
        groupNameView.clipsToBounds = true

        updateView()

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        recognizer.minimumPressDuration = 0.35
        recognizer.delegate = self
        recognizer.delaysTouchesBegan = true
        actionsCollectionView.addGestureRecognizer(recognizer)

        if isNew {
            switchToEditMode()
        }

        doneButton.setTitle("main.universal.done".localize(), for: .normal)
        editButton.setTitle("main.universal.edit".localize(), for: .normal)

        readOnlyHeaderLabel.text = "app.views.studio.list.title.readonly".localize()
        readOnlyHeaderLabel.isHidden = !isReadonlyEvent

        // Für Peek & Pop Preview
        if isForPreview {
            doneButton.isHidden = true
            editButton.isHidden = true
            tableView.showsVerticalScrollIndicator = false

            profilePictureTopSpace.constant = 45
        } else if redirectToEditMode {
            switchToEditMode()
        }
    }

    @objc func handleLongPress(gesture: UILongPressGestureRecognizer!) {
        let p = gesture.location(in: actionsCollectionView)

        guard gesture.state == .began, let indexPath = actionsCollectionView.indexPathForItem(at: p) else {
            return
        }

        guard let action = quickActions[safe: indexPath.row] else {
            return
        }

        Haptic.impact(.medium).generate()

        let cellContentView = actionsCollectionView.cellForItem(at: indexPath)?.contentView
        showTemplateMenuToChooseFrom(action: action, sourceView: cellContentView)
    }

    override func viewDidLayoutSubviews() {
        guard !viewAlreadyDidLayoutSubviews else {
            return
        }
        viewAlreadyDidLayoutSubviews = true
        setupGradientCountdown()
        refreshGradientCountdown()
    }

    private func setupGradientCountdown() {
        headerCountdownView.layoutIfNeeded()
        countdownGradientLayer.colors = []
        countdownGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        countdownGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        countdownGradientLayer.frame = headerCountdownView.bounds
        headerCountdownView.layer.insertSublayer(countdownGradientLayer, at: 0)
    }

    private func openPurchaseScreen(isFirstStart: Bool = false) {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            Haptic.impact(.light).generate()
            purchaseScreen.isFirstAppStart = isFirstStart
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    private func refreshGradientCountdown() {
        let color1 = birthday.group.colorGradient.color1.uiColor
        let color2 = birthday.group.colorGradient.color2.uiColor
        countdownGradientLayer.colors = [color1.cgColor, color2.cgColor]
    }

    private func updateView() {
        DispatchQueue.main.async { [self] in
            let name = NamesCreator.createCombinedName(for: birthday.firstName, lastName: birthday.lastName)
            nameLabel.text = name

            if let currentAge = birthday.currentAge, currentAge >= 0 {
                let age = birthday.birthdayIsToday ? currentAge : currentAge + 1

                let formatter = NumberFormatter()
                formatter.numberStyle = .ordinal
                let first = formatter.string(from: NSNumber(value: age)) ?? ""
                let subtitle = "app.views.birthdayDetailView.countdownView.subtitleAgeCount.%@".localize(values: first)

                countdownDetailLabel.text = (birthday.birthdayIsToday && birthday.birthdayType != .normal) || (!birthday.birthdayIsToday && birthday.nextAgeBirthdayType != .normal) ? "★ \(subtitle) ★" : subtitle

                countdownDetailLabel.isHidden = false
                countdownLabelBottomConstraint.constant = 0
            } else {
                countdownDetailLabel.isHidden = true
                countdownLabelBottomConstraint.constant = -10
            }

            profilePicture.preparePicture(initials: birthday.initials, photo: birthday.profilePicture, colorGradient: birthday
                .group.colorGradient, shadow: true)

            profilePicture.renderPicture()

            subtitleLabel.text = "\(ProjectDateFormatter.formatDate(date: birthday.birthdate)) • \(birthday.birthdate.zodiacSignString)"

            let groupName = birthday.group.name
            groupNameLabel.text = groupName
            groupNameView.isHidden = groupName.count == 0

            refreshGradientCountdown()
            restartCountdown()
        }
    }

    private func restartCountdown() {
        partyDate = getPartDate()

        refreshCountdown()

        countdownTimer.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshCountdown), userInfo: nil, repeats: true)
    }

    private func showOneTimePrivacyInfo(originalAction: QuickAction, originalSourceView: UIView? = nil, originalText: String) {
        let alert = UIAlertController(title: "app.views.birthdayDetailView.privacyInfoAlert.title".localize(), message: "app.views.birthdayDetailView.privacyInfoAlert.content".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .cancel, handler: { _ in

            self.handleQuickActionForText(action: originalAction, sourceView: originalSourceView, text: originalText)
        }))

        present(alert, animated: true, completion: nil)
    }

    private func getPartDate() -> Date {
        return birthday.birthdateInYear.dateWithoutTime
    }

    private func userHasBirthday() {
        DispatchQueue.main.async { [weak self] in
            self?.countdownLabel.text = "app.views.birthdayDetailView.countdownView.onBirthdayText".localize()
            self?.confettiImage.isHidden = false
            self?.milestoneImageView.isHidden = false
            self?.checkMilestoneImage()
        }
    }

    private func checkMilestoneImage() {
        guard birthday.birthdayIsToday else {
            milestoneImageView.isHidden = true
            return
        }

        milestoneImageView.isHidden = false
        milestoneImageView.image = UIImage(named: birthday.birthdayType.imageName())
    }

    @IBAction func doneAction(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func editAction(_: Any) {
        switchToEditMode()
    }

    private func switchToEditMode() {
        if isReadonlyEvent, !CurrentUser.isUserPro() {
            openPurchaseScreen()
            return
        }

        if let editView: BirthdayEditViewController = UIStoryboard(type: .main).instantiateViewController() {
            editView.birthday = birthday
            editView.delegate = self
            editView.isNew = isNew

            navigationController?.fadeTo(editView)
        }
    }

    @objc func refreshCountdown() {
        let interval = partyDate.timeIntervalSince(Date())

        if interval < 0 {
            userHasBirthday()
            partyDate = getPartDate()

            return
        }

        var countdownString = interval.toString {
            $0.maximumUnitCount = 4
            $0.locale = Locale.preferredLocale()
            $0.allowedUnits = [.day, .hour, .minute, .second]
            $0.collapsesLargestUnit = true
            $0.unitsStyle = .abbreviated
            $0.zeroFormattingBehavior = .dropLeading
        }
        countdownString = countdownString.replacingOccurrences(of: " ", with: "   ")

        DispatchQueue.main.async { [weak self] in
            self?.countdownLabel.text = countdownString
            self?.confettiImage.isHidden = true
            self?.milestoneImageView.isHidden = true
        }
    }

    override func viewDidDisappear(_: Bool) {
        countdownTimer.invalidate()
    }

    private func openUrl(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func showTemplateMenuToChooseFrom(action: QuickAction, sourceView: UIView?) {
        let allTemplates = MessageRepository.getAllMessages().sorted(by: { $0.isDefault && !$1.isDefault })

        guard allTemplates.count > 0 else {
            return
        }

        let alertTitle = "app.views.birthdayDetailView.quickAction.chooseTemplateMenu.title".localize()
        let alertContent = "app.views.birthdayDetailView.quickAction.chooseTemplateMenu.content.%@".localize(values: birthday.firstName)

        var alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .actionSheet)

        if let _ = alert.popoverPresentationController {
            alert = UIAlertController(title: alertTitle, message: alertContent, preferredStyle: .alert)
        }

        let preferredTemplateId = birthday.group.preferredMessageTemplate?.identifier ?? "-"

        for template in allTemplates.map({ MessagesViewModel(message: $0) }) {
            let title = template.identifier == preferredTemplateId ? "\(template.title) (\("app.views.birthdayDetailView.quickAction.chooseTemplateMenu.defaultInfoText".localize()))" : "\(template.title)"

            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in

                self.handleQuickActionForText(action: action, sourceView: sourceView, text: MessageTemplatePlaceholder.fillPlaceholderOfText(text: template.content, birthday: self.birthday))

            }))
        }

        alert.addAction(UIAlertAction(title: "app.views.birthdayDetailView.quickAction.chooseTemplateMenu.emptyTemplateAction".localize(), style: .default, handler: { _ in

            self.handleQuickActionForText(action: action, sourceView: sourceView, text: "")
        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }

    private func processActionButton(action: QuickAction, sourceView: UIView?) {
        if let preferredMessageTemplate = birthday.group.preferredMessageTemplate {
            let textToShare = MessageTemplatePlaceholder.fillPlaceholderOfText(text: preferredMessageTemplate.content, birthday: birthday)

            handleQuickActionForText(action: action, sourceView: sourceView, text: textToShare)

        } else {
            showTemplateMenuToChooseFrom(action: action, sourceView: sourceView)
        }

        /*

         let allTemplates = MessageRepository.getAllMessages().sorted(by: { $0.isDefault && !$1.isDefault })
         if let firstTemplate = allTemplates.first {
             templateToChoose = MessagesViewModel(message: firstTemplate)
         }

         var textToShare = ""

         if let validTemplate = templateToChoose {
             textToShare = MessageTemplatePlaceholder.fillPlaceholderOfText(text: validTemplate.content, birthday: birthday)
         }

         handleQuickActionForText(action: action, sourceView: sourceView, text: textToShare)*/
    }
}

extension BirthdayDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return min(quickActions.count, 6)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BirthdayActionCollectionViewCell", for: indexPath) as! BirthdayActionCollectionViewCell

        guard let action = quickActions[safe: indexPath.row] else {
            return UICollectionViewCell()
        }

        cell.actionTitleLabel.text = action.localizedTitle()
        cell.actionIconImage.image = action.icon()

        cell.innerView.layer.cornerRadius = 6
        cell.innerView.clipsToBounds = true

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let action = quickActions[safe: indexPath.row] else {
            return
        }
        processActionButton(action: action, sourceView: collectionView.cellForItem(at: indexPath)?.contentView)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let noOfCellsInRow = 3

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 0, height: 0)
        }

        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: 65)
    }
}

extension BirthdayDetailViewController: EditBirthdayDelegate {
    func birthdayChangeCanceled() {
        restartCountdown()
    }

    func birthdayChanged(updatedBirthday: BirthdayInfoViewModel) {
        birthday = updatedBirthday
        updateView()
        isNew = false
        NotificationCenter.default.post(name: Notification.Name.birthdayDatabaseContentChanged, object: nil)
    }
}

// Action Buttons
extension BirthdayDetailViewController: MFMessageComposeViewControllerDelegate, CNContactPickerDelegate, MFMailComposeViewControllerDelegate {
    private func handleQuickActionForText(action: QuickAction, sourceView: UIView? = nil, text: String) {
        var textToSend = text

        if !GroupedUserDefaults.bool(forKey: .localUserInfo_quickActionPrivacyInfoShown) {
            GroupedUserDefaults.set(value: true, for: .localUserInfo_quickActionPrivacyInfoShown)
            showOneTimePrivacyInfo(originalAction: action, originalSourceView: sourceView, originalText: text)
        }

        switch action {
        case .phone:
            do {
                openTelephoneBook()
            }

        case .mail:
            do {
                openMail(text: textToSend)
            }

        case .message: do {
                openImessage(text: textToSend)
            }

        case .telegram: do {
                textToSend = textToSend.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? ""
                openUrl(urlString: "tg://msg?text=\(textToSend)")
            }

        case .whatsapp: do {
                textToSend = textToSend.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? ""
                openUrl(urlString: "whatsapp://send?text=\(textToSend)")
            }

        case .otherApps: do {
                openActivityView(text: textToSend, view: sourceView)
            }

        case .threema:
            textToSend = textToSend.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? ""
            openUrl(urlString: "https://threema.id/compose?text=\(textToSend)")
        }
    }

    // Telefon
    private func openTelephoneBook() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactPhoneNumbersKey]
        present(contactPicker, animated: true, completion: nil)
    }

    // Other apps
    private func openActivityView(text: String, view: UIView?) {
        let ac = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        if let sourceView = view {
            ac.popoverPresentationController?.sourceView = sourceView

        } else {
            ac.popoverPresentationController?.sourceView = profilePicture
        }

        present(ac, animated: true)
    }

    // Message
    private func openImessage(text: String) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()

            controller.body = text
            controller.messageComposeDelegate = self
            controller.recipients = []
            present(controller, animated: true, completion: nil)
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith _: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

    // Mail
    private func openMail(text: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([""])
            mail.setSubject("app.views.birthdayDetailView.quickAction.emailSubject".localize())
            mail.setMessageBody("\(text)", isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            let subject = "app.views.birthdayDetailView.quickAction.emailSubject".localize().addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? ""
            let content = text.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? ""

            openUrl(urlString: "mailto:?subject=\(subject)&body=\(content)")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
