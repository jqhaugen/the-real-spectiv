//
//  PhotoVoteController.swift
//  the-real-spectiv
//
//  Created by Labuser on 11/18/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import Firebase
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImage: UIImageView!
    var temp: VotePhoto!
    var submitterName: String!
    var image: UIImage!
    var photoName: String!
    var userEmail: String!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var photoNameLabel: UILabel!
    
    let rootRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        detailImage?.image = image
        photoNameLabel.text = photoName
        
        userEmail = UserDefaults.standard.object(forKey: "currentUserEmail") as! String!
        
        //Check if user of submitted picture is currently being follow
        rootRef.child("Follow").child(emailToFolder(email: userEmail)).observe(.value, with: {snapshot in
            if (snapshot.hasChild(self.submitterName)) {
                self.followButton.setTitle("Unfollow", for: .normal)
            } else {
                self.followButton.setTitle("Follow", for: .normal)
            }
        })
        
        if(emailToFolder(email: userEmail) == submitterName){
            followButton.isHidden = true
        }
        else{
            followButton.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onFollowPress(_ sender: Any) {
        //If not following, then follow and append to database
        //Otherwise, unfollow and remove from database
        if (self.followButton.currentTitle == "Follow") {
            rootRef.child("Follow").child(emailToFolder(email: userEmail)).updateChildValues(([emailToFolder(email: submitterName): "0"]))
        } else {
            rootRef.child("Follow").child(emailToFolder(email: userEmail)).child(submitterName).removeValue()
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
