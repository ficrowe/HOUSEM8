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
    var houseName: String?
    var users: [User] = []
    
}
