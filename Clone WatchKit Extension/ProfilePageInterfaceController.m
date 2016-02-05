//
//  ProfilePageInterfaceController.m
//  
//
//  Created by Deja Jackson on 8/6/15.
//
//

#import "ProfilePageInterfaceController.h"
#import <Parse/Parse.h>

@interface ProfilePageInterfaceController ()

@end

@implementation ProfilePageInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self.usernameInterfaceLabel setText:[[PFUser currentUser] username]];
    if ([[PFUser currentUser] objectForKey:@"realname"]) {
        [self.realNameInterfaceLabel setText:[[PFUser currentUser] objectForKey:@"realname"]];
    }
    if ([[PFUser currentUser] objectForKey:@"bio"]) {
        [self.bioInterfaceLabel setText:[[PFUser currentUser] objectForKey:@"bio"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"profilepic"]) {
        PFFile *profilePicImageFile = [[PFUser currentUser] objectForKey:@"profilepic"];
        [profilePicImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [self.profilePicInterfaceImage setImageData:data];
            } else {
                [self presentControllerWithName:@"error" context:@"Couldn't get profile photo"];
            }
        }];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



