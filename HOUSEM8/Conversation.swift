//
//  Conversation.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class Conversation: NSObject, Codable {
    
    @DocumentID var conversationId: String?
    var conversationName: String?
    var messages: [Message] = []
    var users: [User] = []
    var dateLastModified: Date?

}
