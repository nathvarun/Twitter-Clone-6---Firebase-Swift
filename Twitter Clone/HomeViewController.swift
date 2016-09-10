//
//  HomeViewController.swift
//  Twitter Clone
//
//  Created by Varun Nath on 24/08/16.
//  Copyright © 2016 UnsureProgrammer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {

    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser = AnyObject?()
    var loggedInUserData = AnyObject?()
    
    
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var tweets = [AnyObject?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        
        //get the logged in users details
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEventOfType(.Value) { (snapshot:FIRDataSnapshot) in
            
            //store the logged in users details into the variable 
            self.loggedInUserData = snapshot
            print(self.loggedInUserData)
            
            //get all the tweets that are made by the user
            
            self.databaseRef.child("tweets/\(self.loggedInUser!.uid)").observeEventType(.ChildAdded, withBlock: { (snapshot:FIRDataSnapshot) in
              
                
                self.tweets.append(snapshot)
                
                
                self.homeTableView.insertRowsAtIndexPaths([NSIndexPath(forRow:0,inSection:0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                
                self.aivLoading.stopAnimating()
                
            }){(error) in
           
                print(error.localizedDescription)
            }
            
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell: HomeViewTableViewCell = tableView.dequeueReusableCellWithIdentifier("HomeViewTableViewCell", forIndexPath: indexPath) as! HomeViewTableViewCell
        
        
        let tweet = tweets[(self.tweets.count-1) - indexPath.row]!.value["text"] as! String
        
        cell.configure(nil,name:self.loggedInUserData!.value["name"] as! String,handle:self.loggedInUserData!.value["handle"] as! String,tweet:tweet)
        
        
        return cell
    }
    

}
