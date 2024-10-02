//
//  ContactGroupViewModel.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 02.12.20.
//

import Foundation

class MessagesViewModel {
    var identifier: String
    var title: String
    var content: String
    var isDefault: Bool
    var localizable: Bool

    init(message: Message) {
        identifier = message.identifier ?? ""
        isDefault = message.isDefault
        localizable = message.localizable
        
        let title = message.title ?? ""
        let content = message.content ?? ""
        self.title = message.localizable ? title.localize() : title
        self.content = message.localizable ? content.localize() : content

        
    }
    
    
    init(identifier: String, title: String, content: String) {
        self.identifier = identifier
        self.content = content
        self.title = title
        self.isDefault = false
        self.localizable = false
    }
}
