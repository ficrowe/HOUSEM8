//
//  ListsTableViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 6/5/21.
//

import UIKit

class ListsTableViewController: UITableViewController {
    
    // Defining sections and cells
    let SECTION_LIST = 0
    //let SECTION_INFO = 1
    let CELL_LIST = "listCell"
    //let CELL_INFO = "mealNumberCell"
    
    // Defining listener and databaseController
    var listenerType = ListenerType.list
    weak var databaseController: DatabaseProtocol?
    
    // Defining user and MealList
    var user: User?
    var listList: [List] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Initialise mealCell
        let listCell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath)
        
        // Get meal for this row
        let list = listList[indexPath.row]

        // Set labels appropriately
        listCell.textLabel?.text = list.listName
        return listCell

    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Perform batch updates to remove meal from user's meals, and remove from mealList
            // Update table
             tableView.performBatchUpdates({
                databaseController?.removeListFromUser(list: listList[indexPath.row], user: user!)
                
                databaseController?.deleteList(list: listList[indexPath.row])
                self.listList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
             }, completion: nil)
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
                
                listViewTableViewController.list = listList[selectedIndexPath.row]
                
            }
        }
    }
    

}
