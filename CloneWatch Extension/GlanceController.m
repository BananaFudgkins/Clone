//
//  GlanceController.m
//  CloneWatch Extension
//
//  Created by Deja Jackson on 10/26/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

#import "GlanceController.h"
#import "TTTTimeIntervalFormatter.h"

@interface GlanceController()

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Empty the text of all the labels.
    [self.postContentInterfaceLabel setText:@""];
    [self.usernameInterfaceLabel setText:@""];
    [self.dateInterfaceLabel setText:@""];

    // Configure interface objects here.
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        if (session.isReachable == YES) {
            [session sendMessage:[NSDictionary dictionaryWithObject:@"login" forKey:@"message"] replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                if (replyMessage[@"sessiontoken"]) {
                    [self.headerInterfaceLabel setText:NSLocalizedString(@"Logging in...", @"login")];
                    [PFUser becomeInBackground:replyMessage[@"sessiontoken"] block:^(PFUser *user, NSError *error) {
                        if (user) {
                            [self getPost];
                        } else {
                            [self.headerInterfaceLabel setTextColor:[UIColor redColor]];
                            [self.headerInterfaceLabel setText:NSLocalizedString(@"Login Error", @"error")];
                        }
                    }];
                }
            } errorHandler:^(NSError * _Nonnull error) {
                [self.headerInterfaceLabel setTextColor:[UIColor redColor]];
                [self.headerInterfaceLabel setText:NSLocalizedString(@"Login Error", @"error")];
            }];
        } else {
            [self.headerInterfaceLabel setTextColor:[UIColor redColor]];
            [self.headerInterfaceLabel setText:NSLocalizedString(@"Login Error", @"error")];
        }
    } else {
        [self.headerInterfaceLabel setTextColor:[UIColor redColor]];
        [self.headerInterfaceLabel setText:NSLocalizedString(@"Login Error", @"error")];
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

- (void)getPost {
    [self.headerInterfaceLabel setText:NSLocalizedString(@"Getting post...", @"getting")];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
    [followingQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    
    PFQuery *postsFromFollowedQuery = [PFQuery queryWithClassName:@"Posts"];
    [postsFromFollowedQuery whereKey:@"user" matchesKey:@"to" inQuery:followingQuery];
    
    PFQuery *postsFromCurrentUserQuery = [PFQuery queryWithClassName:@"Posts"];
    [postsFromCurrentUserQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    PFQuery *masterQuery = [PFQuery orQueryWithSubqueries:@[postsFromCurrentUserQuery, postsFromFollowedQuery]];
    masterQuery.limit = 1;
    [masterQuery orderByDescending:@"createdAt"];
    [masterQuery includeKey:@"user"];
    [masterQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.headerInterfaceLabel setText:NSLocalizedString(@"Latest Post", @"latestpost")];
            PFObject *foundObject = objects.lastObject;
            [self.postContentInterfaceLabel setText:foundObject[@"content"]];
            [self.usernameInterfaceLabel setText:[[foundObject objectForKey:@"user"] objectForKey:@"username"]];
            TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
            [self.dateInterfaceLabel setText:[formatter stringForTimeIntervalFromDate:[NSDate date]
                                                                               toDate:foundObject.createdAt]];
            if (foundObject[@"image"]) {
                PFFile *postImage = foundObject[@"image"];
                [postImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error)  {
                        [self.postInterfaceImage setImageData:data];
                    }
                }];
            }
        } else {
            [self.headerInterfaceLabel setTextColor:[UIColor redColor]];
            [self.headerInterfaceLabel setText:NSLocalizedString(@"Error getting posts", @"error")];
        }
    }];
}

@end



