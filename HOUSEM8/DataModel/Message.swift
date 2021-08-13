//
//  Message.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift
import MessageKit

struct MessageStruct {
    var message: Message
    var senderID: String
    var senderName: String
}

extension MessageStruct {
    init?(senderID: String, senderName: String) {
        self.init(senderID: senderID, senderName: senderName)
    }
}

extension MessageStruct: MessageType {
    var sender: SenderType {
        return UserStruct(senderId: self.senderID, displayName: self.senderName)
    }
    
    var messageId: String {
        return message.messageId!
    }
    
    var sentDate: Date {
        return message.dateSent!
    }
    
    var kind: MessageKind {
        return .text(message.content!)
    }
    
    
}


class Message: NSObject, Codable {
    
    @DocumentID var messageId: String?
    var content: String?
    var dateSent: Date?
    var conversation: Conversation?
    var sender: User?

}
