//
//  FeedInterfaceController.swift
//  Clone
//
//  Created by Deja Jackson on 11/6/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

import WatchKit
import Foundation


class FeedInterfaceController: WKInterfaceController {
    
    @IBOutlet var loadingIndicator: WKInterfaceImage!
    @IBOutlet var feedInterfaceTable: WKInterfaceTable!
    var postsArray = [PFObject]()
    @IBOutlet var loadingInterfaceLabel: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if PFUser.currentUser() != nil {
            self.loadingIndicator.setImageNamed("Activity")
            self.loadingIndicator.startAnimatingWithImagesInRange(NSMakeRange(0, 15), duration: 1, repeatCount: 0)
            
            let followingQuery = PFQuery(className: "Follows")
            followingQuery.whereKey("from", equalTo: PFUser.currentUser()!)
            
            let postsFromFollowedUsers = PFQuery(className: "Posts")
            postsFromFollowedUsers.whereKey("user", matchesKey: "to", inQuery: followingQuery)
            
            let postsFromCurrentUser = PFQuery(className: "Posts")
            postsFromCurrentUser.whereKey("user", equalTo: PFUser.currentUser()!)
            
            let postsQuery = PFQuery.orQueryWithSubqueries([postsFromCurrentUser, postsFromFollowedUsers])
            postsQuery.includeKey("user")
            postsQuery.orderByDescending("createdAt")
            postsQuery.cachePolicy = PFCachePolicy.NetworkOnly
            postsQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    self.postsArray = objects!
                    self.loadingInterfaceLabel.setHidden(true)
                    self.setupTable()
                } else {
                    let dismiss = WKAlertAction(title: "OK", style: WKAlertActionStyle.Cancel, handler: { () -> Void in})
                    self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message: error?.localizedDescription, preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
                }
                if self.postsArray.count == 0 {
                    postsQuery.cachePolicy = PFCachePolicy.CacheThenNetwork
                }
            }
        }
    }
    
    @IBAction func composePressed() {
        self.presentTextInputControllerWithSuggestions(nil, allowedInputMode: WKTextInputMode.AllowEmoji) { (results:[AnyObject]?) -> Void in
            if results != nil && results?.count > 0 {
                let postObject = PFObject(className: "Posts")
                postObject["user"] = PFUser.currentUser()
                postObject["content"] = results![0]
                postObject.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    self.dismissTextInputController()
                     if error != nil {
                        let dismiss = WKAlertAction(title: NSLocalizedString("OK", comment: "error"), style: WKAlertActionStyle.Cancel, handler: { () -> Void in})
                        self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message: error?.userInfo["error"] as? String, preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
                    }
                    if succeeded == true {
                        self.feedInterfaceTable.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "post")
                        let newRow : FeedRowController = self.feedInterfaceTable.rowControllerAtIndex(0) as! FeedRowController
                        newRow.postContentInterfaceLabel.setText(postObject["content"] as? String)
                        newRow.usernameInterfaceLabel.setText(PFUser.currentUser()?.username)
                        if PFUser.currentUser()?.objectForKey("profilepic") != nil {
                            let profilePicFile = PFUser.currentUser()?.objectForKey("profilepic")
                            profilePicFile?.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                                if error == nil {
                                    newRow.profilePicInterfaceImage.setImageData(data)
                                } else {
                                    let dismiss = WKAlertAction(title: NSLocalizedString("OK", comment: "cancel"), style: WKAlertActionStyle.Cancel, handler: { () -> Void in})
                                    self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message: error?.userInfo["error"] as? String, preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
                                }
                            })
                        } else {
                            newRow.profilePicInterfaceImage.setImageNamed("WatchUser")
                        }
                        self.feedInterfaceTable.scrollToRowAtIndex(0)
                    }
                })
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
        self.feedInterfaceTable.setNumberOfRows(self.postsArray.count, withRowType: "post")
        for var i = 0; i < self.postsArray.count; ++i {
            if let feedRow = self.feedInterfaceTable.rowControllerAtIndex(i) as? FeedRowController {
                let postForRow = self.postsArray[i] 
                let postUser = postForRow.objectForKey("user") as! PFUser
                if postUser.objectForKey("profilepic") != nil {
                    let profilePicFile = postUser.objectForKey("profilepic")
                    profilePicFile?.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                        if error == nil {
                            feedRow.profilePicInterfaceImage.setImageData(data)
                        } else {
                            let dismiss = WKAlertAction(title: NSLocalizedString("OK", comment: "cancel"), style: WKAlertActionStyle.Cancel, handler: { () -> Void in})
                            self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message:NSLocalizedString("Couldn't load profile photos.", comment: "errordesc"), preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
                        }
                    })
                } else {
                    feedRow.profilePicInterfaceImage.setImageNamed("WatchUser")
                }
                feedRow.usernameInterfaceLabel.setText(postUser.username)
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
        let selectedObject = self.postsArray[rowIndex]
        if selectedObject.objectForKey("image") != nil {
            self.presentControllerWithName("image", context: selectedObject)
        }
    }

}
