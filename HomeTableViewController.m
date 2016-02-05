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
#import "OnboardingViewController.h"
#import "OnboardingContentViewController.h"
#import "OtherProfilePageViewController.h"
#import "PostDetailsViewController.h"
#import "PSCoachMark.h"
#import "CommentsTableViewController.h"
#import <DXTimestampLabel.h>
#import <MBProgressHUD.h>
#import "Clone_Dist-Swift.h"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController {
    NSMutableArray *postsArray;
    Reachability *feedReachability;
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
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat rotationAngleDegress = -15;
    CGFloat rotationAngleRadians = rotationAngleDegress * (M_PI / 180);
    CGPoint offsetPositioning = CGPointMake(-20, -20);
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    _initialTransform = transform;
    
    _shownIndexes = [NSMutableSet set];
    
    self.refreshView = [[LGRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    
    postsArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
}

- (void)reachabilityStatusChanged:(NSNotification *)notification {
    NetworkStatus status = feedReachability.currentReachabilityStatus;
    if (status == ReachableViaWWAN || status == ReachableViaWiFi) {
        [self loadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup as soon as the view becomes visible.
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    if (![PFUser currentUser]) {
        [self presentLoginController];  
    } else {
        [self loadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    [self.refreshView triggerAnimated:YES];
    NetworkStatus status = feedReachability.currentReachabilityStatus;
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
    PFQuery *postsQuery = [PFQuery queryWithClassName:@"Posts"];
    [followingQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    [postsQuery whereKey:@"user" matchesKey:@"to" inQuery:followingQuery];
    if (status == ReachableViaWWAN || status == ReachableViaWiFi) {
        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    [postsQuery orderByDescending:@"createdAt"];
                    postsQuery.limit = 200;
                    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)  {
                        if (!error) {
                            [postsArray addObjectsFromArray:objects];
                        }
                    }];
                } else {
                    [self.refreshView endRefreshing];
                }
            } else {
                [self.refreshView endRefreshing];
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't refresh feed", @"error")];
            }
        }];
        
        PFQuery *currentUserQuery = [PFQuery queryWithClassName:@"Posts"];
        [currentUserQuery orderByDescending:@"createdAt"];
        [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                [postsArray addObjectsFromArray:objects];
                [PFObject unpinAllObjectsInBackground];
                [PFObject pinAllInBackground:postsArray];
                [self.refreshView endRefreshing];
                [self.tableView reloadData];
            }
        }];
        
        if (postsArray.count > 0) {
            NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
            [postsArray sortUsingDescriptors:@[sortOrder]];
        }
    } else if (status == NotReachable) {
        [followingQuery fromLocalDatastore];
        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    PFQuery *postsQuery = [PFQuery queryWithClassName:@"Posts"];
                    [postsQuery whereKey:@"user" matchesKey:@"to" inQuery:followingQuery];
                    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            [postsArray addObjectsFromArray:objects];
                            [self.refreshView endRefreshing];
                            [self.tableView reloadData];
                        }
                    }];
                } else {
                    [self.refreshView endRefreshing];
                }
            } else {
                [self.refreshView endRefreshing];
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get posts", @"nope")];
            }
        }];
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    
    NetworkStatus status = feedReachability.currentReachabilityStatus;
    
    if (status == NotReachable) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"None of your feed stored offline", @"title") attributes:attributes];
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
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Clone allows you to view your feed when you're offline by saving your feed, but you don't have any posts saved. Please try again when you have an internet connection to view your feed.", @"description") attributes:attributes];
    }
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"You aren't following anyone yet. You can go to the search tab to search for users to follow.", @"followthem") attributes:attributes];
}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    [self loadData];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Shrug"];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (postsArray.count == 0) {
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

- (IBAction)profilePicTapped:(id)sender {
    OtherProfilePageViewController *otherProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"otheruser"];
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    PFObject *post = [postsArray objectAtIndex:[self.tableView indexPathForCell:parentCell].row];
    otherProfile.userToQuery = [post objectForKey:@"user"];
    [self.navigationController pushViewController:otherProfile animated:YES];
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
    PFObject *post = [postsArray objectAtIndex:[[self.tableView indexPathForCell:parentCell] row]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return postsArray.count;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
