//
//  NotificationsListTableViewController.h
//  
//
//  Created by Deja Jackson on 7/26/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UIScrollView+EmptyDataSet.h"

@interface NotificationsListTableViewController : UITableViewController <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;

@end
