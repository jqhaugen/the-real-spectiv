//
//  ViewController.swift
//  spectiv1
//
//  Created by Jason Haugen on 11/10/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class VoteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //Outlets
    @IBOutlet weak var voteCollection: UICollectionView!
    @IBOutlet weak var voteWord: UILabel!
    @IBOutlet weak var noPhotosMsg: UILabel!
    
    //Photos in collection view
    var photos: [VotePhoto] = []
    var photoCache: [VotePhoto]?
    
    //All users who submitted for vote word
    var usersSubmitted: [String] = []
    
    //Firebase variables
    let rootRef = FIRDatabase.database().reference()
    
    // ======================================
    // View Functions
    // ======================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        voteCollection.backgroundColor = UIColor.white
        voteCollection.reloadData()
        
        voteCollection.dataSource = self
        voteCollection.delegate = self
        
        
        let calendar = Calendar.current
        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: Date())
        let yesterday = oneDayAgo?.description.components(separatedBy: " ")[0]
        
        // set the word to the word from yesterday's contest
        rootRef.child(yesterday!).observeSingleEvent(of: .value, with: { snapshot in
            for item in snapshot.children {
                self.voteWord.text = (item as AnyObject).key
            }
            self.rootRef.child(yesterday!).child(self.voteWord.text!).observeSingleEvent(of: .value, with: { snapshot in
                let enumerator = snapshot.children
                while let elem = enumerator.nextObject() as? FIRDataSnapshot {
                    self.usersSubmitted.append(elem.key)
                }
                print(self.usersSubmitted)
                self.loadImages(day: yesterday!)
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImages(day: String){
        DispatchQueue.main.async{
            self.fetchImages(day: day)
        }
    }
    
    func fetchImages(day: String!){
        let storage = FIRStorage.storage().reference()
        
        for item in usersSubmitted {
            let imageRef = storage.child("user_images/\(item)/\(voteWord.text!).JPG")
            imageRef.data(withMaxSize: 1 * 1024 * 1024 * 1024) { (data, error) -> Void in
                if (error == nil) {
                    let image = UIImageView(image: UIImage(data: data!))
                    self.photos.append(VotePhoto(submitterName: item, photoImage: image))
                    self.voteCollection.reloadData()
                }
            }
        }
    }
    
    // ======================================
    // Collection View Delegate/Data Source Functions
    // ======================================
    
    //Set number of cells in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.photos.count != 0) {
            if (self.photos.count == 0) {
                noPhotosMsg.isHidden = false
            } else {
                noPhotosMsg.isHidden = true
            }
            return self.photos.count
        } else {
            noPhotosMsg.isHidden = false
            return 0
        }
    }
    
    //Set number of sections in collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //Fill cells based on index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoVoteCell", for: indexPath) as! VoteCell
        
        let photo: VotePhoto = indexPathPhoto(indexPath: indexPath as NSIndexPath)
        if (photo.submitterName == "") { //error check
            return cell
        }
        cell.voteImageView.image = photo.photoImage.image
        cell.voteImageView = photo.photoImage
        cell.submitterName = photo.submitterName
        return cell
    }
    
    //Selected cell, push cell view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoVoteView = self.storyboard?.instantiateViewController (withIdentifier: "photoVote") as! PhotoVoteController
    
        photoVoteView.photoName = voteWord.text
        photoVoteView.submitterName = indexPathPhoto(indexPath: indexPath as NSIndexPath).submitterName
        photoVoteView.image = indexPathPhoto(indexPath: indexPath as NSIndexPath).photoImage.image
        
        let calendar = Calendar.current
        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: Date())
        let yesterday = oneDayAgo?.description.components(separatedBy: " ")[0]
        photoVoteView.voteDate = yesterday
        photoVoteView.voteWord = voteWord.text
        
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
            return VotePhoto(submitterName: "", photoImage: UIImageView())
        }
    }
    

}

