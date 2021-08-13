//
//  ListsTableViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit

class ListsTableViewController: UITableViewController, DatabaseListener {
    
    
    
    // Defining sections and cells
    let SECTION_LIST = 0
    
    let CELL_LIST = "listCell"
    
    // Defining listener and databaseController
    var listenerType = ListenerType.list
    weak var databaseController: DatabaseProtocol?
    
    // Defining user and MealList
    var user: User?
    var listList: [List] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        self.user = databaseController?.user
        
        guard self.user?.lists != nil else { return }
        self.listList = self.user!.lists
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.listList.count
        
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let listCell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath)
        
        // Get meal for this row
        let list = self.listList[indexPath.row]
        
        // Set labels appropriately
        listCell.textLabel?.text = list.listName
        
        return listCell
        

    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
       
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Perform batch updates to remove list from user's lists, and remove from listList
            // Update table
             tableView.performBatchUpdates({
                databaseController?.removeListFromUser(list: listList[indexPath.row], user: user!)
                
                databaseController?.deleteList(list: listList[indexPath.row])
                self.listList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
             }, completion: nil)
        }
    }
    
    // Adding and removing listeners on view appear and disappear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
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
    
    func onListChange(change: DatabaseChange, list: [List]) {
        self.listList = databaseController?.user?.lists ?? []
        // reload table
        tableView.reloadData()
    }
    
    func onCalendarChange(change: DatabaseChange, calendar: [Calendar]) {
        
    }
    
    func onCalendarEventChange(change: DatabaseChange, calendarEvent: [CalendarEvent]) {
        
    }
    
    func onUserChange(change: DatabaseChange, user: [User]) {
        
    }
    
    func onConversationChange(change: DatabaseChange, conversation: [Conversation]) {
        
    }
    
    func onPaymentChange(change: DatabaseChange, payment: [Payment]) {
        
    }
    
    func onReminderChange(change: DatabaseChange, reminder: [Reminder]) {
        
    }
    
    func onHomeChange(change: DatabaseChange, home: [Home]) {
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        // If seguing to CreatEditMeal
        if segue.identifier == "listViewSegue" {
            
            // Set segue destination
            let listViewTableViewController = segue.destination as! ListViewTableViewController
            
            // Get selected row
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                listViewTableViewController.list = self.listList[selectedIndexPath.row]
                
            }
        }
    }
    

}
