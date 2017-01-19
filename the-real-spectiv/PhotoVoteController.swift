//
//  PhotoVoteController.swift
//  the-real-spectiv
//
//  Created by Labuser on 11/18/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import Firebase
import UIKit

class PhotoVoteController: UIViewController {
    
    var alreadyVoted = false
    var photoName: String!
    var submitterName: String!
    var image: UIImage!
    var someboolean: Bool = true
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var photoVoteImage: UIImageView!
    
    var voteDate: String!
    var voteWord: String!
    
    //Firebase variables
    let rootRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        photoVoteImage.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Tapped the thumbs up button
    @IBAction func likePhoto(_ sender: Any) {
            let submitterVoteCount = rootRef.child(voteDate).child(voteWord)
        submitterVoteCount.observeSingleEvent(of: .value, with: { snapshot in
                let children = snapshot.children
                for item in children {
                    if ((item as AnyObject).key == self.submitterName) {
                        var val = (item as! FIRDataSnapshot).value as! Int
                        val += 1
                        submitterVoteCount.child((item as AnyObject).key).setValue(val)
                    }
                }
            })
        
        if(alreadyVoted){
            likeBtn.setImage(UIImage(named: "like2.png"), for: .normal)
            alreadyVoted = false
        }
        else{
            likeBtn.setImage(UIImage(named: "like1.png"), for: .normal)
            alreadyVoted = true
        }

    }
}
