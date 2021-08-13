//
//  AppDelegate.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 5/5/21.
//

import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var databaseController: DatabaseProtocol?
    
    var window: UIWindow?
    var notificationsEnabled = false
    
    let IDENTIFIER = "edu.monash.fit3178.HOUSEM8"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set firebase controller
        databaseController = FirebaseController()
        
        // Ask user if app can show notifications, setup notification delegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
        { (granted, error) in
            self.notificationsEnabled = granted
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    
     // Handle how notification is shown
     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
             print("Notification received")
             completionHandler([.banner])
     }

    // Function creates a new Notification and displays it
    func newNotification(title: String, subtitle: String, body: String) {
        
        guard self.notificationsEnabled else {
            print("Notifications disabled")
            return
        }
        
        // Create a notification content object
        let notificationContent = UNMutableNotificationContent()
        
        // Create its details
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body
        
        // Set a trigger for request
        let timeInterval = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: IDENTIFIER,
         content: notificationContent, trigger: timeInterval)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }



}

