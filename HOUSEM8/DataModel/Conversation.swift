//
//  Conversation.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

/*struct ConversationStruct {
    var conversation: Conversation
    
    
}*/


class Conversation: NSObject, Codable {
    
    @DocumentID var conversationId: String?
    var conversationName: String?
    var messages: [Message] = []
    var users: [User] = []
    var dateLastModified: Date?
    
    enum CodingKeys: String, CodingKey {
        case conversationId
        case conversationName
        case messages
        case users
        case dateLastModified
    }

    
    func addMessage(message: Message) {
        self.messages.append(message)
    }
    
    func addUser(user: User) {
        self.users.append(user)
    }
    

}
