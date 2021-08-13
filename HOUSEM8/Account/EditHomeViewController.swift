//
//  EditHomeViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 19/6/21.
//

import UIKit
import MapKit
import CoreLocation

class EditHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // Define sections
    let SECTION_USER = 0
    
    // Define cell identifier
    let CELL_USER = "userCell"
    
    var home: Home?
    var user: User?
    var databaseController: DatabaseProtocol?
    
    var geoLocation: CLCircularRegion?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var userAddress: CLLocation?
    
    // Text fields and table view references
    @IBOutlet weak var homeAddressField: UITextField!
    @IBOutlet weak var homeNameField: UITextField!
    @IBOutlet weak var userTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise location Manager
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Set databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set user
        self.user = databaseController?.user
        
        // Set fields appropriately
        homeNameField.text = self.home?.homeName
        homeAddressField.text = self.home?.homeAddress
        
        // Attempt to convert string address into co-ordinates, set as location
        if let address = self.home?.homeAddress {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    print("not found")
                    return
                }

                // Set user address location
                self.userAddress = location
            }
        }

        // Set table view delegates
        self.userTable.delegate = self
        self.userTable.dataSource = self
        
    }
    
    // When view appears, start updating location
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    // When view disappears, stop updating location
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    // Alert user if they move from home
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
         let alert = UIAlertController(title: "Movement Detected!",
                                       message: "You have left Home", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
         self.present(alert, animated: true, completion: nil)
    }
    
    // Update locations and start looking for movement from home
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
    locations: [CLLocation]) {
        
        currentLocation = locations.last?.coordinate
        geoLocation = CLCircularRegion(center: currentLocation!, radius: 500, identifier: "user")
        geoLocation?.notifyOnExit = true
        locationManager.startMonitoring(for: geoLocation!)
    }
    
    // Method to set headers for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        // Set headers for each section appropriately
        if section == SECTION_USER{
            return "Users"
        }
        else{
            return ""
        }
    }
    
    // Function determines the number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.home?.users.count ?? 0
    }
    
    // Function sets cells in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentUser = self.home?.users[indexPath.row]
        
        let userCell = userTable.dequeueReusableCell(withIdentifier: CELL_USER, for: indexPath)
        userCell.textLabel?.text = currentUser?.getFullName()
        
        let userHome = isUserHome(user: currentUser!)
        if userHome {
            userCell.detailTextLabel?.text = "Currently at Home"
        }
        else {
            userCell.detailTextLabel?.text = "Not at Home"
        }
        
        return userCell
    }
    
    // Function determines if user is home, returns boolean
    func isUserHome(user: User) -> Bool {
        locationManager.requestLocation()
        let userLocation = currentLocation
        
        return true
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
