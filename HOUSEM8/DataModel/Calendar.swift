//
//  Calendar.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class Calendar: NSObject, Codable {
    
    @DocumentID var calendarId: String?
    var calendarName: String?
    var colour: String?
    
    var calendarEvents: [CalendarEvent] = []
    

}
