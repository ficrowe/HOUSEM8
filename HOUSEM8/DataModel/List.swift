//
//  List.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseFirestoreSwift


class List: NSObject, Codable {

    @DocumentID var listId: String?
    var listName: String?
    var dateCreated: Date?
    var dateLastModified: Date?
    var listItems: [ListItem] = []
    
    
    func removeItem(item: ListItem) {
        if let index = self.listItems.firstIndex(of: item) {
            self.listItems.remove(at: index)
        }
    }
    
    
}
