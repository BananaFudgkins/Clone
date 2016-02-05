//
//  ProfilePageViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/13/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "ProfilePageViewController.h"
#import "Reachability.h"
#import "KVNProgress.h"
#import "CloneCardCell.h"
#import <DXTimestampLabel.h>
#import "CommentsTableViewController.h"
#import <MBProgressHUD.h>
#import "PostDetailsViewController.h"

@interface ProfilePageViewController ()

@end

@implementation ProfilePageViewController {
    NSMutableArray *postsArray;
    Reachability *profileReachability;
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
    
    self.navigationItem.title = [[PFUser currentUser] username];
    
    self.refreshView = [[LGRefreshView alloc] initWithScrollView:self.postsTableView delegate:self];
    
    profileReachability = [Reachability reachabilityForInternetConnection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup as soon as the view becomes visible.
    [self loadData];
    
    self.usernameLabel.text = [[PFUser currentUser] username];
    self.profilepicImageView.layer.cornerRadius = self.profilepicImageView.frame.size.width / 2;
    self.profilepicImageView.clipsToBounds = YES;
    
    PFFile *profilepicFile = [[PFUser currentUser] objectForKey:@"profilepic"];
    if (profilepicFile) {
        [profilepicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.profilepicImageView.image = [UIImage imageWithData:data];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get profile photo", @"error")];
            }
        }];
    } else {
        self.profilepicImageView.image = [UIImage imageNamed:@"Shrug"];
    }
    
    self.profilepicImageView.layer.borderWidth = 3.0f;
    self.profilepicImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSString *realName = [[PFUser currentUser] objectForKey:@"realname"];
    if (realName) {
        self.realnameLabel.text = realName;
    } else {
        self.realnameLabel.hidden = YES;
    }
    
    NSString *bio = [[PFUser currentUser] objectForKey:@"bio"];
    if (bio) {
        self.bioTextView.text = bio;
    } else {
        self.bioTextView.hidden = YES;
    }
}

- (void)loadData {
    [self.refreshView triggerAnimated:YES];
    PFQuery *postsQuery = [PFQuery queryWithClassName:@"Posts"];
    [postsQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [postsQuery orderByDescending:@"createdAt"];
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            postsArray = objects.mutableCopy;
            [self.refreshView endRefreshing];
            [self.postsTableView reloadData];
        }
    }];
}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    [self loadData];
}

- (void)messageSent:(SKPSMTPMessage *)message {
    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Thanks for your report", @"thanks")];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't report this post", @"error")];
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

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Shrug"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20],
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No posts yet", @"nope") attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (postsArray.count == 0) {
        self.postsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return YES;
    } else {
        return NO;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return postsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *post = postsArray[indexPath.row];
    if ([post objectForKey:@"image"]) {
        PostDetailsViewController *postDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"postdetails"];
        postDetails.post = post;
        [self.navigationController pushViewController:postDetails animated:YES];
    }
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
    if (imageFile && [postForCell objectForKey:@"content"]) {
        NSString *text = [NSString stringWithFormat:@"%@\rTap to view image.", [postForCell objectForKey:@"content"]];
        cell.postContentLabel.text = NSLocalizedString(text, @"more");
    } else if (imageFile && ![postForCell objectForKey:@"content"]) {
        cell.postContentLabel.text = NSLocalizedString(@"Tap to view image.", @"more");
    } else if (!imageFile && [postForCell objectForKey:@"content"]) {
        NSString *text = [postForCell objectForKey:@"content"];
        cell.postContentLabel.text = NSLocalizedString(text, @"text");
    }
    cell.dateLabel.timestamp = postForCell.createdAt;
    
    NetworkStatus status = profileReachability.currentReachabilityStatus;
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
                MBProgressHUD *deletingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                deletingHUD.mode = MBProgressHUDModeText;
                deletingHUD.labelText = NSLocalizedString(@"Deleting post...", @"deleting");
                if (!error) {
                    [postsArray removeObject:postForCell];
                } else {
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't delete post", @"error")];
                    [postForCell deleteEventually];
                }
                if (succeeded) {
                    [deletingHUD hide:YES];
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

- (IBAction)commentPressed:(UIButton *)sender {
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    CommentsTableViewController *commentsController = [[CommentsTableViewController alloc] init];
    commentsController.postObject = postsArray[[[self.postsTableView indexPathForCell:parentCell] row]];
    [self.navigationController pushViewController:commentsController animated:YES];
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
            }
        }];
    }
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
