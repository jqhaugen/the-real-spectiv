//
//  LoginViewController.swift
//  the-real-spectiv
//
//  Created by Brennan Morell on 11/17/16.
//  Copyright © 2016 Jason Haugen. All rights reserved.
//

import Firebase
import FirebaseAuth
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEmail.delegate = self
        userPassword.delegate = self
        // Do any additional setup after loading the view.
        
        tap.addTarget(self, action: #selector(LoginViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        // set the nav bar back button title to "Log out" instead of just "Back"
        let barButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(getter: UIDynamicBehavior.action))
        
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var errorMsg: UILabel!
    
    let tap = UITapGestureRecognizer()
    
    @IBAction func loginUser(_ sender: Any) {
        authenticateUser(email: userEmail.text!, password: userPassword.text!)
    }
    
    func dismissKeyboard(){
        userEmail.endEditing(true)
        userPassword.endEditing(true)
        tap.isEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tap.isEnabled = true
    }
    
    //Check users database for a match
    func authenticateUser(email: String, password: String){
        FIRAuth.auth()?.signIn(withEmail: userEmail.text!, password: userPassword.text!){ (user, error) in
            if error?.localizedDescription != nil {
                //Display error message
                self.errorMsg.text = "Invalid username or password"
                self.errorMsg.isHidden = false
            }
            else{
                //redirect to the tab view
                //store their information locally to show who is logged in
                self.errorMsg.text = ""
                self.errorMsg.isHidden = true
                self.userPassword.text = ""
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    @IBAction func signupUser(_ sender: Any) {
        //Allow account creation
        //Login user
        //Send user to word-of-the-day page
        FIRAuth.auth()?.createUser(withEmail: userEmail.text!, password: userPassword.text!){ (user, error) in
            if error?.localizedDescription != nil{
                self.errorMsg.text = "Email is invalid or in use"
                self.errorMsg.isHidden = false
            }
            else{
                //redirect to the tab view
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        UserDefaults.standard.set(userEmail.text!, forKey: "currentUserEmail")    }
    
}
