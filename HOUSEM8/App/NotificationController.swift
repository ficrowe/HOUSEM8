//
//  NotificationController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 19/6/21.
//

import Foundation
import UserNotifications

let IDENTIFIER = "edu.monash.git3178.HOUSEM8"
func newNotification(title: String, subtitle: String, body: String) {
    
    guard appDelegate.notificationsEnabled else {
        print("Notifications disabled")
        return
    }
    
    // Create a notification content object
    let notificationContent = UNMutableNotificationContent()
    
    // Create its details
    notificationContent.title = title
    notificationContent.subtitle = subtitle
    notificationContent.body = body
    
    // Set a delayed trigger for the notification of 10 seconds
    let timeInterval = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
    // Create our request
    // Provide a unique identifier (declared above), our content and the trigger
    let request = UNNotificationRequest(identifier: IDENTIFIER,
     content: notificationContent, trigger: timeInterval)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

