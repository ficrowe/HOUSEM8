//
//  CreateHomeViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 18/6/21.
//

import UIKit

class CreateHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let SECTION_INVITE = 0
    
    let CELL_INVITE = "inviteCell"

    @IBOutlet weak var houseNameField: UITextField!
    @IBOutlet weak var houseAddressField: UITextField!
    @IBOutlet weak var invitationTable: UITableView!
    
    var invitationList: [String] = []
    
    //@IBOutlet weak var invitationCell: InvitationTableViewCell!
    
    var user: User?
    var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        invitationTable.dataSource = self
        invitationTable.delegate = self
        
        self.user = databaseController?.user

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createHome(_ sender: Any) {
        if self.checkFields() {
            if let homeName = houseNameField.text, let homeAddress = houseAddressField.text {
                if let newHome = databaseController?.addHome(homeAddress: homeAddress, homeName: homeName) {
                    self.user?.addHome(home: newHome)
                    
                    databaseController?.currentHome = newHome
                    
                    self.addInvites()
                    
                    for invite in invitationList {
                        
                        databaseController?.getUserByEmail(email: invite, completion: {
                            user in
                            guard let newInvite = self.databaseController?.addInvitation(inviter: self.user!, home: newHome)
                            else {
                                return
                            }
                            user?.addInvitation(invitation: newInvite)
                        })
                        
                    }
                    
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let sceneDelegate = windowScene.delegate as? SceneDelegate
                      else {
                        return
                      }
                    
                    
                    sceneDelegate.goToHome()
                }
            }
        }
        displayMessage(title: "Missing Fields", message: "Please ensure the name and address fields are filled.")
    }
    
    func checkFields() -> Bool {
        if houseNameField.hasText && houseAddressField.hasText {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitationList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Initialise
        let invitationCell = tableView.dequeueReusableCell(withIdentifier: CELL_INVITE, for: indexPath) as! InvitationTableViewCell
        
        // Set label appropriately
        //invitationCell.textLabel?.text = "Tap to enter email"
    
        return invitationCell
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
        // Perform batch updates
        invitationTable.performBatchUpdates({
            
            // Add the new invitation cell to the table
            invitationTable.insertRows(at: [IndexPath(row: indexPath.row + 1, section: SECTION_INVITE)], with: .automatic)
            invitationTable.reloadSections([SECTION_INVITE], with: .automatic)
        }, completion: nil)
    }
    
    func addInvites() {
        
        let numRows = invitationTable.numberOfRows(inSection: SECTION_INVITE)
        
        for i in 0...numRows {
            
            let indexPath = IndexPath(item: i, section: SECTION_INVITE)
            
            if let currentCell = invitationTable.cellForRow(at: indexPath) as? InvitationTableViewCell {
                if currentCell.checkField() {
                    invitationList.append(currentCell.getText()!)
                }
                
            }
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
