//
//  NotificationSettingsTableViewController.h
//  Clone
//
//  Created by Deja Jackson on 6/18/15.
//  Copyright © 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NotificationSettingsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UISwitch *likesSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *commentsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *followsSwitch;


@end
