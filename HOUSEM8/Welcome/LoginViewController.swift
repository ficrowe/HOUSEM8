//
//  LoginViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 5/5/21.
//

import UIKit
//import FirebaseAuth

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var databaseController: DatabaseProtocol?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

    }
   
    @IBAction func login(_ sender: Any) {
        
        guard let password = passwordField.text else {
         displayMessage(title: "Error", message: "Please enter a password")
         return
        }

        guard let email = emailField.text else {
         displayMessage(title: "Error", message: "Please enter an email")
         return
        }
        
        databaseController?.login(email: email, password: password, completion: { user in
            
            
            if user == nil {
                self.displayMessage(title: "Failed login", message: "Please retry login")
                return
            }
            else{
                self.databaseController?.user = user
                    
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = windowScene.delegate as? SceneDelegate
                else {
                    return
                }
                sceneDelegate.goToHome()
            }
        })
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginSegue" {
            
            // Set segue destination
            let homeViewController = segue.destination as! HomeTableViewController
            
            // Pass delegate
            homeViewController.user = databaseController?.user
        }
    }
    

}
