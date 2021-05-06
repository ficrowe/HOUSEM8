//
//  Payment.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class Payment: NSObject, Codable {
    
    @DocumentID var paymentId: String?
    var paymentDesc: String?
    var amoount: Float?
    var dueDate: Date?
    var paidDate: Date?
    var recipient: String?
    var reminders: [Reminder] = []
}
