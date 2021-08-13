//
//  NewConversationTableViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 9/6/21.
//

import UIKit

class NewConversationTableViewController: UITableViewController {
    
    
    let SECTION_MESSAGE = 0
    let SECTION_USER = 1
    
    let CELL_USER = "userCell"
    let CELL_MESSAGE = "messageCell"
    
    var databaseController: DatabaseProtocol?
    var user: User?
    var conversation: Conversation?
    var conversationUsers: [User]?
    var messageCell: NewMessageTableViewCell?
    
    weak var addConversationDelegate: AddConversationDelegate?

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        self.user = databaseController?.user
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == SECTION_MESSAGE {
            return 1
        }
        else {
            return self.conversationUsers?.count ?? 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_MESSAGE {
            guard let messageCell = tableView.dequeueReusableCell(withIdentifier: CELL_MESSAGE, for: indexPath) as? NewMessageTableViewCell else { fatalError() }
            
            self.messageCell = messageCell
            
            self.messageCell?.messageField?.placeholder = "Write a message..."
          
            return self.messageCell!
        }
        else {
            let userCell = tableView.dequeueReusableCell(withIdentifier: CELL_USER, for: indexPath)
            
            if let user = conversationUsers?[indexPath.row] {
                userCell.textLabel?.text = user.getFullName()
            }
            
          
            return userCell
        }
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sendMessageSegue" {
            if let msg = messageCell?.messageField.text {
                
                var conversationName = ""
                for user in self.conversationUsers! {
                    if user == self.conversationUsers?[0] {
                        conversationName += user.fName!
                    }
                    else {
                        conversationName += ", " + user.fName!
                    }
                }
                
                guard let newConversation = databaseController?.addConversation(users: self.conversationUsers ?? [], conversationName: conversationName) else { return }
                
                if let message = databaseController?.addMessage(text: msg, conversation: newConversation, sender: self.user!) {
                    print(message.sender)
                    databaseController?.addMessageToConversation(message: message, conversation: newConversation)
                }
               

                databaseController?.addConversationToUser(user: self.user!, conversation: newConversation)
                
                if let addConversationDelegate = addConversationDelegate {
                    addConversationDelegate.addConversation(conversation: newConversation)
                }
                
                let conversationViewController = segue.destination as? ConversationViewController
                conversationViewController?.conversation = newConversation
                
            }
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
