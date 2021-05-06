//
//  DatabaseProtocol.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import Foundation

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
}

// Protocols for the database
protocol DatabaseProtocol: AnyObject {
    
    
    // Protocols for adding and removing listeners
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    // Protocols for adding and removing a list
    func addList(listName: String) -> List
    func deleteList(list: List)
    
    // Protocols for adding and removing a list item
    func addListItem(itemName: String) -> ListItem
    func deleteListItem(item: ListItem)
    
    // Protocols for adding and removing a home
    func addHome(homeName: String) -> Home
    func deleteHome(home: Home)
    
    // Protocols for adding and removing a conversation
    func addConversation(users: [User], conversationName: String?) -> Conversation
    func deleteConversation(conversation: Conversation)
    
    func addCalendar(calendarName: String, colour: String) -> Calendar
    func deleteCalendar(calendar: Calendar)
    
    func addMessage(text: String, conversation: Conversation, sender: User) -> Message
    
    func addListToUser(user: User, list: List) -> Bool
    func addConversationToUser(user: User, conversation: Conversation) -> Bool
    func addMessageToConversation(message: Message, conversation: Conversation) -> Bool
    
    func removeUserFromHome(home: Home, user: User)
    func removeListFromUser(list: List, user: User)
    func removeItemFromList(item: ListItem, list: List)
    
    
    // Protocols for saving the parent and child context
    //func saveContext()
    
    
    // Protocol for adding a user
    func addUser(fName: String, lName: String, email: String, lists: [List], calendars: [Calendar], conversations: [Conversation], payments: [Payment]) -> User
    
    
}
