//
//  MessagesTableViewController.m
//  
//
//  Created by Deja Jackson on 7/22/15.
//
//

#import "MessagesTableViewController.h"
#import "KVNProgress.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>

@interface MessagesTableViewController () <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@end

@implementation MessagesTableViewController {
    NSMutableArray *threadsArray;
    Reachability *reachability;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshView = [[LGRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    [self loadData];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    self.tableView.estimatedRowHeight = 50.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    [self.refreshView triggerAnimated:YES];
    NetworkStatus status = reachability.currentReachabilityStatus;
    PFQuery *threadsQuery = [PFQuery queryWithClassName:@"Threads"];
    [threadsQuery orderByDescending:@"updatedAt"];
    [threadsQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    if (status == ReachableViaWWAN || status == ReachableViaWiFi) {
        [threadsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                threadsArray = objects.mutableCopy;
                [PFObject unpinAllObjectsInBackground];
                [PFObject pinAllInBackground:objects];
                [self.refreshView endRefreshing];
                [self.tableView reloadData];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get your messages", @"error")];
            }
        }];
    } else if (status == NotReachable) {
        [threadsQuery fromLocalDatastore];
        [threadsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                threadsArray = objects.mutableCopy;
                [self.refreshView endRefreshing];
                [self.tableView reloadData];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get your messages", @"error")];
            }
        }];
    }
}

- (void)refreshViewRefreshing:(LGRefreshView *)refreshView {
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return threadsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message" forIndexPath:indexPath];
    cell.imageView.layer.cornerRadius = 22;
    cell.imageView.layer.masksToBounds = YES;
    
    // Configure the cell...
    PFObject *thread = threadsArray[indexPath.row];
    // cell.detailTextLabel.text = [[thread updatedAt] timeAgoSinceNow];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:[[thread objectForKey:@"recipient"] objectId]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFUser *threadRecipint = objects.lastObject;
            cell.textLabel.text = threadRecipint.username;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE MMM d, h:mm a"];
            cell.detailTextLabel.text = [dateFormatter stringFromDate:thread.updatedAt];
            if ([threadRecipint objectForKey:@"profilepic"]) {
                PFFile *profilePicFile = [threadRecipint objectForKey:@"profilepic"];
                [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        cell.imageView.image = [UIImage imageWithData:data];
                        [cell layoutIfNeeded];
                    } else {
                        [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get profile photos", @"error")];
                    }
                }];
            }
        }
    }];
    
    return cell;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]};
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No messages", @"nope") attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:18.0],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Looks like you aren't messaging anyone yet. You can compose a message by tapping on the speech bubble icon on someone's profile page. Or if you have composed a message and it isn't showing up here, just drag down to refresh.", @"tapityoushit") attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Shrug"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (threadsArray.count == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return YES;
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return NO;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
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
