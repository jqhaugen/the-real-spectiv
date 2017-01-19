//
//  ViewController.swift
//  spectiv1
//
//  Created by Jason Haugen on 11/10/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var profileCollection: UICollectionView!
    
    @IBOutlet weak var otherProfileNameLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    var selection: Int = 0;
    let rootRef = FIRDatabase.database().reference()
    
    var userEmail: String!
    var otherUserEmail: String!
    
    //Photos in collection view
    var photos: [VotePhoto] = []
    
    var photoNames: [String] = []
    
    //Words for each vote day
    var words: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        profileCollection.backgroundColor = UIColor.white
        profileCollection.reloadData()
        profileCollection.dataSource = self
        profileCollection.delegate = self
        
        if otherUserEmail == nil{
            userEmail = UserDefaults.standard.object(forKey: "currentUserEmail") as! String!
            userEmail = emailToFolder(email: userEmail)
            profileNameLabel.text = userEmail
        }
        else{
            userEmail = otherUserEmail
            userEmail = emailToFolder(email: userEmail)
            otherProfileNameLabel.text = userEmail
        }
        
        
        DispatchQueue.global(qos:  .userInitiated).async {
            
            self.fetchImages()
            // Bounce back to the main thread to update the UI
            /* DispatchQueue.main.async {
             self.imageView.image = image
             }*/
            self.profileCollection.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchImages(){
        self.photos = []
        self.photoNames = []
        rootRef.observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let elem = enumerator.nextObject() as? FIRDataSnapshot {
                self.getProfileImages(elem: elem.key)
            }
        })
    }
    
    func getProfileImages(elem: String) {
        let storage = FIRStorage.storage().reference()
        
        rootRef.child(elem).observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let elem = enumerator.nextObject() as? FIRDataSnapshot {
                let imageRef = storage.child("user_images/\(self.emailToFolder(email: self.userEmail!))/\(elem.key).JPG")
                imageRef.data(withMaxSize: 1 * 1024 * 1024 * 1024) { (data, error) -> Void in
                    if (error == nil) {
                        let image = UIImageView(image: UIImage(data: data!))
                        print("Key\(elem.key)")
                        self.photoNames.append(elem.key)
                        self.photos.append(VotePhoto(submitterName: self.emailToFolder(email: self.userEmail!), photoImage: image))
                    
                        self.profileCollection.reloadData()
                    }
                }
            }
        })
    }
    
    // ======================================
    // Collection View Delegate/Data Source Functions
    // ======================================
    
    //Set number of cells in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    //Set number of sections in collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Fill cells based on index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! VoteCell

        let photo: VotePhoto = indexPathPhoto(indexPath: indexPath as NSIndexPath)
        
        if (photo.submitterName == "") { //error check
            return cell
        }
        cell.profileImageView.image = photo.photoImage.image
        cell.submitterName = photo.submitterName

        return cell
    }
    
    //Selected cell, push cell view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoVoteView = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        
        print("At path \(photoNames[indexPath.row])")
        
        photoVoteView.photoName = photoNames[indexPath.row]
        
        let p = indexPathPhoto(indexPath: indexPath as NSIndexPath)
        photoVoteView.submitterName = emailToFolder(email: userEmail!)
        photoVoteView.image = p.photoImage.image
        
        self.navigationController?.pushViewController(photoVoteView, animated: true)
    }
    
    // ======================================
    // Collection View Layout Functions
    // ======================================
    
    //Edge insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    //Cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = (self.view.frame.width - 40) / 4.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    //Line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // ======================================
    // Helper Functions
    // ======================================
    
    //Get photo based on index path
    func indexPathPhoto(indexPath: NSIndexPath) -> VotePhoto {
        if (photos.count != 0) {
            return photos[indexPath.row]
        } else {
            return VotePhoto(submitterName: "", photoImage: UIImageView(image: UIImage(named: "")))
        }
    }
    
    func emailToFolder(email: String) -> String{
        let strippedText = email.components(separatedBy: CharacterSet.punctuationCharacters).joined(separator: "").components(separatedBy: " ").filter{!$0.isEmpty}
        var folder = ""
        for block in strippedText{
            folder+=block
        }
        
        return folder
    }

}

