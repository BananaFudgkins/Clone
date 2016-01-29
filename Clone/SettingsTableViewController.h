//
//  SettingsTableViewController.h
//  Clone
//
//  Created by Deja Jackson on 6/12/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface SettingsTableViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *saveSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *nightModeSwitch;
@property (strong, nonatomic) IBOutlet UIButton *logOutButton;
@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *resetPasswordButton;
@property (strong, nonatomic) IBOutlet UIButton *notificationSettingsButton;
@property (strong, nonatomic) IBOutlet UILabel *savePhotosLabel;
@property (strong, nonatomic) IBOutlet UILabel *nightModeLabel;
@property (strong, nonatomic) IBOutlet UIButton *termsButton;
@property (strong, nonatomic) IBOutlet UIButton *librariesButton;
@property (strong, nonatomic) IBOutlet UIButton *NSAButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *editProfileCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *resetPasswordCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *notificationSettingsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *savePhotosCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *nightModeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *termsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *licensesCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *privacyCell;

@end
