//
//  FollowingViewController.swift
//  the-real-spectiv
//
//  Created by Jason Haugen on 11/17/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit
import Firebase

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Variables
    var following: [String] = []
    var userEmail: String?
    
    //Firebase variables
    let rootRef = FIRDatabase.database().reference()
    
    // ======================================
    // Basic Functions
    // ======================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.reloadData()
        tableView.delegate = self
        tableView.dataSource = self
        
        userEmail = UserDefaults.standard.object(forKey: "currentUserEmail") as! String!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        following.removeAll()
        rootRef.child("Follow").child(emailToFolder(email: userEmail!)).observeSingleEvent(of: .value, with: { snapshot in
            for item in snapshot.children {
                self.following.append((item as AnyObject).key)
            }
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ======================================
    // Table View Functions
    // ======================================
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Look up logged in user in database
        //Return number of followers
        return following.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let followCell = tableView.dequeueReusableCell(withIdentifier: "followCell")! as UITableViewCell
        followCell.textLabel!.text = indexPathFollow(indexPath: indexPath as NSIndexPath)
        return followCell
    }
    
    //Get follower name at index path
    func indexPathFollow(indexPath: NSIndexPath) -> String {
        if (following.count != 0) {
            return following[indexPath.row]
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileView = self.storyboard?.instantiateViewController(withIdentifier: "userProfileView") as! ProfileViewController
        
        let otherUser = indexPathFollow(indexPath: indexPath as NSIndexPath)
        profileView.otherUserEmail = emailToFolder(email: otherUser)
        
        self.navigationController?.pushViewController(profileView, animated: true)

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
