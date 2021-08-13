//
//  UIViewController-fcro0003.swift
//  FIT3178 W3 Lab
//
//  Created by Fiona Crowe on 12/3/21.
//

import Foundation

import UIKit

extension UIViewController {
    
    /**
     The displayMessage function takes a title and message, and displays a pop-up alert to the user

     - Parameter title: The title of the alert
     - Parameter message: The message for the alert
     */
    func displayMessage(title: String, message: String) {
        
        // Instantiate alert
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add action for alert (dismiss)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        // Display alert
        self.present(alertController, animated: true, completion: nil)
        
        debugPrint("hi")
    }
    
    //TODO: Add notification code here
    //debugPrint
}
