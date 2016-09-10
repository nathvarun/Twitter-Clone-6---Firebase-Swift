//
//  LoginViewController.swift
//  Twitter Clone
//
//  Created by Varun Nath on 06/08/16.
//  Copyright © 2016 UnsureProgrammer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    
    var rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapCancel(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func didTapLogin(sender: AnyObject) {
        
        FIRAuth.auth()?.signInWithEmail(self.email.text!, password: self.password.text!, completion: { (user, error
            ) in
            
            if(error == nil)
            {
                self.rootRef.child("user_profiles").child((user?.uid)!).child("handle").observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                    
                    if(!snapshot.exists())
                    {
                        //user does not have a handle
                        //send the user to the handleView
                        
                        self.performSegueWithIdentifier("HandleViewSegue", sender: nil)
                    }
                    else
                    {
                        self.performSegueWithIdentifier("HomeViewSegue", sender: nil)
                    }
                })
            }
            else
            {
                self.errorMessage.text = error?.localizedDescription
            }

        })
    
    }
}
