//
//  Reminder.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class Reminder: NSObject, Codable {

    @DocumentID var reminderId: String?
    var date: Date?
    var alert: String?
    
}
