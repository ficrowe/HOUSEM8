//
//  EditUserViewController.swift
//  HOUSEM8
//
//  Created by Fiona Crowe on 18/6/21.
//

import UIKit
import FirebaseStorage

class EditUserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User?
    var databaseController: DatabaseProtocol?
    var storageReference = Storage.storage().reference()

    // Outlets to UI fields and iimage
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var fNameField: UITextField!
    @IBOutlet weak var lNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var image = UIImage()
    var imagePath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set user
        self.user = databaseController?.user
        
        // Set fields appropriately
        fNameField.text = self.user?.fName
        lNameField.text = self.user?.lName
        emailField.text = self.user?.email
        
        if self.user?.profilePicId != nil {
            print(self.user?.profilePicId)
            profilePic.image = databaseController?.loadImageData(filename: (self.user?.profilePicId)!)
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        // Update user object and in database
        if let user = self.user, let fName = fNameField.text, let lName = lNameField.text, let email = emailField.text, let profilePicId = user.profilePicId {
            databaseController?.updateUser(user: user, fName: fName, lName: lName, email: email, profilePicId: profilePicId)
        }
        
        // Go back to account page
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editProfilePic(_ sender: Any) {
        // When edit is pressed on the profile pic, allow user to select photo
        takePhoto()
    }
    
    // Function handles interaction with image picker
    func imagePickerController(_ picker: UIImagePickerController,
     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Get selected image
        if let pickedImage = info[.originalImage] as? UIImage {
            profilePic.image = pickedImage
            // Save image
            savePhoto()
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Dismiss image picker when cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Function allows user to take photo from camera or photolibrary
    func takePhoto() {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        }
        else {
            controller.sourceType = .photoLibrary
        }
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    // Function attempts to save image
    func savePhoto() {
        guard let image = profilePic.image else {
            print("Cannot save until an image has been selected!")
            return
        }
        
        let timestamp = UInt(Date().timeIntervalSince1970)
        let filename = "\(timestamp).jpg"
        self.user?.profilePicId = filename
        
        let imageRef = storageReference.child("\(self.user?.userId)/\(timestamp)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Image data could not be compressed")
            return
        }
        
        databaseController?.uploadImage(data: data)
        
        databaseController?.saveImageData(filename: filename, imageData: data)
        
        //profilePic.image = data
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
