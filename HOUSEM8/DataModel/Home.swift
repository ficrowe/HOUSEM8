//
//  Home.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift

class Home: NSObject, Codable {

    @DocumentID var homeId: String?
    var homeName: String?
    var homeAddress: String?
    var users: [User] = []
    
    enum CodingKeys: String, CodingKey {
        case homeId
        case homeName
        case users
        case homeAddress
    }
    
    func addUser(user: User) {
        self.users.append(user)
    }
    
    func setHomeName(homeName: String) {
        self.homeName = homeName
    }
    
    func removeUser(user: User) {
        if let index = self.users.firstIndex(of: user) {
            self.users.remove(at: index)
        }
    }
    
}
