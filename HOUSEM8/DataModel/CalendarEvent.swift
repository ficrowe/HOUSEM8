//
//  CalendarEvent.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class CalendarEvent: NSObject, Codable {

    @DocumentID var eventId: String?
    var eventName: String?
    var eventDesc: String?
    var location: String?
    var date: Date?
    var invitees: [String] = []
    var reminders: [Reminder] = []
}
