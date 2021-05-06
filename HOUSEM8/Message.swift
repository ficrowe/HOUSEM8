//
//  Message.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class Message: NSObject, Codable {
    
    @DocumentID var messageId: String?
    var text: String?
    var dateSent: Date?
    var conversation: Conversation?
    var sender: User?

}
