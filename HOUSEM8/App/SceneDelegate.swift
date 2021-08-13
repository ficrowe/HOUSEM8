//
//  SceneDelegate.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 5/5/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var databaseController: DatabaseProtocol?
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Get database Controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Check if user is signed in...
        databaseController?.addAuthListener(completion: {
            bool in
            // If no, go to login
            if bool == false {
                self.goToLogin()
            }
            // If yes, go to home
            /*else {
                self.goToHome()
            }*/
        })
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    // Sends user to home screen
    func goToHome() {
        
        let homeVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        
        self.window?.rootViewController = homeVC
        self.window?.makeKeyAndVisible()
    }
    
    // Sends user to login screen
    func goToLogin() {
        let loginVC = self.storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")

        self.window?.rootViewController = loginVC
        self.window?.makeKeyAndVisible()
    }
    
    func goToWelcome() {
        let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeNavigationController")
        
        self.window?.rootViewController = welcomeVC
        self.window?.makeKeyAndVisible()
    }


}

