//
//  MessagesListViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.01.21.
//

import UIKit

class MessagesListViewController: UIViewController {
    @IBOutlet var messagesTableView: UITableView!

    private var messages: [MessagesViewModel] = []

    public var messagesAreEditable: Bool = true
    public var selectedMessageId: String?
    public var delegate: EditMessageDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMessages()

        messagesTableView.rowHeight = UITableView.automaticDimension

        title = "app.views.messages.title".localize()
    }

    override func viewWillAppear(_: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func reloadMessages() {
        let messageModels = MessageRepository.getAllMessages()
        messages = messageModels.map { MessagesViewModel(message: $0) }.sorted(by: { $0.title < $1.title })

        // SelectedID ggf. nil setzen, wenn nicht gefunden
        selectedMessageId = selectedMessageId == nil ? selectedMessageId : (messages.filter { $0.identifier == selectedMessageId }.count == 0) ? nil : selectedMessageId

        messagesTableView.reloadData()
    }

    private func openDetailsFor(message: MessagesViewModel) {
        guard let messageDetailsView: MessageEditorTableViewController = UIStoryboard(type: .messages).instantiateViewController() else {
            return
        }

        messageDetailsView.delegate = self
        messageDetailsView.message = message
        navigationController?.pushViewController(messageDetailsView, animated: true)
    }

    private func addNewMessage() {
        let newEntry = MessagesViewModel(identifier: "new", title: "\("app.defaultData.templates.title.new".localize()) \(messages.count + 1)", content: "app.defaultData.templates.content.new".localize())
        openDetailsFor(message: newEntry)
    }

    private func deleteMessage(indexPath: IndexPath) {
        guard indexPath.section == 0, let messageToDelete = messages[safe: indexPath.row] else {
            return
        }

        messages.remove(at: indexPath.row)

        MessageRepository.deleteMessage(identifier: messageToDelete.identifier)
        messagesTableView.deleteRows(at: [indexPath], with: .fade)
    }
}

extension MessagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (messagesAreEditable ? messages.count : messages.count + 1) : 1
    }

    func numberOfSections(in _: UITableView) -> Int {
        return messagesAreEditable ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row >= messages.count {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyMessageTemplateTableViewCell", for: indexPath) as? MessageTemplateTableViewCell else {
                    return UITableViewCell()
                }

                cell.titleLabel.text = "app.views.messagesList.selectNoTemplateCell.title".localize()
                cell.accessoryType = selectedMessageId == nil ? .checkmark : .none

                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTemplateTableViewCell", for: indexPath) as? MessageTemplateTableViewCell else {
                    return UITableViewCell()
                }

                let message = messages[indexPath.row]

                cell.titleLabel.text = message.title

                var preview = message.content.replacingOccurrences(of: "\n", with: " ")
                if preview.count > 90 {
                    preview = "\(String(preview.prefix(90)))..."
                }

                cell.previewLabel.text = preview

                cell.accessoryType = messagesAreEditable ? .disclosureIndicator : (message.identifier == selectedMessageId ? .checkmark : .none)

                return cell
            }
        }

        guard let addNewMessageCell = tableView.dequeueReusableCell(withIdentifier: "AddMessageTemplateTableViewCell", for: indexPath) as? AddMessageTemplateTableViewCell else {
            return UITableViewCell()
        }

        addNewMessageCell.titleLabel.text = "app.views.messagesList.button.addNew".localize()

        return addNewMessageCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 {
            addNewMessage()
            return
        }

        guard let selectedMessage = messages[safe: indexPath.row] else {
            delegate?.messageChanged(message: nil)
            navigationController?.popViewController(animated: true)
            return
        }

        guard !messagesAreEditable else {
            openDetailsFor(message: selectedMessage)
            return
        }

        selectedMessageId = selectedMessage.identifier
        messagesTableView.reloadData()

        delegate?.messageChanged(message: selectedMessage)
        navigationController?.popViewController(animated: true)
    }

    func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0, !messagesAreEditable {
            return "app.views.messagesList.tableFooterInfo".localize()
        }
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if messagesAreEditable, section == 0, messages.count == 0 {
            return 0.01
        }

        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if messagesAreEditable, section == 0, messages.count == 0 {
            return 15
        }

        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return messagesAreEditable
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteMessage(indexPath: indexPath)
        }
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension MessagesListViewController: EditMessageDelegate {
    func messageChanged(message _: MessagesViewModel?) {
        reloadMessages()
        messagesTableView.reloadData()
    }

    func messageChangeCanceled() {}
}

protocol EditMessageDelegate {
    func messageChanged(message: MessagesViewModel?)
    func messageChangeCanceled()
}
