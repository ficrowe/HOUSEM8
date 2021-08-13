//
//  MessagesTableViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit

class MessagesTableViewController: UITableViewController, AddConversationDelegate {
    
    weak var databaseController: DatabaseProtocol?
    let SECTION_CONVERSATION = 0
    let CELL_CONVERSATION = "conversationCell"
    
    var user: User?
    var messageList: [Conversation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        self.user = self.databaseController?.user
        self.messageList = self.user?.conversations
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let convoCell = tableView.dequeueReusableCell(withIdentifier: CELL_CONVERSATION, for: indexPath)
            
        let conversation = self.messageList?[indexPath.row]

        convoCell.textLabel?.text = conversation?.conversationName
        convoCell.imageView
        
        return convoCell
       
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.performBatchUpdates({
                if let conversation = messageList?[indexPath.row] {
                    
                    databaseController?.removeConversationFromUser(conversation: conversation, user: self.user!)
                     databaseController?.deleteConversation(conversation: conversation)
                    self.messageList!.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.reloadSections([SECTION_CONVERSATION], with: .automatic)
                }
               
            }, completion: nil)
        } else if editingStyle == .insert {
            
        }    
    }
    

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
    
    func addConversation(conversation: Conversation) {
        // Perform batch updates
        tableView.performBatchUpdates({
            
            // Add meal to user's meals and to the mealList
            messageList?.append(conversation)
            
            // Add the new meal cell to the table
            tableView.insertRows(at: [IndexPath(row: messageList!.count - 1, section: SECTION_CONVERSATION)], with: .automatic)
            tableView.reloadSections([SECTION_CONVERSATION], with: .automatic)
        }, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "newMessageSegue" {
            let newMessageViewController = segue.destination as! NewMessageTableViewController
            newMessageViewController.addConversationDelegate = self
            
        }
        else if segue.identifier == "showConversationSegue" {
            let conversationViewController = segue.destination as! ConversationViewController
            
            // Get selected row
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                conversationViewController.conversation = messageList?[selectedIndexPath.row]
                
            }

        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
