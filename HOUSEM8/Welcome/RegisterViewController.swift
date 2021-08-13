//
//  RegisterViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 18/6/21.
//

import UIKit

class RegisterViewController: UIViewController, UIScrollViewDelegate {
  
    @IBOutlet weak var fNameField: UITextField!
    @IBOutlet weak var lNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var homeAddressField: UITextField!
    
    var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
    }
    
    @IBAction func registerUser(_ sender: Any) {
        
        if self.checkFields() {
            databaseController?.registerUser(fName: fNameField.text!, lName: lNameField.text!, email: emailField.text!, password: passwordField.text!, completion: { user in
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate
                  else {
                    return
                  }
                
                //self.databaseController?.user = user
                
                sceneDelegate.goToWelcome()
                
            })
        }
        else {
            displayMessage(title: "Missing Fields", message: "Please ensure all required fields are filled")
        }
        
    }
    
    func checkFields() -> Bool {
        
        // Check correct email
        // Check if password meets 6-digit requirements
        // Add required field indicators
        if fNameField.hasText && lNameField.hasText && emailField.hasText && passwordField.hasText {
            return true
        }
        return false
    }
    
    @IBAction func goToLogin(_ sender: Any) {
        
        // Get array of active view controllers
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        
        // Go back 1 page
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }

}
