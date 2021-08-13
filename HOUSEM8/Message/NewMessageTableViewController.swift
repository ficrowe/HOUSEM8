//
//  NewMessageTableViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit

class NewMessageTableViewController: UITableViewController {
    
    
    let SECTION_USER = 0
    
    let CELL_USER = "userCell"
    
    var databaseController: DatabaseProtocol?
    var user: User?
    var homeUsers: [User]?
    var selectedUsers: [User] = []
    
    // Defining delegate property
    weak var addConversationDelegate: AddConversationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        self.user = databaseController?.user
        self.homeUsers = databaseController?.currentHome!.users
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.homeUsers?.count ?? 0
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userCell = tableView.dequeueReusableCell(withIdentifier: CELL_USER, for: indexPath)
        
        // Get meal for this row
        if let user = homeUsers?[indexPath.row] {
            
            // Set labels appropriately
            userCell.textLabel?.text = user.getFullName()
        }
        return userCell
      
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    // Method for when a cell row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == SECTION_USER {
            let userCell = tableView.cellForRow(at: indexPath) as UITableViewCell?
            
            if userCell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
                userCell?.accessoryType = UITableViewCell.AccessoryType.none
                if let user = homeUsers?[indexPath.row] {
                    guard let userIndex = selectedUsers.firstIndex(of: user) else { return }
                    self.selectedUsers.remove(at: userIndex)
                }
                
            }
            else {
                userCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                if let user = homeUsers?[indexPath.row] {
                    self.selectedUsers.append(user)
                }
                
            }
        }
        
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newConversationSegue" {
            let newConversationController = segue.destination as! NewConversationTableViewController
            newConversationController.conversationUsers = self.selectedUsers
            newConversationController.addConversationDelegate = self.addConversationDelegate
            
        }
        
    }
    

}
