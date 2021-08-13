//
//  NewListViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 7/6/21.
//

import UIKit

class NewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    let SECTION_LISTITEM = 0
    let SECTION_ADDITEM = 1
    
    let CELL_LISTITEM = "listItemCell"
    let CELL_ADDITEM = "addItemCell"

    
    @IBOutlet weak var listNameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var listItems: [String] = []
    var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_LISTITEM {
            return listItems.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SECTION_LISTITEM {
            let listItemCell = tableView.dequeueReusableCell(withIdentifier: CELL_LISTITEM, for: indexPath)
            
            // Get meal for this row
            let listItem = listItems[indexPath.row]
                
            // Set labels appropriately
            listItemCell.textLabel?.text = listItem
            
            return listItemCell
        }
        else {
            let addItemCell = tableView.dequeueReusableCell(withIdentifier: CELL_ADDITEM, for: indexPath)
            
            
            return addItemCell
        }
        
        
    }
    
    
    
    @IBAction func addListItem(_ sender: Any) {
        
       tableView.performBatchUpdates({
                
            // Add the new meal cell to the table
            tableView.insertRows(at: [IndexPath(row: listItems.count, section: SECTION_LISTITEM)], with: .automatic)
                //tableView.reloadSections([SECTION_LISTITEM], with: .automatic)
            }, completion: nil)
        }
        
       
        
    
   
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "saveList" {
            let name = listNameField.text
            var newListItems: [ListItem] = []
            
            // If name and instructions are not nil...
            if name != nil {
                
                for listItem in self.listItems {
                    guard let newListItem = databaseController?.addListItem(itemName: listItem) else { return }
                    newListItems.append(newListItem)
                }
                let newList = databaseController?.addList(listName: name ?? "", listItems: newListItems)
                print(newList)
                
                let listViewController = segue.destination as? ListViewTableViewController
                listViewController?.list = newList
            }
            else{
                
                // If name an dinstructions are blank, display error and return
                displayMessage(title: "Missing Fields", message: "Please ensure all fields are filled before saving")
                return
            }
        }
    }
    

}
