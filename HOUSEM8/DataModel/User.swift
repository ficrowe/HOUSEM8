//
//  User.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift
import MessageKit


struct UserStruct: SenderType {
    var senderId: String
    
    var displayName: String
    
}

class User: NSObject, Codable {
    
    @DocumentID var userId: String?
    var fName: String?
    var lName: String?
    var email: String?
    var lists: [List] = []
    var calendars: [Calendar] = []
    var conversations: [Conversation] = []
    var payments: [Payment] = []
    var homes: [Home] = []
    var invitations: [Invitation] = []
    var profilePicId: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case fName
        case lName
        case email
        case lists
        case calendars
        case conversations
        case payments
        case homes
        case invitations
        case profilePicId
    }
    
    func addList(list: List) {
        
        self.lists.append(list)
    }
    
    func removeList(list: List) {
        if let index = self.lists.firstIndex(of: list) {
            self.lists.remove(at: index)
        }
    }
    
    func addConversation(conversation: Conversation) {
        
        self.conversations.append(conversation)
    }
    
    func removeConversation(conversation: Conversation) {
        if let index = self.conversations.firstIndex(of: conversation) {
            self.conversations.remove(at: index)
        }
    }
    
    func addInvitation(invitation: Invitation) {
        self.invitations.append(invitation)
    }
    
    func removeInvitation(invitation: Invitation) {
        if let index = self.invitations.firstIndex(of: invitation) {
            self.invitations.remove(at: index)
        }
    }
    
    func addCalendar(calendar: Calendar) {
        self.calendars.append(calendar)
    }
    
    func addHome(home: Home) {
        self.homes.append(home)
    }
    
    func getFullName() -> String {
        return self.fName! + " " + self.lName!
    }
    
    func addProfilePic(id: String) {
        self.profilePicId = id
    }
    
    func removeProfilePic() {
        self.profilePicId = nil
    }
    

}
