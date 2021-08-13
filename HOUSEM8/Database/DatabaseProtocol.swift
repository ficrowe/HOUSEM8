//
//  DatabaseProtocol.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import Foundation
import SwiftUI
import Firebase

// Enum - defines type of database change
enum DatabaseChange {
    case add
    case remove
    case update
}

// Enum - defines type of listener
enum ListenerType {
    case list
    case calendar
    case calendarEvent
    case conversation
    case user
    case home
    case payment
    case reminder
    case all
}

// Database Listener protocol
protocol DatabaseListener: AnyObject {
    
    // Define listener type
    var listenerType: ListenerType {get set}
    
    // Method protocols for meal and ingredient change
    func onListChange(change: DatabaseChange, list: [List])
    func onCalendarChange(change: DatabaseChange, calendar: [Calendar])
    func onCalendarEventChange(change: DatabaseChange, calendarEvent: [CalendarEvent])
    func onUserChange(change: DatabaseChange, user: [User])
    func onConversationChange(change: DatabaseChange, conversation: [Conversation])
    func onPaymentChange(change: DatabaseChange, payment: [Payment])
    func onReminderChange(change: DatabaseChange, reminder: [Reminder])
    func onHomeChange(change: DatabaseChange, home: [Home])
}

// Protocols for the database
protocol DatabaseProtocol: AnyObject {
    
    var user: User? { get set }
    var currentHome: Home? { get set }
    
    
    // Protocols for adding and removing listeners
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // Protocols for adding and removing a list
    func addList(listName: String, listItems: [ListItem]) -> List
    func deleteList(list: List)
    
    // Protocols for adding and removing a list item
    func addListItem(itemName: String) -> ListItem
    func deleteListItem(item: ListItem)
    
    // Protocols for adding and removing a home
    func addHome(homeAddress: String, homeName: String) -> Home
    func deleteHome(home: Home)
    
    // Protocols for adding and removing a conversation
    func addConversation(users: [User], conversationName: String) -> Conversation
    func deleteConversation(conversation: Conversation)
    
    // Protocols for adding and removing a calendar
    func addCalendar(calendarName: String, colour: String) -> Calendar
    func deleteCalendar(calendar: Calendar)
    
    // Protocols for adding a message
    func addMessage(text: String, conversation: Conversation, sender: User) -> Message
    
    // Protocols for adding and removing a list, conversation or home to user
    func addListToUser(user: User, list: List) -> Bool
    func removeListFromUser(list: List, user: User)
    func addConversationToUser(user: User, conversation: Conversation) -> Bool
    func removeConversationFromUser(conversation: Conversation, user: User)
    func addHomeToUser(user: User, home: Home) -> Bool
    
    // Protocol for adding a message to a conversation
    func addMessageToConversation(message: Message, conversation: Conversation) -> Bool
    
    // Protocols for adding and removing a user to a home
    func addUserToHome(user: User, home: Home) -> Bool
    func removeUserFromHome(home: Home, user: User)
    
    // Protocol for removing an item from a list
    func removeItemFromList(item: ListItem, list: List)
    
    // Protocols for dealing with images
    func uploadImage(data: Data)
    func saveImageData(filename: String, imageData: Data)
    func loadImageData(filename: String) -> UIImage?
    func parseImageSnapshot(snapshot: QuerySnapshot) -> UIImage
    
    // Protocol for adding a user
    func addUser(fName: String, lName: String, email: String, lists: [List], calendars: [Calendar], conversations: [Conversation], payments: [Payment], homes: [Home]) -> User
    
    func addInvitation(inviter: User, home: Home) -> Invitation
    
    // Protocol for updating a user
    func updateUser(user: User, fName: String, lName: String, email: String, profilePicId: String)
    
    // Protocol for logging in and registering a user
    func login(email: String, password: String, completion: @escaping (User?) -> Void)
    func registerUser(fName: String, lName: String, email: String, password: String, completion: @escaping (User) -> Void)
    
    func addAuthListener(completion: @escaping (Bool) -> Void)
    func removeAuthListener()
    func signOut()
    
    func getUserByEmail(email: String, completion: @escaping (User?) -> Void)
    func getConversationByID(id: String, completion: @escaping (Conversation) -> Void)
    
    
}
