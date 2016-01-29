//
//  OtherProfilePageViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/17/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "OtherProfilePageViewController.h"
#import "KVNProgress.h"
#import "CloneCardCell.h"
#import "CommentsTableViewController.h"
#import "Reachability.h"
#import "PostDetailsViewController.h"
#import "FollowingListTableViewController.h"
#import "TTTTimeIntervalFormatter.h"

@interface OtherProfilePageViewController ()

@end

@implementation OtherProfilePageViewController {
    NSMutableArray *postsArray;
    Reachability *feedReachability;
    UIRefreshControl *postsControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postsTableView.delegate = self;
    self.postsTableView.dataSource = self;
    self.postsTableView.emptyDataSetDelegate = self;
    self.postsTableView.emptyDataSetSource = self;
    self.postsTableView.rowHeight = UITableViewAutomaticDimension;
    self.postsTableView.estimatedRowHeight = 200;
    
    postsControl = [[UIRefreshControl alloc] init];
    postsControl.tintColor = [UIColor whiteColor];
    postsControl.backgroundColor = [UIColor colorWithRed:0.22 green:0.62 blue:0.95 alpha:1];
    
    [self.postsTableView addSubview:postsControl];
    
    self.navigationItem.title = self.userToQuery.username;
    self.profilepicImageView.layer.cornerRadius = self.profilepicImageView.frame.size.width / 2;
    self.profilepicImageView.clipsToBounds = YES;
    PFFile *profilepicFile = [self.userToQuery objectForKey:@"profilepic"];
    if (profilepicFile) {
        [profilepicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.profilepicImageView.image = [UIImage imageWithData:data];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get profile photo", @"error")];
            }
        }];
    } else {
        self.profilepicImageView.image = [UIImage imageNamed:@"User"];
    }
    
    self.profilepicImageView.layer.borderWidth = 3.0f;
    self.profilepicImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.usernameLabel.text = self.userToQuery.username;
    self.realnameLabel.text = self.userToQuery[@"realname"];
    self.bioLabel.text = self.userToQuery[@"bio"];
    
    feedReachability = [Reachability reachabilityForInternetConnection];
    
    if ([self.userToQuery.username isEqualToString:[[PFUser currentUser] username]]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
    [followingQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                for (PFObject *object in objects) {
                    PFUser *followedUser = [object objectForKey:@"to"];
                    if (followedUser == self.userToQuery) {
                        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Unfollow", @"unfollow");
                    }
                }
            }
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
    }];
    
    PFQuery *otherFollowingQuery = [PFQuery queryWithClassName:@"Follows"];
    [otherFollowingQuery whereKey:@"from" equalTo:self.userToQuery];
    [otherFollowingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.numberFollowingLabel.text = [NSString stringWithFormat:@"%lu", objects.count];
            self.followingLabel.text = NSLocalizedString(@"Following", @"following"); 
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
    }];
    
    PFQuery *anotherQuery = [PFQuery queryWithClassName:@"Follows"];
    [anotherQuery whereKey:@"to" equalTo:self.userToQuery];
    [anotherQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count > 0) {
            self.numberFollowersLabel.text = [NSString stringWithFormat:@"%lu", objects.count];
            if (objects.count == 1) {
                self.followersLabel.text = NSLocalizedString(@"Follower", @"follower");
            } else {
                self.followersLabel.text = NSLocalizedString(@"Followers", @"followers");
            }
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
    }];
    
    [self loadData];
}

- (IBAction)chatPressed:(UIBarButtonItem *)sender {
    /*
    MessagesViewController *messagesController = [self.storyboard instantiateViewControllerWithIdentifier:@"messagesview"];
    messagesController.threadRecipient = self.userToQuery;
    messagesController.isNewMessage = YES;
    UINavigationController *messagesNav = [[UINavigationController alloc] initWithRootViewController:messagesController];
    messagesNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    messagesNav.navigationBar.tintColor = [UIColor whiteColor];
    [self presentViewController:messagesNav animated:YES completion:nil];
     */
}

- (IBAction)followPressed:(UIBarButtonItem *)sender {
    if (![self.navigationItem.rightBarButtonItem.title isEqualToString:NSLocalizedString(@"Unfollow", @"unfollow")]) {
        PFObject *followObject = [PFObject objectWithClassName:@"Follows"];
        followObject[@"from"] = [PFUser currentUser];
        followObject[@"to"] = self.userToQuery;
        [followObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't follow user", @"nope")];
                [followObject saveEventually];
            }
            if (succeeded) {
                self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Unfollow", @"unfollow");
                if ([self.userToQuery objectForKey:@"pushfollows"]) {
                    if ([[self.userToQuery objectForKey:@"pushfollows"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                        PFPush *followPush = [[PFPush alloc] init];
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:@"user" equalTo:self.userToQuery];
                        [followPush setQuery:pushQuery];
                        NSString *messageText = [NSString stringWithFormat:@"%@ is now following you.", [[PFUser currentUser] username]];
                        [followPush setData:@{@"alert":NSLocalizedString(messageText, @"message"), @"badge":@"Increment"}];
                        [followPush sendPushInBackground];
                    }
                } else {
                    PFPush *followPush = [[PFPush alloc] init];
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:self.userToQuery];
                    [followPush setQuery:pushQuery];
                    NSString *messageText = [NSString stringWithFormat:@"%@ is now following you.", [[PFUser currentUser] username]];
                    [followPush setData:@{@"alert":NSLocalizedString(messageText, @"message"), @"badge":@"Increment"}];
                    [followPush sendPushInBackground];
                }
            }
        }];
    } else {
        PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
        [followingQuery whereKey:@"to" equalTo:self.userToQuery];
        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *o in objects) {
                    [o deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Follow", @"follow");
                        }
                    }];
                }
            }
        }];
    }
}

- (UIView *)superviewOfType:(Class)superviewClass forView:(UIView *)view {
    if (view.superview != nil) {
        if ([view.superview isKindOfClass:superviewClass]) {
            return view.superview;
        } else {
            return [self superviewOfType:superviewClass forView:view.superview];
        }
    }
    return nil;
}

- (void)messageSent:(SKPSMTPMessage *)message {
    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Thanks for your report", @"thanks")];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't report this post", @"error")];
}

- (IBAction)commentPressed:(UIButton *)sender {
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    CommentsTableViewController *commentsController = [[CommentsTableViewController alloc] init];
    commentsController.postObject = postsArray[[[self.postsTableView indexPathForCell:parentCell] row]];
    [self.navigationController pushViewController:commentsController animated:YES];
}

- (IBAction)followersButtonPressed:(UIButton *)sender {
    FollowingListTableViewController *followingList = [self.storyboard instantiateViewControllerWithIdentifier:@"followinglist"];
    followingList.followingUser = self.userToQuery;
    followingList.displayFollowing = NO;
    [self.navigationController pushViewController:followingList animated:YES];
}

- (IBAction)morePressed:(UIButton *)sender {
    UIAlertController *actions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    PFObject *postForCell = [postsArray objectAtIndex:[[self.postsTableView indexPathForCell:parentCell] row]];
    UIAlertAction *reportPost = [UIAlertAction actionWithTitle:NSLocalizedString(@"Report Post", @"report") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        SKPSMTPMessage *reportPost = [[SKPSMTPMessage alloc] init];
        reportPost.fromEmail = @"bananafudgkins@gmail.com";
        reportPost.toEmail = @"bananafudgkins@gmail.com";
        reportPost.relayHost = @"smtp.gmail.com";
        reportPost.requiresAuth = YES;
        reportPost.login = @"bananafudgkins@gmail.com";
        reportPost.pass = @"Hobbytownusa2";
        reportPost.subject = @"A user has reported a post on Clone.";
        reportPost.wantsSecure = YES;
        reportPost.delegate = self;
        
        NSString *message = [NSString stringWithFormat:@"%@ has reported a post with the objectId of %@ that was composed by %@.", [[PFUser currentUser] username], postForCell.objectId, [[postForCell objectForKey:@"user"] objectForKey:@"username"]];
        NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain", kSKPSMTPPartContentTypeKey, message, kSKPSMTPPartMessageKey, @"8bit", kSKPSMTPPartContentTransferEncodingKey, nil];
        
        reportPost.parts = @[plainPart];
        [reportPost send];
        
        [postForCell saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Thanks for your report", @"thanks")];
            } else if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't report post", @"error")];
            }
        }];
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Post", @"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", @"confirm") message:NSLocalizedString(@"Are you sure you want to delete this post?", @"confirmpls") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *otherdelete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [postForCell deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [postsArray removeObject:postForCell];
                } else {
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't delete post", @"error")];
                    [postForCell deleteEventually];
                }
                if (succeeded) {
                    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
                    [self.postsTableView deleteRowsAtIndexPaths:@[[self.postsTableView indexPathForCell:parentCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"cancel") style:UIAlertActionStyleCancel handler:nil];
        [deleteAlert addAction:otherdelete];
        [deleteAlert addAction:cancel];
        
        [self presentViewController:deleteAlert animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    
    if ([postForCell objectForKey:@"user"] != [PFUser currentUser]) {
        [actions addAction:reportPost];
    }
    if ([[postForCell objectForKey:@"user"] isEqual:[PFUser currentUser]]) {
        [actions addAction:delete];
    }
    [actions addAction:cancel];
    
    [self presentViewController:actions animated:YES completion:nil];
}

// Detect the tap of teh like button and like dat post.
- (IBAction)likePressed:(UIButton *)sender {
    // Get the cell that this button is attactched to.
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    PFObject *post = [postsArray objectAtIndex:[[self.postsTableView indexPathForCell:parentCell] row]];
    NSMutableArray *likedArray = [post objectForKey:@"likedby"];
    if (likedArray && likedArray.count > 0) {
        for (NSString *username in likedArray) {
            if ([username isEqualToString:[[PFUser currentUser] username]]) {
                [likedArray removeObject:[[PFUser currentUser] username]];
                post[@"likedby"] = likedArray;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't unlike post", @"nope")];
                    }
                    if (succeeded) {
                        [parentCell.likeButton setImage:[UIImage imageNamed:@"Like outline"] forState:UIControlStateNormal];
                        if (likedArray.count == 1) {
                            parentCell.likeCountLabel.text = NSLocalizedString(@"1 like", @"like");
                        } else {
                            NSString *likedText = [NSString stringWithFormat:@"%lu likes", likedArray.count];
                            parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"likes");
                        }
                    }
                }];
            } else {
                [likedArray addObject:[[PFUser currentUser] username]];
                post[@"likedby"] = likedArray;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't like post", @"nope")];
                    }
                    if (succeeded) {
                        [parentCell.likeButton setImage:[UIImage imageNamed:@"Like filled"] forState:UIControlStateNormal];
                        if (likedArray.count == 1) {
                            parentCell.likeCountLabel.text = NSLocalizedString(@"1 like", @"like");
                        } else {
                            NSString *likedText = [NSString stringWithFormat:@"%lu likes", likedArray.count];
                            parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"likes");
                        }
                        
                        if ([[post objectForKey:@"user"] objectForKey:@"pushlikes"]) {
                            if ([[[post objectForKey:@"user"] objectForKey:@"pushlikes"] isEqualToNumber:[NSNumber numberWithBool:YES]] && [post objectForKey:@"user"] != [PFUser currentUser]) {
                                PFPush *likePush = [[PFPush alloc] init];
                                PFQuery *pushQuery = [PFInstallation query];
                                [pushQuery whereKey:@"user" equalTo:[post objectForKey:@"user"]];
                                [likePush setQuery:pushQuery];
                                NSString *notificationText = [NSString stringWithFormat:@"%@ liked your post.", [[PFUser currentUser] username]];
                                [likePush setData:@{@"alert":NSLocalizedString(notificationText, @"notification"), @"badge":@"Increment", @"category":@"Like", @"post":post}];
                                [likePush sendPushInBackground];
                            }
                        } else if (![[post objectForKey:@"user"] objectForKey:@"pushlikes"] && [post objectForKey:@"user"] != [PFUser currentUser]) {
                            PFPush *likePush = [[PFPush alloc] init];
                            PFQuery *pushQuery = [PFInstallation query];
                            [pushQuery whereKey:@"user" equalTo:[post objectForKey:@"user"]];
                            [likePush setQuery:pushQuery];
                            NSString *notificationText = [NSString stringWithFormat:@"%@ liked your post.", [[PFUser currentUser] username]];
                            [likePush setData:@{@"alert":NSLocalizedString(notificationText, @"notification"), @"badge":@"Increment", @"category":@"Like", @"post":post}];
                            [likePush sendPushInBackground];
                        }
                    }
                }];
            }
        }
    } else {
        [post addUniqueObject:[[PFUser currentUser] username] forKey:@"likedby"];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't like post", @"error")];
            }
            if (succeeded) {
                [parentCell.likeButton setImage:[UIImage imageNamed:@"Like filled"] forState:UIControlStateNormal];
                parentCell.likeCountLabel.text = NSLocalizedString(@"1 like", @"like");
                
                if ([[post objectForKey:@"user"] objectForKey:@"pushlikes"]) {
                    if ([[[post objectForKey:@"user"] objectForKey:@"pushlikes"] isEqualToNumber:[NSNumber numberWithBool:YES]] && [post objectForKey:@"user"] != [PFUser currentUser]) {
                        PFPush *likePush = [[PFPush alloc] init];
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:@"user" equalTo:[post objectForKey:@"user"]];
                        [likePush setQuery:pushQuery];
                        NSString *notificationText = [NSString stringWithFormat:@"%@ liked your post.", [[PFUser currentUser] username]];
                        [likePush setData:@{@"alert":NSLocalizedString(notificationText, @"notification"), @"badge":@"Increment", @"category":@"Like", @"post":post}];
                        [likePush sendPushInBackground];
                    }
                } else if (![[post objectForKey:@"user"] objectForKey:@"pushlikes"] && [post objectForKey:@"user"] != [PFUser currentUser]) {
                    PFPush *likePush = [[PFPush alloc] init];
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:[post objectForKey:@"user"]];
                    [likePush setQuery:pushQuery];
                    NSString *notificationText = [NSString stringWithFormat:@"%@ liked your post.", [[PFUser currentUser] username]];
                    [likePush setData:@{@"alert":NSLocalizedString(notificationText, @"notification"), @"badge":@"Increment", @"category":@"Like", @"post":post}];
                    [likePush sendPushInBackground];
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    [postsControl beginRefreshing];
    PFQuery *postsQuery = [PFQuery queryWithClassName:@"Posts"];
    [postsQuery whereKey:@"user" equalTo:self.userToQuery];
    [postsQuery orderByDescending:@"createdAt"];
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            postsArray = objects.mutableCopy;
            [postsControl endRefreshing];
            [self.postsTableView reloadData];
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get posts", @"error")];
        }
    }];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Shrug"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20],
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No Posts Yet", @"nope") attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (postsArray.count == 0) {
        return YES;
    } else {
        return NO;
    }
    return nil;
}

- (IBAction)followingTapped:(UIButton *)sender {
    FollowingListTableViewController *followingList = [self.storyboard instantiateViewControllerWithIdentifier:@"followinglist"];
    followingList.followingUser = self.userToQuery;
    followingList.displayFollowing = YES;
    [self.navigationController pushViewController:followingList animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the object at the selected cell's indexPath.
    PFObject *selectedObject = postsArray[indexPath.row];
    
    // Nope I decided to make it so only posts with image can do that. You can now view full posts so it's kind of pointless.
    if ([selectedObject objectForKey:@"image"]) {
        PostDetailsViewController *postDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"postdetails"];
        postDetails.post = selectedObject;
        [self.navigationController pushViewController:postDetails animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return postsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CloneCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFObject *postForCell = postsArray[indexPath.row];
    if ([postForCell objectForKey:@"likedby"]) {
        NSMutableArray *likedBy = [postForCell objectForKey:@"likedby"];
        for (NSString *username in likedBy) {
            if ([username isEqualToString:[[PFUser currentUser] username]]) {
                [cell.likeButton setImage:[UIImage imageNamed:@"Like filled"] forState:UIControlStateNormal];
            }
        }
        if (likedBy.count == 1) {
            cell.likeCountLabel.text = NSLocalizedString(@"1 like", @"2sed3me");
        } else {
            NSString *likedText = [NSString stringWithFormat:@"%lu likes", (unsigned long)likedBy.count];
            cell.likeCountLabel.text = NSLocalizedString(likedText, @"liked");
        }
    } else {
        cell.likeCountLabel.text = NSLocalizedString(@"0 likes", @"nope");
    }
    PFFile *imageFile = [postForCell objectForKey:@"image"];
    if (imageFile) {
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                if (postForCell[@"content"]) {
                    NSString *postContent = [NSString stringWithFormat:@"%@\rTap or press firmly to view image.", postForCell[@"content"]];
                    cell.postContentLabel.text = NSLocalizedString(postContent, @"postcontent");
                } else {
                    cell.postContentLabel.text = NSLocalizedString(@"Tap to view image.", @"tapimage");
                }
            } else if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityUnavailable) {
                if (postForCell[@"content"]) {
                    NSString *postContent = [NSString stringWithFormat:@"%@\rTap to view image.", postForCell[@"content"]];
                    cell.postContentLabel.text = NSLocalizedString(postContent, @"postcontent");
                } else {
                    cell.postContentLabel.text = NSLocalizedString(@"Tap to view image.", @"tapimage");
                }
            }
        } else {
            if (postForCell[@"content"]) {
                NSString *postContent = [NSString stringWithFormat:@"%@\rTap to view image.", postForCell[@"content"]];
                cell.postContentLabel.text = NSLocalizedString(postContent, @"postcontent");
            } else {
                cell.postContentLabel.text = NSLocalizedString(@"Tap to view image.", @"tapimage");
            }
        }
    } else {
        cell.postContentLabel.text = postForCell[@"content"];
    }
    
    TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
    cell.dateLabel.text = [formatter stringForTimeIntervalFromDate:[NSDate date] toDate:postForCell.createdAt];
    
    NetworkStatus status = feedReachability.currentReachabilityStatus;
    if (status == ReachableViaWWAN || status == ReachableViaWiFi) {
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:[[postForCell objectForKey:@"user"] objectId]];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                PFUser *postUser = objects.lastObject;
                cell.usernameLabel.text = postUser.username;
                PFFile *profilePicFile = [postUser objectForKey:@"profilepic"];
                if (profilePicFile) {
                    [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            [cell.profilepicButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                        } else {
                            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get profile photos", @"error")];
                        }
                    }];
                } else {
                    [cell.profilepicButton setBackgroundImage:[UIImage imageNamed:@"User"] forState:UIControlStateNormal];
                }
            }
        }];
    } else if (status == NotReachable) {
        PFQuery *userQuery = [PFUser query];
        [userQuery fromLocalDatastore];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [userQuery whereKey:@"objectId" equalTo:[[postForCell objectForKey:@"user"] objectId]];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        PFUser *postUser = objects.lastObject;
                        cell.usernameLabel.text = postUser.username;
                        PFFile *profilePicFile = [postUser objectForKey:@"profilepic"];
                        if (profilePicFile) {
                            [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                if (!error) {
                                    [cell.profilepicButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
                                } else {
                                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get profile photos", @"error")];
                                }
                            }];
                        } else {
                            [cell.profilepicButton setBackgroundImage:[UIImage imageNamed:@"User"] forState:UIControlStateNormal];
                        }
                    }
                }];
            }
        }];
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
