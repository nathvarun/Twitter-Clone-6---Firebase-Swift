//
//  MeViewController.swift
//
//
//  Created by Varun Nath on 30/08/16.
//
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class MeViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var tweetsContainer: UIView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var likesContainer: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var about: UITextField!
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    
    var loggedInUser = AnyObject?()
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    
    var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEventOfType(.Value) { (snapshot:FIRDataSnapshot) in
            
            self.name.text = snapshot.value!["name"] as? String
            self.handle.text = snapshot.value!["handle"] as? String
            
            //initially the user will not have an about data
            
            if(snapshot.value!["about"] !== nil)
            {
                self.about.text = snapshot.value!["about"] as? String
            }
            
            if(snapshot.value!["profile_pic"] !== nil)
            {
                let databaseProfilePic = snapshot.value!["profile_pic"]
                    as! String
                
                let data = NSData(contentsOfURL: NSURL(string: databaseProfilePic)!)
                
                self.setProfilePicture(self.profilePicture,imageToSet:UIImage(data:data!)!)
            }
            
            self.imageLoader.stopAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLogout(sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let welcomeViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("welcomeViewController")
        
        self.presentViewController(welcomeViewController, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func showComponents(sender: AnyObject) {
        
        if(sender.selectedSegmentIndex == 0)
        {
            UIView.animateWithDuration(0.5, animations: {
                
                self.tweetsContainer.alpha = 1
                self.mediaContainer.alpha = 0
                self.likesContainer.alpha = 0
            })
        }
        else if(sender.selectedSegmentIndex == 1)
        {
            UIView.animateWithDuration(0.5, animations: {
                
                self.mediaContainer.alpha = 1
                self.tweetsContainer.alpha = 0
                self.likesContainer.alpha = 0
                
            })
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: {
                self.likesContainer.alpha = 1
                self.tweetsContainer.alpha = 0
                self.mediaContainer.alpha = 0
            })
        }
    }
    
    
    internal func setProfilePicture(imageView:UIImageView,imageToSet:UIImage)
    {
        imageView.layer.cornerRadius = 10.0
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.masksToBounds = true
        imageView.image = imageToSet
    }
    
    
    @IBAction func didTapProfilePicture(sender: UITapGestureRecognizer) {
        
        //create the action sheet
        
        let myActionSheet = UIAlertController(title:"Profile Picture",message:"Select",preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let viewPicture = UIAlertAction(title: "View Picture", style: UIAlertActionStyle.Default) { (action) in
            
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            
            newImageView.frame = self.view.frame
            
            newImageView.backgroundColor = UIColor.blackColor()
            newImageView.contentMode = .ScaleAspectFit
            newImageView.userInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
            
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
        }
        
        let photoGallery = UIAlertAction(title: "Photos", style: UIAlertActionStyle.Default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.SavedPhotosAlbum)
            {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.presentViewController(self.imagePicker, animated: true
                    , completion: nil)
            }
        }
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.Camera)
            {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imagePicker.allowsEditing = true
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(myActionSheet, animated: true, completion: nil)
        
    }
    
    
    func dismissFullScreenImage(sender:UITapGestureRecognizer)
    {
        //remove the larger image from the view
        sender.view?.removeFromSuperview()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.imageLoader.startAnimating()
        setProfilePicture(self.profilePicture,imageToSet: image)
        
        
        
        if let imageData: NSData = UIImagePNGRepresentation(self.profilePicture.image!)!
        {
            
            let profilePicStorageRef = storageRef.child("user_profiles/\(self.loggedInUser!.uid)/profile_pic")
            
            let uploadTask = profilePicStorageRef.putData(imageData, metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).child("profile_pic").setValue(downloadUrl!.absoluteString)
                }
                else
                {
                    print(error?.localizedDescription)
                }
                
                self.imageLoader.stopAnimating()
            }
        }
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    @IBAction func AboutDidEndEditing(sender: AnyObject) {
        
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).child("about").setValue(self.about.text)
        
    }
    
}
