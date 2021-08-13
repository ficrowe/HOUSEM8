//
//  WelcomeViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 18/6/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var user: User?
    var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        self.user = databaseController?.user

    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createHomeSegue" {
            let createHomeViewController = segue.destination as! CreateHomeViewController
            createHomeViewController.user = self.user
        }
    }
    

}
