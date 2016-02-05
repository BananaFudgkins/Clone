//
//  MessagesTableViewController.h
//  
//
//  Created by Deja Jackson on 7/22/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <LGRefreshView.h>

@interface MessagesTableViewController : UITableViewController <LGRefreshViewDelegate>

@property (strong, nonatomic) LGRefreshView *refreshView;

@end
