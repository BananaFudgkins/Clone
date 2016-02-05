//
//  InterfaceController.m
//  Clone WatchKit Extension
//
//  Created by Deja Jackson on 8/6/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "InterfaceController.h"
#import "WKInterfaceTable+IGInterfaceDataTable.h"
#import "FeedRowController.h"
#import <Parse/Parse.h>

@interface InterfaceController() <IGInterfaceTableDataSource>

@end


@implementation InterfaceController {
    NSMutableArray *postsArray;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    self.feedInterfaceTable.ig_dataSource = self;
    
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.pixelbypixel.Clone"
                                     containingApplication:@"com.pixelbypixel.Clone"];
    [Parse enableLocalDatastore];
    
    [Parse setApplicationId:@"zXsU51Bh1AwneejkVIYUMRZzI0MQXIJLy1IM0LOh"
                  clientKey:@"hvDPq4a89vLnKYwkZLBMytS3M2R8qsLiOFpxFC3L"];
    
    if ([PFUser currentUser]) {
        [self loadData];
    } else {
        [self presentControllerWithName:@"loggedout" context:nil];
    }
    
    postsArray = [NSMutableArray array];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadData {
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
    [followingQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    followingQuery.limit = 15;
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                
                PFQuery *postsQuery = [PFQuery queryWithClassName:@"Posts"];
                [postsQuery orderByDescending:@"createdAt"];
                postsQuery.limit = 15;
                [postsQuery whereKey:@"user" matchesKey:@"to" inQuery:followingQuery];
                [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        [postsArray addObjectsFromArray:objects];
                    } else {
                        [self presentControllerWithName:@"error" context:@"Couldn't refresh feed"];
                    }
                }];
                
                PFQuery *currentUserQuery = [PFQuery queryWithClassName:@"Posts"];
                [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser]];
                [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        [postsArray addObjectsFromArray:objects];
                        [self.feedInterfaceTable reloadData];
                    } else {
                        [self presentControllerWithName:@"error" context:@"Couldn't refresh feed"];
                    }
                }];
            }
        } else {
            [self presentControllerWithName:@"error" context:@"Couldn't refresh feed"];
        }
    }];
    
    if (postsArray.count > 0) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
        [postsArray sortUsingDescriptors:@[sortDescriptor]];
    }
}

- (IBAction)composePressed {
    [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModeAllowEmoji completion:^(NSArray *results) {
        if (results && results.count > 0) {
            [self dismissTextInputController];
            PFObject *post = [PFObject objectWithClassName:@"Posts"];
            post[@"user"] = [PFUser currentUser];
            post[@"content"] = results[0];
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [self presentControllerWithName:@"error" context:@"Couldn't save post"];
                    [post saveEventually];
                }
            }];
        }
    }];
}

- (NSInteger)numberOfRowsInTable:(WKInterfaceTable *)table section:(NSInteger)section {
    return postsArray.count;
}

- (NSString *)table:(WKInterfaceTable *)table rowIdentifierAtIndexPath:(NSIndexPath *)indexPath {
    return @"post";
}

- (void)table:(WKInterfaceTable *)table configureRowController:(NSObject *)rowController forIndexPath:(NSIndexPath *)indexPath {
    FeedRowController *feedRowController = (FeedRowController *)rowController;
    PFObject *post = postsArray[indexPath.row];
    if ([post objectForKey:@"content"]) {
        [feedRowController.postContentInterfaceLabel setText:[post objectForKey:@"content"]];
    }
    if ([post objectForKey:@"image"] && [post objectForKey:@"content"]) {
        NSString *postFormatted = [NSString stringWithFormat:@"%@\rTap to view image.", [post objectForKey:@"content"]];
        [feedRowController.postContentInterfaceLabel setText:postFormatted];
    } else if ([post objectForKey:@"image"] && ![post objectForKey:@"content"]) {
        [feedRowController.postContentInterfaceLabel setText:NSLocalizedString(@"Tap to view image.", @"tap")];
    }
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:[[post objectForKey:@"user"] objectId]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *postUser = objects.lastObject;
            [feedRowController.usernameInterfaceLabel setText:postUser.username];
            if ([postUser objectForKey:@"profilepic"]) {
                PFFile *profilePicFile = [postUser objectForKey:@"profilepic"];
                [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        [feedRowController.profilePicInterfaceImage setImageData:data];
                    } else {
                        [self presentControllerWithName:@"error" context:@"Couldn't get profile photos"];
                    }
                }];
            }
        } else {
            [self presentControllerWithName:@"error" context:@"Couldn't get user info"];
        }
    }];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    PFObject *selectedPost = postsArray[rowIndex];
    if ([selectedPost objectForKey:@"image"]) {
        PFFile *imageFile = [selectedPost objectForKey:@"image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [self presentControllerWithName:@"image" context:data];
            } else {
                [self presentControllerWithName:@"error" context:@"Couldn't load image"];
            }
        }];
    }
}

@end



