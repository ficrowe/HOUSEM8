//
//  ListItem.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class ListItem: NSObject, Codable {
    
    @DocumentID var listItemId: String?
    var itemName: String?
    var completed: Bool?
    var reminders: [Reminder] = []
    
}
