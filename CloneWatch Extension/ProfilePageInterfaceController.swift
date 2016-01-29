//
//  ProfilePageInterfaceController.swift
//  Clone
//
//  Created by Deja Jackson on 11/7/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

import WatchKit
import Foundation


class ProfilePageInterfaceController: WKInterfaceController {

    @IBOutlet var postsInterfaceTable: WKInterfaceTable!
    @IBOutlet var bioInterfaceLabel: WKInterfaceLabel!
    @IBOutlet var realNameInterfaceLabel: WKInterfaceLabel!
    @IBOutlet var usernameInterfaceLabel: WKInterfaceLabel!
    @IBOutlet var profilePicInterfaceImage: WKInterfaceImage!
    
    @IBOutlet var loadingInterfaceLabel: WKInterfaceLabel!
    @IBOutlet var loadingIndicator: WKInterfaceImage!
    
    var postsArray = [PFObject]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if PFUser.currentUser()?.objectForKey("profilepic") != nil {
            let profilePicFile = PFUser.currentUser()?.objectForKey("profilepic")
            profilePicFile?.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                if error == nil {
                    self.profilePicInterfaceImage.setImageData(data)
                } else {
                    let dismiss = WKAlertAction(title: NSLocalizedString("OK", comment: "cancel"), style: WKAlertActionStyle.Cancel, handler: { () -> Void in})
                    self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message: NSLocalizedString("Couldn't load your profile photo", comment: "errordesc"), preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
                }
            })
        } else {
            self.profilePicInterfaceImage.setImageNamed("WatchUser")
        }
        
        self.usernameInterfaceLabel.setText(PFUser.currentUser()?.username)
        self.realNameInterfaceLabel.setText(PFUser.currentUser()?.objectForKey("realname") as? String)
        self.bioInterfaceLabel.setText(PFUser.currentUser()?.objectForKey("bio") as? String)
        
        self.loadingIndicator.setImageNamed("Activity")
        self.loadingIndicator.startAnimatingWithImagesInRange(NSMakeRange(0, 15), duration: 1, repeatCount: 0)
        
        let postsQuery = PFQuery(className: "Posts")
        postsQuery.whereKey("user", equalTo: PFUser.currentUser()!)
        postsQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                self.postsArray = objects!
                self.loadingInterfaceLabel.setHidden(true)
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.setHidden(true)
                self.setupTable()
            } else {
                let dismiss = WKAlertAction(title: NSLocalizedString("OK", comment: "cancel"), style: WKAlertActionStyle.Cancel, handler: { () -> Void in})
                self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message:NSLocalizedString("Couldn't load your posts.", comment: "errordesc"), preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setupTable() {
        self.postsInterfaceTable.setNumberOfRows(self.postsArray.count, withRowType: "post")
        for var i = 0; i < self.postsArray.count; ++i {
            if let feedRow = self.postsInterfaceTable.rowControllerAtIndex(i) as? FeedRowController {
                let postForRow = self.postsArray[i];
                feedRow.usernameInterfaceLabel.setText(PFUser.currentUser()?.username)
                if PFUser.currentUser()?.objectForKey("profilepic") != nil {
                    let profilePicFile = PFUser.currentUser()?.objectForKey("profilepic")
                    profilePicFile?.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                        if error == nil {
                            feedRow.profilePicInterfaceImage.setImageData(data)
                        } else {
                            let dismiss = WKAlertAction(title: NSLocalizedString("OK", comment: "cancel"), style:WKAlertActionStyle.Cancel, handler: { () -> Void in})
                            self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message: NSLocalizedString("Couldn't load profile photos.", comment: "error"), preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
                        }
                    })
                } else {
                    feedRow.profilePicInterfaceImage.setImageNamed("WatchUser")
                }
                if postForRow.objectForKey("content") != nil && postForRow.objectForKey("image") == nil {
                    feedRow.postContentInterfaceLabel.setText(postForRow.objectForKey("content") as? String)
                } else if postForRow.objectForKey("content") == nil && postForRow.objectForKey("image") != nil {
                    feedRow.postContentInterfaceLabel.setText(NSLocalizedString("Tap to view image.", comment: "viewimage"))
                } else if postForRow.objectForKey("content") != nil && postForRow.objectForKey("image") != nil {
                    let postContent = String(format: "%@\rTap to view image.", (postForRow.objectForKey("content") as? String)!)
                    feedRow.postContentInterfaceLabel.setText(NSLocalizedString(postContent, comment: "postcontent"))
                }
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let selectedPost = self.postsArray[rowIndex]
        if selectedPost.objectForKey("image") != nil {
            self.presentControllerWithName("image", context:selectedPost)
        }
    }

}
