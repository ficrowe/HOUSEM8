//
//  Invitation.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 18/6/21.
//

import UIKit
import FirebaseFirestoreSwift

class Invitation: NSObject, Codable {

    @DocumentID var invitationId: String?
    var home: Home?
    var inviter: User?
    
}
