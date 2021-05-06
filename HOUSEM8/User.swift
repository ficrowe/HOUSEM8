//
//  User.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class User: NSObject, Codable {
    
    @DocumentID var userId: String?
    var fName: String?
    var lName: String?
    var email: String?
    var lists: [List] = []
    var calendars: [Calendar] = []
    var conversations: [Conversation] = []
    var payments: [Payment] = []

}
