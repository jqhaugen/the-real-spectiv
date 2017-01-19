//
//  ViewController.swift
//  spectiv1
//
//  Created by Jason Haugen on 11/10/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class FollowProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var profileCollection: UICollectionView!
    var selection: Int = 0;
    let rootRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage()
    
    //Photos in collection view
    var photos: [VotePhoto]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        profileCollection.backgroundColor = UIColor.white
        profileCollection.reloadData()
        profileCollection.dataSource = self
        profileCollection.delegate = self
        
        DispatchQueue.global(qos:  .userInitiated).async {
            
            self.fetchSubmissions()
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
    
    
    func fetchSubmissions(){
        var userSubmissions: [String] = []
        
        rootRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            for key in postDict.keys {
                userSubmissions.append(key)
            }
            
            self.fetchImages(submissions: userSubmissions)
        })
    }
    
    func fetchImages(submissions: [String]){
        let userImagesRef = storageRef.reference().child("user_images")
        for file in submissions{
            let pathRef = userImagesRef.child("bmorellwustledu").child(file+".JPG")
            
            pathRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    let image = UIImage(data: data!)
                    self.photos?.append(VotePhoto(submitterName: "bmorellwustledu", photoImage: UIImageView(image: image)))
                    self.profileCollection.reloadData()
                }
            }
        }
    }
    
    // ======================================
    // Collection View Delegate/Data Source Functions
    // ======================================
    
    //Set number of cells in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.photos != nil) {
            return self.photos!.count
        } else {
            return 24
        }
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
        cell.profileImageView = photo.photoImage
        cell.submitterName = photo.submitterName
        
        return cell
    }
    
    //Selected cell, push cell view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoVoteView = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        
        let p = indexPathPhoto(indexPath: indexPath as NSIndexPath)
        photoVoteView.submitterName = "jason"
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
        if (photos != nil) {
            return photos![indexPath.row]
        } else {
            return VotePhoto(submitterName: "", photoImage: UIImageView(image: UIImage(named: "penguin.jpg")))
        }
    }
    
    //Grab photos from storage
    func getVotePhotos() {
        //** Do asynchronously **
        //Go through each user's folder in storage
        //Find photo with name "vote_word.png"
        //Append photo to _photos_ array
    }
}

