//
//  FirebaseController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var listList: [List]
    var calendarList: [Calendar]
    var conversationList: [Conversation]
    var paymentList: [Payment]
    
    
    
    let DEFAULT_USER_EMAIL = "crowefifi@gmail.com"
    var defaultUser = User()
    
    var authController: Auth
    var database: Firestore
    var listRef: CollectionReference?
    var userRef: CollectionReference?
    var messageRef: CollectionReference?
    var calendarRef: CollectionReference?
    var conversationRef: CollectionReference?
    var homeRef: CollectionReference?
    var itemRef: CollectionReference?
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        listList = [List]()
        calendarList = [Calendar]()
        conversationList = [Conversation]()
        paymentList = [Payment]()
        super.init()
        
        /*authController.signIn(withEmail: email, password: password) {
            [weak self] authResult, error in
            guard let strongSelf = self else {
                return
        
            }
          
        }*/
        
        self.setupListListener()
        //self.setupUserListener()
    }
    
    
    
    func addListener(listener: DatabaseListener){
        // Add listener as delegate
        listeners.addDelegate(listener)
        
        // If the listener type is meal, or all...
        if listener.listenerType == .list || listener.listenerType == .all {
            
            // Call onMealChange method with change type and list of meals
            listener.onListChange(change: .update, list: listList)
        }
        
        // If the listener type is ingredient, or all...
        else if listener.listenerType == .calendar || listener.listenerType == .all {
            
            // Call onIngredientChange method with change type and list of ingredients
            listener.onCalendarChange(change: .update, calendar: calendarList)
        }
        
        // If the listener type is ingredient, or all...
        else if listener.listenerType == .conversation || listener.listenerType == .all {
            
            // Call onIngredientChange method with change type and list of ingredients
            listener.onConversationChange(change: .update, conversation: conversationList)
        }
    }
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    
    
    func addUser(fName: String, lName: String, email: String, lists: [List], calendars: [Calendar], conversations: [Conversation], payments: [Payment]) -> User {
        
        let user = User()
        user.fName = fName
        user.lName = lName
        user.email = email
        user.lists = lists
        user.conversations = conversations
        user.calendars = calendars
        user.payments = payments
        
        do {
            if let userRef = try userRef?.addDocument(from: user) {
                user.userId = userRef.documentID
            }
        } catch {
            print("Failed to serialize user")
        }
        return user
    }
    
    func addList(listName: String) -> List{
        let list = List()
        list.listName = listName
        let date = Date()
        list.dateLastModified = date
        list.dateCreated = date
        
        do {
            if let listRef = try listRef?.addDocument(from: list) {
                list.listId = listRef.documentID
            }
        } catch {
            print("Failed to serialize list")
        }
        return list
    }
    
    func addListItem(itemName: String) -> ListItem{
        let item = ListItem()
        item.itemName = itemName
        item.completed = false
        item.reminders = []
        
        
        do {
            if let itemRef = try itemRef?.addDocument(from: item) {
                item.listItemId = itemRef.documentID
            }
        } catch {
            print("Failed to serialize list item")
        }
        return item
    }
    
    func addHome(homeName: String) -> Home{
        
        let home = Home()
        home.houseName = homeName
        home.users = []
        
        
        do {
            if let homeRef = try homeRef?.addDocument(from: home) {
                home.homeId = homeRef.documentID
            }
        } catch {
            print("Failed to serialize home")
        }
        return home
        
    }
    func addConversation(users: [User], conversationName: String?) -> Conversation{
        let conversation = Conversation()
        conversation.users = users
        conversation.conversationName = conversationName
        conversation.messages = []
        let date = Date()
        conversation.dateLastModified = date
        do {
            if let conversationRef = try conversationRef?.addDocument(from: conversation) {
                conversation.conversationId = conversationRef.documentID
            }
        } catch {
            print("Failed to serialize list")
        }
        return conversation
        
        
    }
    
    func addCalendar(calendarName: String, colour: String) -> Calendar{
        let calendar = Calendar()
        calendar.calendarName = calendarName
        calendar.colour = colour
        calendar.calendarEvents = []
        
        do {
            if let calendarRef = try calendarRef?.addDocument(from: calendar) {
                calendar.calendarId = calendarRef.documentID
            }
        } catch {
            print("Failed to serialize list")
        }
        return calendar
        
        
    }
    
    func addMessage(text: String, conversation: Conversation, sender: User) -> Message{
        let message = Message()
        message.text = text
        message.conversation = conversation
        message.sender = sender
        message.dateSent = Date()
        
        do {
            if let messageRef = try messageRef?.addDocument(from: message) {
                message.messageId = messageRef.documentID
            }
        } catch {
            print("Failed to serialize list")
        }
        return message
        
        
    }
    
    func addListToUser(user: User, list: List) -> Bool{
        
        guard let listID = list.listId, let userID = user.userId, !user.lists.contains(list)
        else {
            return false
        }
        
        if let newListRef = listRef?.document(listID) { userRef?.document(userID).updateData(
                ["lists" : FieldValue.arrayUnion([newListRef])]
            )
        }
        
        return true
        
    }
    
    func addConversationToUser(user: User, conversation: Conversation) -> Bool{
        
        guard let conversationID = conversation.conversationId, let userID = user.userId, !user.conversations.contains(conversation)
        else {
            return false
        }
        
        if let newConversationRef = conversationRef?.document(conversationID) { userRef?.document(userID).updateData(
                ["calendar" : FieldValue.arrayUnion([newConversationRef])]
            )
        }
        
        return true
        
    }
    
    func addMessageToConversation(message: Message, conversation: Conversation) -> Bool{
        
        guard let conversationID = conversation.conversationId, let messageID = message.messageId, !conversation.messages.contains(message)
        else {
            return false
        }
        
        if let newMessageRef = messageRef?.document(messageID) { conversationRef?.document(conversationID).updateData(
                ["messages" : FieldValue.arrayUnion([newMessageRef])]
            )
        }
        
        return true
        
    }
    
    func deleteList(list: List){
        if let listID = list.listId {
            listRef?.document(listID).delete()
        }
    }
    func deleteListItem(item: ListItem){
        if let itemID = item.listItemId {
            itemRef?.document(itemID).delete()
        }
    }
    func deleteHome(home: Home){
        if let homeID = home.homeId {
            homeRef?.document(homeID).delete()
        }
    }
    func deleteConversation(conversation: Conversation){
        if let conversationID = conversation.conversationId {
            conversationRef?.document(conversationID).delete()
        }
    }
    func deleteCalendar(calendar: Calendar){
        if let calendarID = calendar.calendarId {
            calendarRef?.document(calendarID).delete()
        }
    }
    
    
    func removeUserFromHome(home: Home, user: User){
        if home.users.contains(user), let homeID = home.homeId, let userID = user.userId {
            if let removedUserRef = userRef?.document(userID) { homeRef?.document(homeID).updateData(
                    ["users": FieldValue.arrayRemove([removedUserRef])]
                )
            }
        }
    }
    
    func removeItemFromList(item: ListItem, list: List){
        if list.listItems.contains(item), let itemID = item.listItemId, let listID = list.listId {
            if let removedItemRef = itemRef?.document(itemID) { listRef?.document(listID).updateData(
                    ["listItems": FieldValue.arrayRemove([removedItemRef])]
                )
            }
        }
    }
    
    func removeListFromUser(list: List, user: User){
        if user.lists.contains(list), let listID = list.listId, let userID = user.userId {
            if let removedListRef = listRef?.document(listID) { userRef?.document(userID).updateData(
                    ["lists": FieldValue.arrayRemove([removedListRef])]
                )
            }
        }
    }
    
    
    func getListIndexByID(_ id: String) -> Int?{
        if let list = getListByID(id) {
            return listList.firstIndex(of: list)
        }
        return nil
    }
    func getListByID(_ id: String) -> List?{
        for list in listList {
            if list.listId == id {
                return list
                
            }
        }
        return nil
    }
    
    func getConversationIndexByID(_ id: String) -> Int?{
        if let conversation = getConversationByID(id) {
            return conversationList.firstIndex(of: conversation)
        }
        return nil
    }
    func getConversationByID(_ id: String) -> Conversation?{
        for conversation in conversationList {
            if conversation.conversationId == id {
                return conversation
                
            }
        }
        return nil
    }
    
    
    func getCalendarIndexByID(_ id: String) -> Int?{
        if let calendar = getCalendarByID(id) {
            return calendarList.firstIndex(of: calendar)
        }
        return nil
    }
    func getCalendarByID(_ id: String) -> Calendar?{
        for calendar in calendarList {
            if calendar.calendarId == id {
                return calendar
                
            }
        }
        return nil
    }
    
    func getPaymentIndexByID(_ id: String) -> Int?{
        if let payment = getPaymentByID(id) {
            return paymentList.firstIndex(of: payment)
        }
        return nil
    }
    func getPaymentByID(_ id: String) -> Payment?{
        for payment in paymentList {
            if payment.paymentId == id {
                return payment
                
            }
        }
        return nil
    }
    
    
    func setupListListener(){
        listRef = database.collection("lists")
        
        listRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseListsSnapshot(snapshot: querySnapshot)
            if self.userRef == nil {
                self.setupUserListener()
            }
        }
    }
    func setupUserListener(){
        userRef = database.collection("users")
        userRef?.whereField("email", isEqualTo: DEFAULT_USER_EMAIL).addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first
            
            else {
                print("Error fetching teams:")
                return
            }
            self.parseUserSnapshot(snapshot: userSnapshot)
        }
    }
    func parseListsSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach {
            (change) in
            var parsedList: List?
            do {
                parsedList = try change.document.data(as: List.self)
            } catch {
                print("Unable to decode list.")
                return
            }
            guard let list = parsedList else {
                print("Document doesn't exist")
                return;
            }
            if change.type == .added {
                listList.insert(list, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                listList[Int(change.oldIndex)] = list
            }
            else if change.type == .removed {
                listList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.list || listener.listenerType == ListenerType.all {
                        listener.onListChange(change: .update, list: listList)
                }
            }
        }
        
    }
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot){
        defaultUser = User()
        defaultUser.fName = snapshot.data()["fName"] as? String
        defaultUser.lName = snapshot.data()["lName"] as? String
        defaultUser.email = snapshot.data()["email"] as? String
        defaultUser.userId = snapshot.documentID
        
        if let listReferences = snapshot.data()["lists"] as? [DocumentReference] {
            for reference in listReferences {
                if let list = getListByID(reference.documentID) {
                    defaultUser.lists.append(list)
                }
            }
        }
        
        if let conversationReferences = snapshot.data()["conversations"] as? [DocumentReference] {
            for reference in conversationReferences {
                if let conversation = getConversationByID(reference.documentID) {
                    defaultUser.conversations.append(conversation)
                }
            }
        }
        
        if let paymentsReferences = snapshot.data()["payments"] as? [DocumentReference] {
            for reference in paymentsReferences {
                if let payment = getPaymentByID(reference.documentID) {
                    defaultUser.payments.append(payment)
                }
            }
        }
        
        if let calendarsReferences = snapshot.data()["calendars"] as? [DocumentReference] {
            for reference in calendarsReferences {
                if let calendar = getCalendarByID(reference.documentID) {
                    defaultUser.calendars.append(calendar)
                }
            }
        }
                
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
                    listener.onUserChange(change: .update,
                                          user: [defaultUser])
            }
        }
    }
    
    
    
    
    

}
