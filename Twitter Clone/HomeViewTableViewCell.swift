//
//  HomeViewTableViewCell.swift
//  Twitter Clone
//
//  Created by Varun Nath on 24/08/16.
//  Copyright © 2016 UnsureProgrammer. All rights reserved.
//

import UIKit

public class HomeViewTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var tweet: UITextView!
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(profilePic:String?,name:String,handle:String,tweet:String)
    {
        self.tweet.text = tweet
        self.handle.text = "@"+handle
        self.name.text = name
        
        
        if((profilePic) != nil)
        {
            let imageData = NSData(contentsOfURL: NSURL(string:profilePic!)!)
            self.profilePic.image = UIImage(data:imageData!)
        }
        else
        {
            self.profilePic.image = UIImage(named:"twitter")
        }
        
    }
}
