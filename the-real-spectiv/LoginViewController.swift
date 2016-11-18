//
//  LoginViewController.swift
//  the-real-spectiv
//
//  Created by Brennan Morell on 11/17/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    @IBAction func loginUser(_ sender: Any) {
        if authenticateUser(email: userEmail.text!, password: userPassword.text!){
            print("Authentication succeeded")
        }
        else{
            print("Authentication failed")
        }
    }
    
    @IBAction func sendToSignup(_ sender: Any) {
        print("Pushing new view controller")
        
    }
    
    func authenticateUser(email: String, password: String) -> Bool{
        print("Authenticating user")
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
