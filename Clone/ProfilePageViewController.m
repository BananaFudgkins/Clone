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
#import "CommentsTableViewController.h"
#import "MBProgressHUD.h"
#import "PostDetailsViewController.h"
#import "FollowingListTableViewController.h"
#import "TGCameraViewController.h"
#import "TTTTimeIntervalFormatter.h"

@interface ProfilePageViewController () <TGCameraDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ProfilePageViewController {
    NSMutableArray *postsArray;
    Reachability *profileReachability;
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
    self.postsTableView.estimatedRowHeight = 170;
    
    postsControl = [[UIRefreshControl alloc] init];
    [postsControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    postsControl.tintColor = [UIColor whiteColor];
    postsControl.backgroundColor = [UIColor colorWithRed:0.22 green:0.62 blue:0.95 alpha:1];
    
    [self.postsTableView addSubview:postsControl];
    
    self.navigationItem.title = [[PFUser currentUser] username];
    
    profileReachability = [Reachability reachabilityForInternetConnection];
    
    UITapGestureRecognizer *photoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePicTapped:)];
    [self.profilepicImageView addGestureRecognizer:photoRecognizer];
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
    self.realnameLabel.text = [[PFUser currentUser] objectForKey:@"realname"];
    self.bioLabel.text = [[PFUser currentUser] objectForKey:@"bio"];
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
    
    PFQuery *followersQuery = [PFQuery queryWithClassName:@"Follows"];
    [followersQuery whereKey:@"to" equalTo:[PFUser currentUser]];
    [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.numFollowersLabel.text = [NSString stringWithFormat:@"%lu", objects.count];
            if (objects.count == 1) {
                self.followersLabel.text = NSLocalizedString(@"Follower", @"follower");
            } else {
                self.followersLabel.text = NSLocalizedString(@"Followers", @"followers");
            }
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
    }];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
    [followingQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.numFollowingLabel.text = [NSString stringWithFormat:@"%lu", objects.count];
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
    }];
}

- (void)loadData {
    [postsControl beginRefreshing];
    PFQuery *postsQuery = [PFQuery queryWithClassName:@"Posts"];
    [postsQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [postsQuery orderByDescending:@"createdAt"];
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            postsArray = objects.mutableCopy;
            [postsControl endRefreshing];
            [self.postsTableView reloadData];
        }
    }];
}

- (void)messageSent:(SKPSMTPMessage *)message {
    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Thanks for your report", @"thanks")];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't report this post", @"error")];
}

- (IBAction)profilePicTapped:(UITapGestureRecognizer *)sender {
    UIAlertController *profilePicOptions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", @"takephoto") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            TGCameraNavigationController *camNav = [TGCameraNavigationController newWithCameraDelegate:self];
            [self presentViewController:camNav animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No camera detected", @"nocamera") message:NSLocalizedString(@"No camera was detected on this device. Please buy a phone with a camera and try again.", @"buyyouscrub") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upload Photo", @"uploadphoto") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    
    [profilePicOptions addAction:takePhoto];
    [profilePicOptions addAction:choosePhoto];
    [profilePicOptions addAction:cancel];
    
    [self presentViewController:profilePicOptions animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    PFFile *profilePhotoFile = [PFFile fileWithName:@"profilepic.jpg" data:UIImageJPEGRepresentation(selectedImage, 0.5)];
    [profilePhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:profilePhotoFile forKey:@"profilepic"];
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
        if (succeeded) {
            [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Profile photo saved successfully", @"saved") completion:^{
                self.profilepicImageView.image = [[PFUser currentUser] objectForKey:@"profilepic"];
            }];
        }
    } progressBlock:^(int percentDone) {
        [KVNProgress updateProgress:(float)percentDone / 100.0f animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image {
    PFFile *profilePicFile = [PFFile fileWithName:@"profilepic.jpg" data:UIImageJPEGRepresentation(image, 0.5)];
    [profilePicFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:profilePicFile forKey:@"profilepic"];
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
        if (succeeded) {
            [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Profile photo saved successfully", @"saved") completion:^{
                self.profilepicImageView.image = [[PFUser currentUser] objectForKey:@"profilepic"];
            }];
        }
    } progressBlock:^(int percentDone) {
        [KVNProgress updateProgress:(float)percentDone / 100.0f animated:YES];
    }];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image {
    PFFile *profilPicFile = [PFFile fileWithName:@"profilepic.jpg" data:UIImageJPEGRepresentation(image, 0.5)];
    [profilPicFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:profilPicFile forKey:@"profilepic"];
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
        if (succeeded) {
            [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Profile photo saved successfully", @"saved") completion:^{
                self.profilepicImageView.image = [[PFUser currentUser] objectForKey:@"profilepic"];
            }];
        }
    } progressBlock:^(int percentDone) {
        [KVNProgress updateProgress:(float)percentDone / 100.0f animated:YES];
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
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

- (IBAction)followingButtonPressed:(UIButton *)sender {
    FollowingListTableViewController *followingList = [self.storyboard instantiateViewControllerWithIdentifier:@"followinglist"];
    followingList.followingUser = [PFUser currentUser];
    followingList.displayFollowing = YES;
    [self.navigationController pushViewController:followingList animated:YES];
}

- (IBAction)followersButton:(UIButton *)sender {
    FollowingListTableViewController *followingList = [self.storyboard instantiateViewControllerWithIdentifier:@"followinglist"];
    followingList.followingUser = [PFUser currentUser];
    followingList.displayFollowing = NO;
    [self.navigationController pushViewController:followingList animated:YES];
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
    if (imageFile) {
        [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (!error) {
                cell.postImageView.image = [UIImage imageWithData:data];
            } else {
                [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
            }
        }];
    }
    
    TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
    cell.dateLabel.text = [formatter stringForTimeIntervalFromDate:[NSDate date] toDate:postForCell.createdAt];
    cell.postContentLabel.text = postForCell[@"content"];
    
    if ([[PFUser currentUser] objectForKey:@"profilepic"]) {
        PFFile *profilePicFile = [[PFUser currentUser] objectForKey:@"profilepic"];
        [profilePicFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (!error) {
                [cell.profilepicButton setBackgroundImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            } else {
                [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
            }
        }];
    }
    
    return cell;
}

- (IBAction)morePressed:(UIButton *)sender {
    UIAlertController *actions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CloneCardCell *parentCell = (CloneCardCell *)[self superviewOfType:[CloneCardCell class] forView:sender];
    PFObject *postForCell = [postsArray objectAtIndex:[[self.postsTableView indexPathForCell:parentCell] row]];
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
    
    [actions addAction:delete];
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
