//
//  SignUpViewController.swift
//  Twitter Clone
//
//  Created by Varun Nath on 06/08/16.
//  Copyright © 2016 UnsureProgrammer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class SignUpViewController: UIViewController {


    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
     @IBOutlet weak var errorMessage: UILabel!
    
    @IBOutlet weak var signUp: UIBarButtonItem!
 
    
    var databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUp.enabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

  
    @IBAction func didTapSignup(sender: AnyObject) {

        //disbable the signUp Button to prevent user from clicking twice
        signUp.enabled = false
        
        FIRAuth.auth()?.createUserWithEmail(email.text!, password: password.text!, completion: { (user, error) in
        
            if(error !== nil)
            {
                if(error!.code == 17999)
                {
                    self.errorMessage.text = "Inavlid email Address"
                }
                else
                {
                    self.errorMessage.text = error?.localizedDescription
                }
            }
            else
            {
                self.errorMessage.text = "Registered Succesfully"
        
                FIRAuth.auth()?.signInWithEmail(self.email.text!, password: self.password.text!, completion: { (user, error) in
        
                    if(error == nil)
                    {
                        self.databaseRef.child("user_profiles").child(user!.uid).child("email").setValue(self.email.text!)
                        
                        self.performSegueWithIdentifier("HandleViewSegue", sender: nil)
                    }
                    
                })
            }
        })
        

    
    }
    @IBAction func textDidChange(sender: UITextField) {
        
        if(email.text!.characters.count>0 && password.text!.characters.count>0)
        {
            signUp.enabled = true
        }
        else
        {
            signUp.enabled = false
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
