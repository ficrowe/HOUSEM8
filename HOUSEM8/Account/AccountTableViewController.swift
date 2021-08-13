//
//  AccountTableViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit
import FirebaseStorage

class AccountTableViewController: UITableViewController {
    
    // Defining sections
    let SECTION_USER = 0
    let SECTION_INVITATIONS = 1
    let SECTION_HOMES = 2
    let SECTION_LOGOUT = 3
    
    // Define cell identifiers
    let CELL_USER = "userCell"
    let CELL_HOME = "homeCell"
    let CELL_INVITATION = "invitationCell"
    let CELL_LOGOUT = "logoutCell"
    
    var databaseController: DatabaseProtocol?
    var user: User?
    
    var storageReference = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set user
        self.user = databaseController?.user
    }

    // MARK: - Table view data source

    // Function returns number of sections in table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    // Function returns the number of rows for each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_USER {
            return 1
        }
        else if section == SECTION_INVITATIONS {
            return self.user?.invitations.count ?? 0
        }
        else if section == SECTION_HOMES {
            return self.user?.homes.count ?? 0
        }
        return 1
    }

    // Function displays cell depending on section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // If in logout section, display logout cell
        if indexPath.section == SECTION_LOGOUT {
            let logoutCell = tableView.dequeueReusableCell(withIdentifier: CELL_LOGOUT, for: indexPath)
            return logoutCell
        }
        // If in invitation section, display invitation cell
        else if indexPath.section == SECTION_INVITATIONS {
            let invitationCell = tableView.dequeueReusableCell(withIdentifier: CELL_INVITATION, for: indexPath)
            return invitationCell
        }
        // If in home section, display home cell
        else if indexPath.section == SECTION_HOMES {
            let homeCell = tableView.dequeueReusableCell(withIdentifier: CELL_HOME, for: indexPath)
            homeCell.textLabel?.text = self.user?.homes[indexPath.row].homeName
            var homeUsersString = ""
            if let homeUsers = self.user?.homes[indexPath.row].users {
                for user in homeUsers {
                    homeUsersString +=  user.getFullName()
                }
                homeCell.detailTextLabel?.text = homeUsersString
            }
            return homeCell
        }
        // If in user section, display user cell
        else {
            let userCell = tableView.dequeueReusableCell(withIdentifier: CELL_USER, for: indexPath)
            userCell.textLabel?.text = self.user?.getFullName()
            return userCell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If logout is tapped, log user out
        if indexPath.section == SECTION_LOGOUT {
            databaseController?.signOut()
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editHomeSegue" {
            let editHomeViewController = segue.destination as? EditHomeViewController
            // Get selected row
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Set home of editHomeViewController
                editHomeViewController?.home = self.user?.homes[selectedIndexPath.row]
                
            }
        }
    }
    
}
