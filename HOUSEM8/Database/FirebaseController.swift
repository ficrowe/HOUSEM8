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
  
    // Defining variables
    var listeners = MulticastDelegate<DatabaseListener>()
    var listList: [List]
    var listItemsList: [ListItem]
    var calendarList: [Calendar]
    var conversationList: [Conversation]
    var paymentList: [Payment]
    var homeList: [Home]
    var reminderList: [Reminder]
    var messageList: [Message]
    var userList: [User]
    var invitationList: [Invitation]
    var imageList: [UIImage]
    var imagePathList: [String]
    var user: User?
    var currentHome: Home?
    var snapshotListener: ListenerRegistration?
    
    // Firebase variables
    var authController: Auth
    var database: Firestore
    var listRef: CollectionReference?
    var userRef: CollectionReference?
    var messageRef: CollectionReference?
    var calendarRef: CollectionReference?
    var conversationRef: CollectionReference?
    var homeRef: CollectionReference?
    var itemRef: CollectionReference?
    var reminderRef: CollectionReference?
    var invitationRef: CollectionReference?
    
    var storageReference: StorageReference
    var storage: Storage
    
    var authHandle: AuthStateDidChangeListenerHandle?
    
    override init(){
        
        // Initialise all non-optional variables, and firebase variables
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        listList = [List]()
        calendarList = [Calendar]()
        conversationList = [Conversation]()
        paymentList = [Payment]()
        homeList = [Home]()
        listItemsList = [ListItem]()
        reminderList = [Reminder]()
        messageList = [Message]()
        userList = [User]()
        invitationList = [Invitation]()
        imageList = [UIImage]()
        imagePathList = [String]()
        user = nil
        storageReference = Storage.storage().reference()
        storage = Storage.storage()
        
        super.init()
        
        // Start listeners
        setupImageListener()
        setupUserListener()
    }
   
    
    /**
     Function - addAuthListener
     Description - Determines if user is logged in already, and if so, sets user
     */
    func addAuthListener(completion: @escaping (Bool) -> Void) {
        
        authHandle = authController.addStateDidChangeListener() {
         (auth, user) in
            guard user != nil
            else { completion(false)
                return }
            
            self.getUserByEmail(email: user!.email!, completion: {
                user in
                self.user = user
                completion(true)
            })
        }
    }
    
    func removeAuthListener(){
        guard let authHandle = authHandle else { return }
        authController.removeStateDidChangeListener(authHandle)
    }
    
    /**
     Function - getUserByEmail
     Description - Given an email, this function retrieves the information associated with that email and creates a user object
     */
    func getUserByEmail(email: String, completion: @escaping (User?) -> Void) {
        
        for user in userList {
            if user.email == email {
                completion(user)
            }
        }
        
        userRef = database.collection("users")
        
        userRef?.whereField("email", isEqualTo: email)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(nil)
                } else {
                    for document in querySnapshot!.documents {
                     
                        let userData = document.data()
                        let user = User()
                        user.userId = String(document.documentID)
                        user.fName = userData["fName"] as? String
                        user.lName = userData["lName"] as? String
                        user.email = userData["email"] as? String
                        user.profilePicId = userData["profilePicId"] as? String
                        
                        if let listReferences = userData["lists"] as? [DocumentReference] {
                            for ref in listReferences {
                                self.getListByID(ref.documentID, completion: { list in
                                    user.addList(list: list)
                                })
                            }
                        }
                        if let conversationReferences = userData["conversations"] as? [DocumentReference] {
                            for ref in conversationReferences {
                                self.getConversationByID(id: ref.documentID, completion: { conversation in
                                    user.addConversation(conversation: conversation)
                                })
                            }
                        }
                        if let calendarReferences = userData["calendars"] as? [DocumentReference] {
                            for ref in calendarReferences {
                                if let calendar = self.getCalendarByID(ref.documentID) {
                                    user.addCalendar(calendar: calendar)
                                }
                            }
                        }
                        if let homeReferences = userData["homes"] as? [DocumentReference] {
                            for ref in homeReferences {
                                self.getHomeByID(ref.documentID, completion: { home in
                                    user.addHome(home: home)
                                
                                    if user.homes.count > 0 {
                                        self.currentHome = user.homes[0]
                                    }
                                })
                            }
                        }
                        self.listeners.invoke { (listener) in
                            if listener.listenerType == ListenerType.all {
                                listener.onListChange(change: .update, list: user.lists)
                                listener.onCalendarChange(change: .update, calendar: user.calendars)
                                listener.onConversationChange(change: .update, conversation: user.conversations)
                            }
                        }
                        self.userList.append(user)
                        completion(user)
                    }
                }
            }
    }
   
    /**
     Function - login
     Description - Function logs in a user with email and password, if successful, it returns user
     */
    func login(email: String, password: String, completion: @escaping (User?) -> Void) {
            
        authController.signIn(withEmail: email, password: password) { (authResult, error) in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            if let firsebaseUser = authResult?.user {
                self.getUserByEmail(email: firsebaseUser.email!, completion: {
                    user in
                    if let user = user {
                        completion(user)
                    }
                })
            }
        }
    }
    
    /**
     Function - registerUser
     Description - This function creates a user given  their initial details
     */
    func registerUser(fName: String, lName: String, email: String, password: String, completion: @escaping (User) -> Void) {
        
        authController.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let user = user {
                /*let newUser = User()
                newUser.email = user.user.email
                self.user = newUser*/
                //let newHome = self.addHome(homeAddress: homeAddress, homeName: homeAddress)
                self.user = self.addUser(fName: fName, lName: lName, email: email, lists: [], calendars: [], conversations: [], payments: [], homes: [])
                completion(self.user!)
            }
        }
    }
    
    /**
     Function - signOut
     Description - Function signs user out
     */
    func signOut(){
        do {
            try authController.signOut()
        } catch {
            print("Log out error: \(error.localizedDescription)")
        }
    }
    
    /**
     Function - addListener
     Description - Given a listener, it will invoke listener methods to update data
     */
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
        
        // If the listener type is ingredient, or all...
        else if listener.listenerType == .home || listener.listenerType == .all {
            
            // Call onIngredientChange method with change type and list of ingredients
            listener.onHomeChange(change: .update, home: homeList)
        }
    }
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    
    /**
     Function - addUser
     Description - this function adds a user to the firestore
     Parameters -
                fName (String) - the user's first name
                lName (String) - the user's last name
                email (String) - the user's email
                lists ([List]) - a list of the user's lists
                calendars ([Calendar]) - a list of the user's calendars
                conversations ([Conversation]) - a list of the user's conversations
                payments ([Payment]) - a list of the user's payments
     Return - A User object that was just added to the firestore
     */
    func addUser(fName: String, lName: String, email: String, lists: [List], calendars: [Calendar], conversations: [Conversation], payments: [Payment], homes: [Home]) -> User {
        
        // Creating a user object and setting its attributes
        let user = User()
        user.fName = fName
        user.lName = lName
        user.email = email
        user.lists = []
        user.conversations = []
        user.calendars = []
        user.payments = []
        user.homes = []
        
        // Defining collection reference
        userRef = database.collection("users")
        
        // Try to add the user to firestore
        do {
            if let userRef = try userRef?.addDocument(from: user) {
                
                // Set user object's ID
                user.userId = userRef.documentID
                
                // For each conversation
                for conversation in conversations {
                    self.addConversationToUser(user: user, conversation: conversation)
                    
                }
                
                for list in lists {
                    self.addListToUser(user: user, list: list)
                }
                
                // For each home
                for home in homes {
                    self.addHomeToUser(user: user, home: home)
                    self.addUserToHome(user: user, home: home)
                    
                }
                
            }
        } catch {
            print("Failed to serialize user")
        }
        
        return user
    }
    
    /**
     Function - updateUser
     Description - Function updates user information in firestore and locally
     Parameter: user (User) - the user being updated
     Parameter: fName (String) - the new first name
     Parameter: lName (String) - the new last name
     Parameter: email (String) - the new email
     Returns: None
     */
    func updateUser(user: User, fName: String, lName: String, email: String, profilePicId: String) {
        
        userRef = database.collection("users")
        
        userRef?.document(user.userId!).updateData(
                ["fName" : fName,
                "lName" : lName,
                "email" : email,
                "profilePicId" : profilePicId]
            )
        user.fName = fName
        user.lName = lName
        user.email = email
        user.profilePicId = profilePicId
    }
    
    /**
     Function - addList
     Description - this function adds a list to the firestore
     Parameters -
                listName (String) - the name of the list
                listItems ([ListItem]) - the list's list items
     Return - A List object that was just added to the firestore
     */
    func addList(listName: String, listItems: [ListItem]) -> List {
        
        // Creating a list object and setting its attributes
        let list = List()
        list.listName = listName
        let date = Date()
        list.dateLastModified = date
        list.dateCreated = date
        list.listItems = listItems
        
        // Defining collection reference
        listRef = database.collection("lists")
        
        // Try to add the list to firestore
        do {
            if let listRef = try listRef?.addDocument(from: list) {
                list.listId = listRef.documentID
            }
        } catch {
            print("Failed to serialize list")
        }
        return list
    }
    
    /**
     Function - addListItem
     Description - this function adds a list item to the firestore
     Parameters -
                itemName (String) - the name of the item
     Return - A ListItem object that was just added to the firestore
     */
    func addListItem(itemName: String) -> ListItem {
        
        // Creating a list item object and setting its attributes
        let item = ListItem()
        item.itemName = itemName
        item.completed = false
        item.reminders = []
        
        // Defining collection reference
        itemRef = database.collection("listItems")
        
        // Try to add the list item to firestore
        do {
            if let itemRef = try itemRef?.addDocument(from: item) {
                item.listItemId = itemRef.documentID
            }
        } catch {
            print("Failed to serialize list item")
        }
        return item
    }
    
    /**
     Function - addHome
     Description - this function adds a home to the firestore
     Parameters -
                homeName (String) - the name of the home
     Return - A Home object that was just added to the firestore
     */
    func addHome(homeAddress: String, homeName: String) -> Home {
        
        // Creating a home object and setting its attributes
        let home = Home()
        home.homeAddress = homeAddress
        home.homeName = homeName
        home.users = []
        
        // Defining collection reference
        homeRef = database.collection("homes")
        
        // Try to add the home to firestore
        do {
            if let homeRef = try homeRef?.addDocument(from: home) {
                home.homeId = homeRef.documentID
            }
        } catch {
            print("Failed to serialize home")
        }
        return home
        
    }
    
    /**
     Function - addConversation
     Description - this function adds a conversation to the firestore
     Parameters -
                conversationName (String) - the name of the conversation
                users ([User]) - the users in the conversation
     Return - A Conversation object that was just added to the firestore
     */
    func addConversation(users: [User], conversationName: String) -> Conversation {
        
        // Creating a conversation object and setting its attributes
        let conversation = Conversation()
        conversation.conversationName = conversationName
        conversation.dateLastModified = Date()
        
        // Defining collection reference
        conversationRef = database.collection("conversations")
       
        // Try to add the conversation to firestore
        do {
            if let conversationRef = try conversationRef?.addDocument(from: conversation) {
                conversation.conversationId = conversationRef.documentID
                self.addUsersToConversation(conversation: conversation, users: users)
            }
        } catch {
            print("Failed to serialize list")
        }
        return conversation
    }
    
    /**
     Function - addCalendar
     Description - this function adds a calendar to the firestore
     Parameters -
                calendarName (String) - the name of the calendar
                colour (String) - the colour code of the calendar
     Return - A Calendar object that was just added to the firestore
     */
    func addCalendar(calendarName: String, colour: String) -> Calendar{
        
        // Create new calendar and set attributes
        let calendar = Calendar()
        calendar.calendarName = calendarName
        calendar.colour = colour
        calendar.calendarEvents = []
        
        // Define collection references
        calendarRef = database.collection("calendars")
        
        // Try to add calendar to firestore
        do {
            if let calendarRef = try calendarRef?.addDocument(from: calendar) {
                calendar.calendarId = calendarRef.documentID
            }
        } catch {
            print("Failed to serialize list")
        }
        return calendar
    }
    
    /**
     Function - addMessage
     Description - this function adds a message to the firestore
     Parameters -
                text (String) - the content of the message
                conversation (Conversation) - the conversation that the message is in
                sender (User) - the user whio sent the message
     Return - A Message object that was just added to the firestore
     */
    func addMessage(text: String, conversation: Conversation, sender: User) -> Message {
        
        // Create new message and set attributes
        let message = Message()
        message.content = text
        message.dateSent = Date()
        
        // Define collection references
        messageRef = database.collection("messages")
        userRef = database.collection("users")
        conversationRef = database.collection("conversations")
        
        // Try to add message to firestore
        do {
            if let messageRef = try messageRef?.addDocument(from: message) {
                message.messageId = messageRef.documentID
                if let newConvoRef = conversationRef?.document(conversation.conversationId!) { messageRef.updateData(["conversation" : newConvoRef])
                    message.conversation = conversation
                }
                if let newUserRef = userRef?.document(sender.userId!) { messageRef.updateData(["sender" : newUserRef])
                    
                    message.sender = sender
                }
            }
        } catch {
            print("Failed to serialize list")
        }
        return message
    }
    
    func addInvitation(inviter: User, home: Home) -> Invitation {
        
        // Create new invitation and set attributes
        let invitation = Invitation()
        invitation.inviter = inviter
        invitation.home = home
        
        // Define collection references
        invitationRef = database.collection("invitations")
        //userRef = database.collection("users")
        //homeRef = database.collection("homes")
        
        // Try to add invitation to firestore
        do {
            if let inviteRef = try messageRef?.addDocument(from: invitation) {
                invitation.invitationId = inviteRef.documentID
            }
        } catch {
            print("Failed to serialize list")
        }
        return invitation
    }
    
    /**
     Function - addListToUser
     Description - this function adds a list to a user and updates on firestore
     Parameters -
                user (User) - the user which the list is being added to
                list (List) - the list which is being added to the user
     Return - A Boolean representing the outcome of adding the list to user (true = list added, false = list not added)
     */
    func addListToUser(user: User, list: List) -> Bool {
        
        // Ensure user does not already have list, return false if user has list
        guard let listID = list.listId, let userID = user.userId, !user.lists.contains(list)
        else {
            return false
        }
        
        // Otherwise, attempt to add list to user
        if let newListRef = listRef?.document(listID) { userRef?.document(userID).updateData(
                ["lists" : FieldValue.arrayUnion([newListRef])]
            )
        }
        
        user.addList(list: list)
        
        // Return true on success
        return true
        
    }
    
    /**
     Function - addConversationToUser
     Description - this function adds a conversation to a user and updates on firestore
     Parameters -
                user (User) - the user which the conversation is being added to
                conversation (Conversation) - the conversation that is being added to the user
     Return - A Boolean representing the outcome of adding the conversation to user (true = conversation added, false = conversation not added)
     */
    func addConversationToUser(user: User, conversation: Conversation) -> Bool {
        
        // Ensure user does not already have conversation, return false if user has conversation
        guard let conversationID = conversation.conversationId, let userID = user.userId, !user.conversations.contains(conversation)
        else {
            return false
        }
        
        // Otherwise, attempt to add conversation to user
        if let newConversationRef = conversationRef?.document(conversationID) { userRef?.document(userID).updateData(
                ["conversations" : FieldValue.arrayUnion([newConversationRef])]
            )
        }
        user.addConversation(conversation: conversation)
        
        // Return true on success
        return true
        
    }
    
    /**
     Function - addUsersToConversation
     Description - this function adds a user to a conversation and updates on firestore
     Parameters -
                conversation (Conversation) - the conversation that is adding users
                users ([Use]) - the users which are being added to the conversation
     Return - A Boolean representing the outcome of adding the users to the ocnversation (true = users added, false = users not added)
     */
    func addUsersToConversation(conversation: Conversation, users: [User]) -> Bool{
        
        // For each user
        for user in users {
            
            // Attempt to add conversation to user
            if let newUserRef = userRef?.document(user.userId!) { conversationRef?.document(conversation.conversationId!).updateData(
                    ["users" : FieldValue.arrayUnion([newUserRef])]
                )
            }
            conversation.addUser(user: user)
        }
        // Return true on success
        return true
        
    }
    
    /**
     Function - addMessageToConversation
     Description - this function adds a message to a conversation and updates on firestore
     Parameters -
                message (Message) - the user which the conversation is being added to
                conversation (Conversation) - the conversation that is being added to the user
     Returns:   A Boolean representing the outcome of adding the message to the conversation (true = message added, false = message not added)
     */
    func addMessageToConversation(message: Message, conversation: Conversation) -> Bool{
        
        // Ensure conversation does not already have the message, return false if conversation has message
        guard let conversationID = conversation.conversationId, let messageID = message.messageId, !conversation.messages.contains(message)
        else {
            return false
        }
        
        conversationRef = database.collection("conversations")
        messageRef = database.collection("messages")
        
        // Attempt to add message to conversation
        if let newMessageRef = messageRef?.document(messageID) { conversationRef?.document(conversationID).updateData(
                ["messages" : FieldValue.arrayUnion([newMessageRef])]
            )
        }
        conversation.addMessage(message: message)
        
        // Return true on success
        return true
        
    }
    
    /**
     Function - addHomeToUser
     Description - Function adds a home to a user in firebase, then updates the object
     */
    func addHomeToUser(user: User, home: Home) -> Bool  {
        
        // Ensure user does not already have home, return false if user has home
        guard let homeId = home.homeId, let userId = user.userId, !user.homes.contains(home)
        else {
            return false
        }
        
        // Otherwise, attempt to add home to user
        if let newHomeRef = homeRef?.document(homeId) { userRef?.document(userId).updateData(
                ["homes" : FieldValue.arrayUnion([newHomeRef])]
            )
        }
        
        user.addHome(home: home)
        
        // Return true on success
        return true
        
    }
    
    /**
     Function - addUserToHome
     Description - Function adds a user to a home in firebase, then updates the object
     */
    func addUserToHome(user: User, home: Home) -> Bool  {
        
        // Ensure home does not already have user, return false if home has user
        guard let homeId = home.homeId, let userId = user.userId, !home.users.contains(user)
        else {
            return false
        }
        
        // Otherwise, attempt to add user to home
        if let newUserRef = userRef?.document(userId) { homeRef?.document(homeId).updateData(
                ["users" : FieldValue.arrayUnion([newUserRef])]
            )
        }
        
        home.addUser(user: user)
        
        // Return true on success
        return true
        
    }
    
    // These function delete documents from firestore
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
    
    /**
     Function - removeUserFromHome
     Description - Function removes a user from a home in firebase, then updates the object
     */
    func removeUserFromHome(home: Home, user: User){
        if home.users.contains(user), let homeID = home.homeId, let userID = user.userId {
            if let removedUserRef = userRef?.document(userID) { homeRef?.document(homeID).updateData(
                    ["users": FieldValue.arrayRemove([removedUserRef])]
                )
            }
            home.removeUser(user: user)
        }
    }
    
    /**
     Function - removeItemFromList
     Description - Function removes an item from a list, then updates object
     */
    func removeItemFromList(item: ListItem, list: List){
        if list.listItems.contains(item), let itemID = item.listItemId, let listID = list.listId {
            if let removedItemRef = itemRef?.document(itemID) { listRef?.document(listID).updateData(
                    ["listItems": FieldValue.arrayRemove([removedItemRef])]
                )
            }
            list.removeItem(item: item)
        }
    }
    
    /**
     Function - removeListFromUser
     Description - Function removes a list from a user in firebase, then updates the object
     */
    func removeListFromUser(list: List, user: User){
        if user.lists.contains(list), let listID = list.listId, let userID = user.userId {
            if let removedListRef = listRef?.document(listID) { userRef?.document(userID).updateData(
                    ["lists": FieldValue.arrayRemove([removedListRef])]
                )
            }
        }
        user.removeList(list: list)
    }
    
    /**
     Function - removeConversationFromUser
     Description - Function removes a conversation from a user in firebase, then updates the object
     */
    func removeConversationFromUser(conversation: Conversation, user: User) {
        if user.conversations.contains(conversation), let conversationId = conversation.conversationId, let userId = user.userId {
            if let removedConvoRef = conversationRef?.document(conversationId) { userRef?.document(userId).updateData(
                    ["conversations": FieldValue.arrayRemove([removedConvoRef])]
                )
            }
        }
        user.removeConversation(conversation: conversation)
    }
    
    /**
     Function - getListByID
     Description - Given an id, function finds the list in firebase and creates a list obejct
     */
    func getListByID(_ id: String, completion: @escaping (List) -> Void) {
        for list in listList {
            if list.listId == id {
                completion(list)
            }
        }
        
        listRef = database.collection("lists")
        
        listRef?.document(id).getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let listData = document.data() {
                    let list = List()
                    list.dateLastModified = listData["dateLastModified"] as? Date
                    list.dateCreated = listData["dateCreated"] as? Date
                    list.listName = listData["listName"] as? String
                    
                    if let listItemReferences = listData["listItems"] as? [DocumentReference] {
                        
                        for ref in listItemReferences {
                            self.getListItemByID(ref.documentID, completion: { listItem in
                                    list.listItems.append(listItem)
                                })
                        }
                    }
                    self.listList.append(list)
                    completion(list)
                }
            } else {
                print("Document does not exist lkst")
            }
        }
    }
    
    /**
     Function - getConversationByID
     Description - Given an id, function finds the conversation in firebase and creates a conversation obejct
     */
    func getConversationByID(id: String, completion: @escaping (Conversation) -> Void) {
        for conversation in conversationList {
            if conversation.conversationId == id {
                completion(conversation)
            }
        }
        
        conversationRef = database.collection("conversations")
        conversationRef?.document(id).getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let conversationData = document.data() {
                    let conversation = Conversation()
                    conversation.conversationId = id
                    
                    if let conversationName = conversationData["conversationName"] as? String {
                        conversation.conversationName = conversationName
                    }
                    if let dateLastModified = conversationData["dateLastModified"] as? Date {
                        conversation.dateLastModified = dateLastModified
                    }
                    if let messagesReferences = conversationData["messages"] as? [DocumentReference] {
                        
                        for ref in messagesReferences {
                            self.getMessageById(ref.documentID, completion: { message in
                                print(message)
                                conversation.addMessage(message: message)
                            })
                        }
                    }
                    if let userReferences = conversationData["users"] as? [DocumentReference] {
                        
                        for ref in userReferences {
                            self.getUserByID(id: ref.documentID, completion: { user in
                                if let user = user {
                                    conversation.addUser(user: user)
                                }
                            })
                        }
                    }
                    self.conversationList.append(conversation)
                    completion(conversation)
                }
            } else {
                print("Document does not exist conv")
            }
        }
    }
    
    /**
     Function - getInvitationByID
     Description - Given an id, function finds the invitation in firebase and creates a invitation obejct
     */
    func getInvitationByID(id: String, completion: @escaping (Invitation) -> Void) {
        for invitation in invitationList {
            if invitation.invitationId == id {
                completion(invitation)
            }
        }
        
        invitationRef = database.collection("invitations")
        invitationRef?.document(id).getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let invitationData = document.data() {
                    let invitation = Invitation()
                    invitation.invitationId = id
                    
                    if let userReference = invitationData["inviter"] as? DocumentReference {
                        
                        self.getUserByID(id: userReference.documentID, completion: { user in
                            if let user = user {
                                invitation.inviter = user
                            }
                        })
                    }
                    if let homeReference = invitationData["home"] as? DocumentReference {
                        
                        self.getHomeByID(homeReference.documentID, completion: { home in
                            invitation.home = home
                        })
                    }
                    self.invitationList.append(invitation)
                    completion(invitation)
                }
            } else {
                print("Document does not exist conv")
            }
        }
    }
    
    /**
     Function - getCalendarByID
     Description - Given an id, function finds the calendar locally
     */
    func getCalendarByID(_ id: String) -> Calendar?{
        for calendar in calendarList {
            if calendar.calendarId == id {
                return calendar
            }
        }
        return nil
    }
    
    /**
     Function - getPaymentByID
     Description - Given an id, function finds the payment locally
     */
    func getPaymentByID(_ id: String) -> Payment?{
        for payment in paymentList {
            if payment.paymentId == id {
                return payment
            }
        }
        return nil
    }
    
    /**
     Function - getListItemByID
     Description - Given an id, function finds the listItem in firebase and creates a listItem obejct
     */
    func getListItemByID(_ id: String, completion: @escaping (ListItem) -> Void) {
        
        for listItem in listItemsList {
            if listItem.listItemId == id {
                completion(listItem)
                
            }
        }
        
        itemRef = database.collection("listItems")
        
        itemRef?.document(id).getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let itemData = document.data() {
                    let item = ListItem()
                    item.itemName = itemData["itemName"] as? String
                    item.completed = itemData["completed"] as? Bool
                    
                    if let reminderReferences = itemData["reminders"] as? [DocumentReference] {
                        for ref in reminderReferences {
                            self.getReminderByID(ref.documentID, completion: { reminder in
                                    item.addReminder(reminder: reminder)
                                })
                        }
                    }
                    self.listItemsList.append(item)
                    completion(item)
                }
            } else {
                print("Document does not exist listitem")
            }
        }
    }
    
    /**
     Function - getHomeByID
     Description - Given an id, function finds the home in firebase and creates a home obejct
     */
    func getHomeByID(_ id: String, completion: @escaping (Home) -> Void) {
        for home in homeList {
            if home.homeId == id {
                completion(home)
            }
        }
        
        homeRef = database.collection("homes")
        
        homeRef?.document(id).getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let homeData = document.data() {
                    let home = Home()
                    home.homeName = homeData["homeName"] as? String
                    if let usersReferences = homeData["users"] as? [DocumentReference] {
                        for ref in usersReferences {
                            self.getUserByID(id: ref.documentID, completion: { user in
                                if let user = user {
                                    home.addUser(user: user)
                                }
                            })
                        }
                    }
                    self.homeList.append(home)
                    completion(home)
                }
            } else {
                print("Document does not exist home")
            }
            
        }
    }
    
    /**
     Function - getUserByID
     Description - Given an id, function finds the user in firebase and creates a user obejct
     */
    func getUserByID(id: String, completion: @escaping (User?) -> Void) {
        
        for user in userList {
            if user.userId == id {
                completion(user)
                return
            }
        }
        
        userRef = database.collection("users")
        
        self.userRef?.document(id).getDocument { (document, error) in
            if let err = error {
                print("Error getting documents: \(err)")
                completion(nil)
            } else {
                
                if let userData = document?.data() {
                    let user = User()
                    user.userId = document?.documentID
                    user.fName = userData["fName"] as? String
                    user.lName = userData["lName"] as? String
                    user.email = userData["email"] as? String
                    user.profilePicId = userData["profilePicId"] as? String
                    
                    if let listReferences = userData["lists"] as? [DocumentReference] {
                        for ref in listReferences {
                            self.getListByID(ref.documentID, completion: { list in
                                user.addList(list: list)
                            })
                        }
                    }
                    if let conversationReferences = userData["conversations"] as? [DocumentReference] {
                        for ref in conversationReferences {
                            self.getConversationByID(id: ref.documentID, completion: { conversation in
                                user.addConversation(conversation: conversation)
                            })
                        }
                    }
                    if let calendarReferences = userData["calendars"] as? [DocumentReference] {
                        for ref in calendarReferences {
                            if let calendar = self.getCalendarByID(ref.documentID) {
                                user.addCalendar(calendar: calendar)
                            }
                        }
                    }
                    
                    if let homeReferences = userData["homes"] as? [DocumentReference] {
                        for ref in homeReferences {
                            self.getHomeByID(ref.documentID, completion: { home in
                                user.addHome(home: home)
                            })
                        }
                    }
                    self.listeners.invoke { (listener) in
                        if listener.listenerType == ListenerType.all {
                            listener.onListChange(change: .update, list: user.lists)
                            listener.onCalendarChange(change: .update, calendar: user.calendars)
                            listener.onConversationChange(change: .update, conversation: user.conversations)
                        }
                    }
                    self.userList.append(user)
                    completion(user)
                }
            }
        }
    }
   
    /**
     Function - getReminderByID
     Description - Given an id, function finds the reminder in firebase and creates a reminder obejct
     */
    func getReminderByID(_ id: String, completion: @escaping (Reminder) -> Void) {
        for reminder in reminderList {
            if reminder.reminderId == id {
                completion(reminder)
            }
        }
        
        reminderRef = database.collection("reminders")
        
        reminderRef?.document(id).getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let reminderData = document.data() {
                    let reminder = Reminder()
                    reminder.date = reminderData["date"] as? Date
                    reminder.alert = reminderData["alert"] as? String
                    self.reminderList.append(reminder)
                    completion(reminder)
                }
            } else {
                print("Document does not exist reminder")
            }
        }
    }
    
    /**
     Function - getMessageById
     Description - Given an id, function finds the message in firebase and creates a message obejct
     */
    func getMessageById(_ id: String, completion: @escaping (Message) -> Void) {
        for message in messageList {
            if message.messageId == id {
                completion(message)
            }
        }
        
        messageRef = database.collection("messages")
        
        messageRef?.document(id).getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let messageData = document.data() {
                    let message = Message()
                    message.content = messageData["content"] as? String
                    message.dateSent = messageData["dateSent"] as? Date
                    self.messageList.append(message)
                    completion(message)
                }
            } else {
                print("Document does not exist message")
            }
        }
    }
    
  // MARK: - Image Handling
    func uploadImage(data: Data) {
        
        let timestamp = UInt(Date().timeIntervalSince1970)
        let filename = "\(timestamp).jpg"
        
        let imageRef = storageReference.child((self.user?.userId!)! + String(timestamp))
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        imageRef.putData(data, metadata: metadata) {
            (meta, error) in
            
            if let error = error { print(error.localizedDescription)
                return
           }
            
            guard let urlPath = meta?.path! else { return }
            self.userRef?.document(self.user!.userId!).collection("profilePic") .document("\(timestamp)").setData([
                   "url" : "\(urlPath)"
               ])
        }
    }
    
    func saveImageData(filename: String, imageData: Data) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
    
    /**
     Function - parseImageSnapshot
     Description - Given a query snapshot, attempt to translate data into image
     */
    func parseImageSnapshot(snapshot: QuerySnapshot) -> UIImage {
        
        var imageVar = UIImage()
        
        snapshot.documentChanges.forEach { change in
            let imageName = change.document.documentID
            let imageURL = change.document.data()["url"] as! String
            let filename = ("\(imageName).jpg")
            
            if change.type == .added {
                if !self.imagePathList.contains(filename) {
                    if let image = self.loadImageData(filename: filename) {
                        self.imageList.append(image)
                        self.imagePathList.append(filename)
                        imageVar = image
                   } else {
                        
                        self.storage.reference(withPath: imageURL)
                            .getData(maxSize: 5 * 1024 * 1024) { data, error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            else if let data = data, let image = UIImage(data: data) { self.imageList.append(image)
                                self.imagePathList.append(filename)
                                self.saveImageData(filename: filename, imageData: data)
                                imageVar = image
                           }
                        }
                    }
                }
            }
        }
        return imageVar
    }
    
    func setupImageListener(){
        let userProfilePicRef = userRef?.document((self.user?.userId)!).collection("profilePic")
        
        snapshotListener = userProfilePicRef?.addSnapshotListener() { querySnapshot, error in
        guard let querySnapshot = querySnapshot else {
            print(error!)
            return
        }
            self.parseImageSnapshot(snapshot: querySnapshot)
        }
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
    
    /*func setupMessageListener(){
        messageRef = database.collection("messages")
        
        messageRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseMessageSnapshot(snapshot: querySnapshot)
        }
    }*/
        
    func setupUserListener(){
        userRef = database.collection("users")
        userRef?.whereField("email", isEqualTo: authController.currentUser?.email).addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first
            
            else {
                print("Error fetching users:")
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
        self.user = User()
        self.user?.fName = snapshot.data()["fName"] as? String
        self.user?.lName = snapshot.data()["lName"] as? String
        self.user?.email = snapshot.data()["email"] as? String
        self.user?.userId = snapshot.documentID
        
        if let listReferences = snapshot.data()["lists"] as? [DocumentReference] {
            for reference in listReferences {
                getListByID(reference.documentID, completion: { list in
                    self.user?.addList(list: list)
                })
            }
        }
        
        if let conversationReferences = snapshot.data()["conversations"] as? [DocumentReference] {
            for reference in conversationReferences {

                self.getConversationByID(id: reference.documentID, completion: { conversation in
                    self.user?.addConversation(conversation: conversation)
                    
                })
            }
        }
        
        if let paymentsReferences = snapshot.data()["payments"] as? [DocumentReference] {
            for reference in paymentsReferences {
                if let payment = getPaymentByID(reference.documentID) {
                    self.user?.payments.append(payment)
                }
            }
        }
        
        if let calendarsReferences = snapshot.data()["calendars"] as? [DocumentReference] {
            for reference in calendarsReferences {
                if let calendar = getCalendarByID(reference.documentID) {
                    self.user?.calendars.append(calendar)
                }
            }
        }
                
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user || listener.listenerType == ListenerType.all {
                    listener.onUserChange(change: .update,
                                          user: [self.user!])
            }
        }
    }

}
