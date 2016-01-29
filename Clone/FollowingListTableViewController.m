//
//  FollowingListTableViewController.m
//  
//
//  Created by Deja Jackson on 8/4/15.
//
//

#import "FollowingListTableViewController.h"
#import "FollowingListTableViewCell.h"
#import "KVNProgress.h"
#import "OtherProfilePageViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface FollowingListTableViewController () <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@end

@implementation FollowingListTableViewController {
    NSMutableArray *followingArray;
    BOOL shouldShow;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.displayFollowing == YES) {
        self.navigationItem.title = NSLocalizedString(@"Following", @"following");
        PFQuery *followingQuery = [PFQuery queryWithClassName:@"Follows"];
        [followingQuery whereKey:@"from" equalTo:self.followingUser];
        [followingQuery includeKey:@"to"];
        [followingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.navigationItem.rightBarButtonItem = nil;
                followingArray = objects.mutableCopy;
                if (followingArray.count == 0) {
                    shouldShow = YES;
                }
                [self.tableView reloadData];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get users", @"error")];
            }
        }];
    } else {
        self.navigationItem.title = NSLocalizedString(@"Followers", @"followers");
        PFQuery *followersQuery = [PFQuery queryWithClassName:@"Follows"];
        [followersQuery whereKey:@"to" equalTo:self.followingUser];
        [followersQuery includeKey:@"from"];
        [followersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.navigationItem.rightBarButtonItem = nil;
                followingArray = objects.mutableCopy;
                if (followingArray.count == 0) {
                    shouldShow = YES;
                }
                [self.tableView reloadData];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get users", @"error")];
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingIndicator startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingIndicator];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    
    if (self.displayFollowing == YES) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Not following anyone", @"nope") attributes:attributes];
    } else {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No followers", @"alsonope") attributes:attributes];
    }
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:18]};
    if (self.displayFollowing == YES) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"This user isn't following anyone yet.", @"nope") attributes:attributes];
    } else {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"This user doesn't have any followers", @"nope") attributes:attributes];
    }
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Shrug"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (shouldShow == YES) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return YES;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return followingArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFObject *followingObject = followingArray[indexPath.row];
    
    PFQuery *userQuery = [PFUser query];
    if (self.displayFollowing == YES) {
        PFUser *selectedUser = followingObject[@"to"];
        OtherProfilePageViewController *otherProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"otheruser"];
        otherProfile.userToQuery = selectedUser;
        
        [self.navigationController pushViewController:otherProfile animated:YES];
    } else {
        PFUser *selectedUser = followingObject[@"from"];
        OtherProfilePageViewController *otherProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"otheruser"];
        otherProfile.userToQuery = selectedUser;
        
        [self.navigationController pushViewController:otherProfile animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowingListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"following" forIndexPath:indexPath];
    
    // Configure the cell...
    
    PFObject *followingObject = followingArray[indexPath.row];
    PFFile *profilePicFile;
    
    if (self.displayFollowing == YES) {
        if ([[followingObject objectForKey:@"to"] objectForKey:@"profilepic"]) {
            profilePicFile = [[followingObject objectForKey:@"to"] objectForKey:@"profilepic"];
            [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    cell.profilepicImageView.image = [UIImage imageWithData:data];
                } else {
                    [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
                }
            }];
        } else {
            cell.profilepicImageView.image = [UIImage imageNamed:@"User"];
        }
        
        cell.usernameLabel.text = [[followingObject objectForKey:@"to"] objectForKey:@"username"];
        cell.realNameLabel.text = [[followingObject objectForKey:@"to"] objectForKey:@"realname"];
    } else {
        if ([[followingObject objectForKey:@"from"] objectForKey:@"profilepic"]) {
            profilePicFile = [[followingObject objectForKey:@"from"] objectForKey:@"profilepic"];
            [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    cell.profilepicImageView.image = [UIImage imageWithData:data];
                } else {
                    [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
                }
            }];
        } else {
            cell.profilepicImageView.image = [UIImage imageNamed:@"User"];
        }
        
        cell.usernameLabel.text = [[followingObject objectForKey:@"from"] objectForKey:@"username"];
        cell.realNameLabel.text = [[followingObject objectForKey:@"from"] objectForKey:@"realname"];
    }
    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
