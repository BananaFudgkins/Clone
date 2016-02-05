//
//  FollowingListTableViewController.h
//  
//
//  Created by Deja Jackson on 8/4/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FollowingListTableViewController : UITableViewController

@property (strong, nonatomic) PFUser *followingUser;
@property (nonatomic) BOOL displayFollowing;

@end
