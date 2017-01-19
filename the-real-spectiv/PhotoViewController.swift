//
//  ViewController.swift
//  spectiv1
//
//  Created by Jason Haugen on 11/10/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class PhotoViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var userEmail: String!
    //Outlets
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var thePicture: UIImageView!
    @IBOutlet weak var photoWord: UILabel!
    
    //Firebase variables
    let rootRef = FIRDatabase.database().reference()
    
    // ======================================
    // Basic Functions
    // ======================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        submitBtn.isHidden = true
        
        rootRef.child(getDate()).observe(.value, with: { snapshot in
            for item in snapshot.children {
                self.photoWord.text = (item as AnyObject).key
            }
        })
        
        userEmail = UserDefaults.standard.object(forKey: "currentUserEmail") as! String!
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ======================================
    // Image Picker Functions
    // ======================================
    
    //Set image in image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        thePicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
        submitBtn.isHidden = false
    }

    
    // ======================================
    // Take/Submit Photo Functions
    // ======================================
    
    //Take photo, go to imagePickerController
    @IBAction func cameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    //Submit photo
    @IBAction func submitPicture(_ sender: Any) {
        //send photo to storage under directory "currentUser/photoWord.png"
        //overwrite if necessary
        let storage = FIRStorage.storage().reference()
        
        //create file from image
        let imageFile = convertImageViewToData()
        
        let user_folder = emailToFolder(email: userEmail)
        let directory_str = "user_images/\(user_folder)/\(photoWord.text!).JPG"
        let target_directory = storage.child(directory_str)
        print(target_directory.fullPath)
        
        //Upload the file to the target directory
        _ = target_directory.put(imageFile, metadata: nil) { metadata, error in
            if (error != nil) {
                print("Error uploading file")
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
                print("Download URL is \(downloadURL)")
                self.writeImageInfoDB(path: directory_str)
            }
        }
    }
    
    func writeImageInfoDB(path: String){
        let database = FIRDatabase.database().reference()
        database.child(photoWord.text!).updateChildValues(([emailToFolder(email: userEmail): "0"]))
    }
    
    func convertImageViewToData() -> Data{
        if let data = UIImageJPEGRepresentation(thePicture.image!, 1.0) {
            return data
        }
        return Data()
    }
    
    func emailToFolder(email: String) -> String{
        let strippedText = email.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "").components(separatedBy: " ").filter{!$0.isEmpty}
        var folder = ""
        for block in strippedText{
            folder+=block
        }
        
        return folder
    }
    
    // helper functions
    func getDate()->String{
        let gmt = NSDate()
        let array = gmt.description.components(separatedBy: " ")
        let day = array[0]
        return day
    }
    
}
