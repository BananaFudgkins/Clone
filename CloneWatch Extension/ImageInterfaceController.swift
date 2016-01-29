//
//  ImageInterfaceController.swift
//  Clone
//
//  Created by Deja Jackson on 11/7/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

import WatchKit
import Foundation


class ImageInterfaceController: WKInterfaceController {

    @IBOutlet var loadingInterfaceLabel: WKInterfaceLabel!
    @IBOutlet var postInterfaceImage: WKInterfaceImage!
    @IBOutlet var loadingIndicator: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let imagePost = context as! PFObject
        if imagePost.objectForKey("image") != nil {
            self.loadingIndicator.setImageNamed("Activity")
            self.loadingIndicator.startAnimatingWithImagesInRange(NSMakeRange(0, 15), duration: 1, repeatCount: 0)
            let postImage = imagePost.objectForKey("image")
            postImage?.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                if error == nil {
                    self.loadingInterfaceLabel.setHidden(true)
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.setHidden(true)
                    self.postInterfaceImage.setImageData(data)
                } else {
                    let dismiss = WKAlertAction(title: NSLocalizedString("OK", comment: "cancel"), style: WKAlertActionStyle.Cancel, handler: { () -> Void in})
                    self.presentAlertControllerWithTitle(NSLocalizedString("Error", comment: "error"), message: NSLocalizedString("Couldn't load image.", comment: "error"), preferredStyle: WKAlertControllerStyle.Alert, actions: [dismiss])
                }
            })
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

}
