//
//  HomeTableViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/11/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "HomeTableViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "Reachability.h"
#import "CloneCardCell.h"
#import "KVNProgress.h"
#import "OtherProfilePageViewController.h"
#import "PostDetailsViewController.h"
#import "CommentsTableViewController.h"
#import "MBProgressHUD.h"
#import "Clone-Swift.h"
#import "TTTTimeIntervalFormatter.h"
#import "JTSImageViewController.h"
#import "ProfilePageViewController.h"

@interface HomeTableViewController()

@end

@implementation HomeTableViewController {
    NSMutableArray *postsArray;
    
    Reachability *feedReachability;
    
    BOOL isLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"Navbar logo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(navbarTapped:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.adjustsImageWhenHighlighted = NO;
    UIImage *buttonImage = [UIImage imageNamed:@"Navbar logo"];
    titleButton.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    self.navigationItem.titleView = titleButton;
    feedReachability = [Reachability reachabilityForInternetConnection];
    [feedReachability startNotifier];
    self.tableView.separatorColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.22 green:0.62 blue:0.95 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(loadFeed) forControlEvents:UIControlEventValueChanged];
    
    CGFloat rotationAngleDegress = -15;
    CGFloat rotationAngleRadians = rotationAngleDegress * (M_PI / 180);
    CGPoint offsetPositioning = CGPointMake(-20, -20);
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    _initialTransform = transform;
    
    _shownIndexes = [NSMutableSet set];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidCommentOnPost:)
                                                 name:@"usercommented"
                                               object:nil];
    
    postsArray = [NSMutableArray array];
    
    self.tableView.estimatedRowHeight = 340;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    }
    
    isLoading = YES;
    
}

- (void)reachabilityStatusChanged:(NSNotification *)notification {
    NetworkStatus status = feedReachability.currentReachabilityStatus;
    if (status == ReachableViaWWAN || status == ReachableViaWiFi) {
        [self loadFeed];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup as soon as the view becomes visible.
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    if (![PFUser currentUser]) {
        [self presentLoginController];  
    } else {
        if (postsArray.count == 0) {
            [self loadFeed];
        }
        if (![[PFInstallation currentInstallation] objectForKey:@"user"]) {
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            currentInstallation[@"user"] = [PFUser currentUser];
            [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [currentInstallation saveEventually];
                }
            }];
        }
    }
    
    if (![[[PFUser currentUser] objectForKey:@"following"] containsObject:[PFUser currentUser]]) {
        [[PFUser currentUser] addObject:[PFUser currentUser] forKey:@"following"];
        [[PFUser currentUser] saveInBackground];
    }
}

- (void)loadFeed {
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -130) animated:YES];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
    [followingQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    
    PFQuery *postsFromFollowedUsers = [PFQuery queryWithClassName:@"Posts"];
    [postsFromFollowedUsers whereKey:@"user" matchesKey:@"to" inQuery:followingQuery];
    
    PFQuery *postsFromCurrentUser = [PFQuery queryWithClassName:@"Posts"];
    [postsFromCurrentUser whereKey:@"user" equalTo:[PFUser currentUser]];
    
    PFQuery *postsQuery = [PFQuery orQueryWithSubqueries:@[postsFromCurrentUser, postsFromFollowedUsers]];
    [postsQuery includeKey:@"user"];
    [postsQuery orderByDescending:@"createdAt"];
    [postsQuery setCachePolicy:kPFCachePolicyNetworkOnly];
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            postsArray = objects.mutableCopy;
            isLoading = NO;
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        } else {
            [self.refreshControl endRefreshing];
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
        
        if (postsArray.count == 0 || feedReachability.currentReachabilityStatus == NotReachable) {
            [postsQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)userDidCommentOnPost:(NSNotification *)note {
    self.commentObject = note.object;
    self.notification = [[AFDropdownNotification alloc] init];
    self.notification.notificationDelegate = self;
    self.notification.image = [UIImage imageNamed:@"Comment"];
    NSString *commentNotifString = [NSString stringWithFormat:@"%@ commented on your post:", self.commentObject[@"user"]];
    self.notification.titleText = NSLocalizedString(commentNotifString, @"commentnotif");
    self.notification.subtitleText = self.commentObject[@"content"];
    self.notification.topButtonText = NSLocalizedString(@"View comment", @"viewcomment");
    self.notification.bottomButtonText = NSLocalizedString(@"Dismiss", @"dismiss");
    self.notification.dismissOnTap = YES;
    
    [self.notification presentInView:self.tableView withGravityAnimation:YES];
    
    [self.notification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
        switch (event) {
            case AFDropdownNotificationEventTopButton:
                // Listen for the top button being tapped.
                break;
            case AFDropdownNotificationEventBottomButton:
                // Listen for the bottom button being tapped.
                break;
            case AFDropdownNotificationEventTap:
                // Listen for the notification being tapped.
                break;
                
            default:
                break;
        }
    }];
}

- (void)dropdownNotificationTopButtonTapped {
    CommentsTableViewController *comments = [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
    comments.postObject = self.commentObject;
    [self.navigationController pushViewController:comments animated:YES];
    [self.notification dismissWithGravityAnimation:YES];
}

- (void)dropdownNotificationBottomButtonTapped {
    [self.notification dismissWithGravityAnimation:YES];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    
    NetworkStatus status = feedReachability.currentReachabilityStatus;
    
    if (status == NotReachable) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No internet connection", @"title") attributes:attributes];
    }
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Not following anyone", @"nope") attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:18],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    NetworkStatus status = feedReachability.currentReachabilityStatus;
    
    if (status == NotReachable) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"You're currently offline so you can't view your feed. Please connect to the internet and try again.", @"description") attributes:attributes];
    }
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"You aren't following anyone yet. You can go to the search tab to search for users to follow. If your feed hasn't loaded correctly, pull down to refresh your feed. You might also be seeing this because your feed is loading.", @"followthem") attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Shrug"];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (isLoading == NO && postsArray.count == 0) {
        return YES;
    }
    return NO;
}

- (void)showPostErrorMessage:(PFObject *)post {
    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save post", @"error")];
    [post saveEventually];
}

- (void)postDidSave:(PFObject *)post {
    [self.tableView beginUpdates];
    [postsArray insertObject:post atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView endUpdates];
}

- (void)presentLoginController {
    // Present the login interface if the user is not logged in.
    LoginViewController *loginController = [[LoginViewController alloc] init];
    SignUpViewController *signUpController = [[SignUpViewController alloc] init];
    loginController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsPasswordForgotten | PFLogInFieldsLogInButton | PFLogInFieldsFacebook | PFLogInFieldsTwitter | PFLogInFieldsSignUpButton;
    loginController.signUpController = signUpController;
    loginController.delegate = self;
    signUpController.delegate = self;
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)messageSent:(SKPSMTPMessage *)message {
    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Thanks for your report", @"thnxbruh")];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't report post", @"whyyounosend")];
}

- (IBAction)navbarTapped:(UIButton *)sender {
    [self.tableView setContentOffset:CGPointMake(0, 0 - self.tableView.contentInset.top) animated:YES];
}

- (IBAction)profilePicTapped:(UIButton *)sender {
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    PFObject *post = [postsArray objectAtIndex:[self.tableView indexPathForCell:parentCell].row];
    if ([[[post objectForKey:@"user"] objectForKey:@"username"] isEqualToString:[[PFUser currentUser] username]]) {
        ProfilePageViewController *profilePage = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
        [self.navigationController pushViewController:profilePage animated:YES];
    } else {
        OtherProfilePageViewController *otherProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"otheruser"];
        otherProfile.userToQuery = post[@"user"];
        [self.navigationController pushViewController:otherProfile animated:YES];
    }
}

- (IBAction)morePressed:(UIButton *)sender {
    UIAlertController *actions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    PFObject *postForCell = [postsArray objectAtIndex:[[self.tableView indexPathForCell:parentCell] row]];
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
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Post", @"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", @"confirm") message:NSLocalizedString(@"Are you sure you want to delete this post?", @"confirmpls") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *otherdelete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [postForCell deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                MBProgressHUD *deletingHUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
                deletingHUD.mode = MBProgressHUDModeText;
                deletingHUD.labelText = NSLocalizedString(@"Deleting post...", @"deleting");
                if (!error) {
                    [postsArray removeObject:postForCell];
                } else {
                    [deletingHUD hide:YES];
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't delete post", @"error")];
                    [postForCell deleteEventually];
                }
                if (succeeded) {
                    [deletingHUD hide:YES];
                    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
                    [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:parentCell]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"cancel") style:UIAlertActionStyleCancel handler:nil];
        [deleteAlert addAction:otherdelete];
        [deleteAlert addAction:cancel];
        
        [self presentViewController:deleteAlert animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    [actions addAction:cancel];
    if ([[postForCell objectForKey:@"user"] objectForKey:@"username"] == [PFUser currentUser].username) {
        [actions addAction:delete];
    } else {
        [actions addAction:reportPost];
    }
    [actions setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = actions.popoverPresentationController;
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
    
    [self presentViewController:actions animated:YES completion:nil];
}

// Detect the tap of teh like button and like dat post.
- (IBAction)likePressed:(UIButton *)sender {
    // Get the cell that this button is attactched to.
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    PFObject *post = [postsArray objectAtIndex:[[self.tableView indexPathForCell:parentCell] row]];
    NSMutableArray *likedArray = [post objectForKey:@"likedby"];
    if (likedArray && likedArray.count > 0) {
        for (NSString *username in likedArray) {
            if ([username isEqualToString:[[PFUser currentUser] username]]) {
                [likedArray removeObject:[[PFUser currentUser] username]];
                post[@"likedby"] = likedArray;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
                    }
                    if (succeeded) {
                        [parentCell.likeButton setBackgroundImage:[UIImage imageNamed:@"Like outline"] forState:UIControlStateNormal];
                        if (likedArray.count == 1) {
                            parentCell.likeCountLabel.text = NSLocalizedString(@"1 like", @"2sed3me");
                        } else if (likedArray.count > 1) {
                            if(likedArray.count % 1000 == 0) {
                                // Check if the amount of likes are divisble by 1,000.
                                NSString *likedText = [NSString stringWithFormat:@"%lu%@ %@", likedArray.count / 1000, @"k", @"likes"];
                                parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"liked");
                            } else if (likedArray.count % 1000000 == 0) {
                                // Check if the amount of likes are divisible by 1,000,000.
                                NSString *likedText = [NSString stringWithFormat:@"%lu%@ %@", likedArray.count / 1000000, @"m", @"likes"];
                                parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"liked");
                            } else if (likedArray.count % 1000000000 == 0) {
                                // Check if the amount of likes are divisble by 1,000,000,000. Yeah that's a fuck ton of likes but just to be safe.
                                NSString *likedText = [NSString stringWithFormat:@"%lu%@ %@", likedArray.count / 1000000000, @"b", @"likes"];
                                parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"liked");
                            }
                        } else if (likedArray.count == 0) {
                            parentCell.likeCountLabel.text = NSLocalizedString(@"0 likes", @"foreveralone");
                        }
                    }
                }];
            } else {
                [likedArray addObject:[[PFUser currentUser] username]];
                post[@"likedby"] = likedArray;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
                    }
                    if (succeeded) {
                        [parentCell.likeButton setBackgroundImage:[UIImage imageNamed:@"Like filled"] forState:UIControlStateNormal];
                        if (likedArray.count == 1) {
                            parentCell.likeCountLabel.text = NSLocalizedString(@"1 like", @"2sed3me");
                        } else if (likedArray.count > 1) {
                            if(likedArray.count % 1000 == 0) {
                                // Check if the amount of likes are divisble by 1,000.
                                NSString *likedText = [NSString stringWithFormat:@"%lu%@ %@", likedArray.count / 1000, @"k", @"likes"];
                                parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"liked");
                            } else if (likedArray.count % 1000000 == 0) {
                                // Check if the amount of likes are divisible by 1,000,000.
                                NSString *likedText = [NSString stringWithFormat:@"%lu%@ %@", likedArray.count / 1000000, @"m", @"likes"];
                                parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"liked");
                            } else if (likedArray.count % 1000000000 == 0) {
                                // Check if the amount of likes are divisble by 1,000,000,000. Yeah that's a fuck ton of likes but just to be safe.
                                NSString *likedText = [NSString stringWithFormat:@"%lu%@ %@", likedArray.count / 1000000000, @"b", @"likes"];
                                parentCell.likeCountLabel.text = NSLocalizedString(likedText, @"liked");
                            }
                        } else if (likedArray.count == 0) {
                            parentCell.likeCountLabel.text = NSLocalizedString(@"0 likes", @"foreveralone");
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
                [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
            }
            if (succeeded) {
                [parentCell.likeButton setBackgroundImage:[UIImage imageNamed:@"Like filled"] forState:UIControlStateNormal];
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

#pragma mark - 3D Touch

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.presentedViewController isKindOfClass:[PostDetailsViewController class]]) {
        return nil;
    }
    
    CGPoint cellPosition = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *selectedPath = [self.tableView indexPathForRowAtPoint:cellPosition];
    
    if (selectedPath) {
        CloneCardCell *selectedCell = [self.tableView cellForRowAtIndexPath:selectedPath];
        
        PostDetailsViewController *postDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"postdetails"];
        postDetails.post = postsArray[selectedPath.row];
        
        [previewingContext setSourceRect:[self.view convertRect:selectedCell.frame fromView:self.tableView]];
        return postDetails;
    }
    
    return nil;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            if (!self.previewingContext) {
                self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
            }
        } else {
            if (self.previewingContext) {
                [self unregisterForPreviewingWithContext:self.previewingContext];
                self.previewingContext = nil;
            }
        }
    }
}

#pragma mark - Login and sign up delegate

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"user"] = user;
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't log you in", @"error")];
        }
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    user[@"following"] = [NSMutableArray arrayWithObject:user];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (error) {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't sign you up", @"error")];
        }
    }];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    NSString *username = [info objectForKey:@"username"];
    return ([username rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound);
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    return ([username rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound);
}

#pragma mark - View stuff

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/* - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return postsArray.count;
} */

/* - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.shownIndexes containsObject:indexPath]) {
        [self.shownIndexes addObject:indexPath];
        
        UIView *cardView = [(CloneCardCell *)cell cardView];
        cardView.layer.transform = self.initialTransform;
        cardView.layer.opacity = 0;
        
        [UIView animateWithDuration:0.4 animations:^{
            cardView.layer.transform = CATransform3DIdentity;
            cardView.layer.opacity = 1;
        }];
    }
} */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CloneCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
    PFObject *postForCell = postsArray[indexPath.row];
    if ([postForCell objectForKey:@"likedby"]) {
        NSMutableArray *likedBy = [postForCell objectForKey:@"likedby"];
        for (NSString *username in postForCell[@"likedby"]) {
            if ([[[PFUser currentUser] username] isEqualToString:username]) {
                [cell.likeButton setImage:[UIImage imageNamed:@"Like filled"] forState:UIControlStateNormal];
            }
        }
        if (likedBy.count > 1) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *numberString = [numberFormatter stringFromNumber:@(likedBy.count)];
            cell.likeCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ likes", @"likecount"), numberString];
        } else if (likedBy.count == 1) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *numberString = [numberFormatter stringFromNumber:@(1)];
            cell.likeCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ like", @"like"), numberString];
        } else if (likedBy.count == 0) {
            cell.likeCountLabel.text = NSLocalizedString(@"0 likes", @"nolikes");
        }
    } else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSString *numberString = [formatter stringFromNumber:@(0)];
        cell.likeCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ likes", @"nolikes"), numberString];
    }
    
    if ([postForCell objectForKey:@"image"]) {
        PFFile *postImageFile = [postForCell objectForKey:@"image"];
        [postImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                cell.postImageView.image = [UIImage imageWithData:data];
                cell.postImageView.alpha = 1;
                cell.postImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *imageRecogizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImageViewTapped:)];
                imageRecogizer.numberOfTapsRequired = 1;
                imageRecogizer.numberOfTouchesRequired = 1;
                [cell.postImageView addGestureRecognizer:imageRecogizer];
            } else {
                [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
            }
        }];
    }
    
    if ([[postForCell objectForKey:@"user"] objectForKey:@"profilepic"]) {
        PFFile *profilePicFile = [[postForCell objectForKey:@"user"] objectForKey:@"profilepic"];
        [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [cell.profilepicButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            } else {
                [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
            }
        }];
    }
    
    TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
    cell.dateLabel.text = [formatter stringForTimeIntervalFromDate:[NSDate date] toDate:postForCell.createdAt];
    cell.usernameLabel.text = [[postForCell objectForKey:@"user"] objectForKey:@"username"];
    cell.postContentLabel.text = postForCell[@"content"];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    return cell;
}

- (IBAction)postImageViewTapped:(UITapGestureRecognizer *)sender {
    CGPoint cellPosition = [self.tableView convertPoint:[sender locationInView:self.tableView] fromView:self.tableView];
    CloneCardCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:cellPosition]];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = selectedCell.postImageView.image;
    imageInfo.referenceRect = sender.view.frame;
    imageInfo.referenceView = sender.view;
    
    JTSImageViewController *postImageView = [[JTSImageViewController alloc]
                                             initWithImageInfo:imageInfo
                                             mode:JTSImageViewControllerMode_Image
                                             backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    [postImageView showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"comments"]) {
        CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
        PFObject *selectedPost = postsArray[[self.tableView indexPathForCell:parentCell].row];
        CommentsTableViewController *commentsController = segue.destinationViewController;
        commentsController.postObject = selectedPost;
    }
}

- (void)dealloc {
    self.tableView.emptyDataSetDelegate = nil;
    self.tableView.emptyDataSetSource = nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
