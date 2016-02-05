//
//  NotificationsListTableViewController.m
//  
//
//  Created by Deja Jackson on 7/26/15.
//
//

#import "NotificationsListTableViewController.h"
#import "NotificationListTableViewCell.h"
#import "KVNProgress.h"
#import "PostDetailsViewController.h"
#import "CommentsTableViewController.h"

@interface NotificationsListTableViewController ()

@end

@implementation NotificationsListTableViewController {
    NSMutableArray *notificationsArray;
    UIActivityIndicatorView *loadingIndicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60.0;
    
    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    [self loadNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadNotifications {
    [loadingIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingIndicator];
    PFQuery *notificationsQuery = [PFQuery queryWithClassName:@"Notifications"];
    [notificationsQuery whereKey:@"foruser" equalTo:[PFUser currentUser]];
    [notificationsQuery orderByDescending:@"createdAt"];
    [notificationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            notificationsArray = objects.mutableCopy;
            [loadingIndicator stopAnimating];
            self.navigationItem.rightBarButtonItem = self.refreshBarButtonItem;
            [self.tableView reloadData];
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get notifications", @"error")];
        }
    }];
}

- (IBAction)refreshPressed:(UIBarButtonItem *)sender {
    [self loadNotifications];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (notificationsArray.count == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return YES;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return NO;
    }
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Notifications Inverted"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]};
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No notifications", @"nope") attributes:attributes];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return notificationsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *notification = notificationsArray[indexPath.row];
    if ([[notification objectForKey:@"type"] isEqualToString:@"Like"]) {
        PostDetailsViewController *postDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"postdetails"];
        postDetails.post = notification;
        [self.navigationController pushViewController:postDetails animated:YES];
    } else if ([[notification objectForKey:@"type"] isEqualToString:@"Comment"]) {
        CommentsTableViewController *commentsController = [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
        commentsController.postObject = notification;
        [self.navigationController pushViewController:commentsController animated:YES];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notification" forIndexPath:indexPath];
    
    // Configure the cell...
    
    PFObject *notificationForCell = notificationsArray[indexPath.row];
    
    cell.notificationContentLabel.text = [notificationForCell objectForKey:@"content"];
    cell.dateLabel.timestamp = notificationForCell.createdAt;
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"fromuser" equalTo:[[notificationForCell objectForKey:@"fromuser"] objectId]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *notificationUser = objects.lastObject;
            if ([notificationUser objectForKey:@"profilepic"]) {
                PFFile *profilePicFile = [notificationUser objectForKey:@"profilepic"];
                [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        cell.profilePicImageView.image = [UIImage imageWithData:data];
                    }
                }];
            } else {
                cell.profilePicImageView.image = [UIImage imageNamed:@"User"];
            }
        }
    }];
    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
