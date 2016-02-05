//
//  NotificationSettingsTableViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/18/15.
//  Copyright © 2015 Pixel by Pixel Games. All rights reserved.
//

#import "NotificationSettingsTableViewController.h"
#import "KVNProgress.h"

@interface NotificationSettingsTableViewController ()

@end

@implementation NotificationSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    self.likesSwitch.onTintColor = UIColorFromRGB(0x1c9ef1);
    self.commentsSwitch.onTintColor = UIColorFromRGB(0x1c9ef1);
    self.followsSwitch.onTintColor = UIColorFromRGB(0x1c9ef1);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any setup as soon as the view becomes visible.
    
    // Look through the user's settings. If some things are on, turn the switches on.
    NSNumber *likeSetting = [[PFUser currentUser] objectForKey:@"pushlikes"];
    if (likeSetting) {
        if (likeSetting == [NSNumber numberWithBool:YES]) {
            self.likesSwitch.on = YES;
        } else if (likeSetting == [NSNumber numberWithBool:NO]) {
            self.likesSwitch.on = NO;
        }
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushlikes"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    NSNumber *commentSetting = [[PFUser currentUser] objectForKey:@"pushcomments"];
    if (commentSetting) {
        if (commentSetting == [NSNumber numberWithBool:YES]) {
            self.commentsSwitch.on = YES;
        } else if (commentSetting == [NSNumber numberWithBool:NO]) {
            self.commentsSwitch.on = NO;
        }
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushcomments"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    NSNumber *messagesSetting = [[PFUser currentUser] objectForKey:@"pushmessages"];
    if (messagesSetting) {
        if (messagesSetting == [NSNumber numberWithBool:YES]) {
            
        } else if (messagesSetting == [NSNumber numberWithBool:NO]) {
            
        }
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushmessages"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    
    if ([[PFUser currentUser] objectForKey:@"pushfollows"]) {
        if ([[[PFUser currentUser] objectForKey:@"pushfollows"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            self.followsSwitch.on = YES;
        } else {
            self.followsSwitch.on = NO;
        }
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushfollows"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)likeSwitchChanged:(UISwitch *)sender {
    if ([sender isOn]) {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushlikes"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"pushlikes"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

- (IBAction)commentSwitchChanged:(UISwitch *)sender {
    if ([sender isOn]) {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushcomments"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"pushcomments"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

- (IBAction)newMessagesSwitchSwitched:(UISwitch *)sender {
    if (sender.isOn) {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushmessages"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

- (IBAction)newFollowersSwitched:(UISwitch *)sender {
    if (sender.isOn) {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"pushfollows"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"pushfollows"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self showErrorNotification];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

- (void)showErrorNotification {
    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save your profile", @"error")];
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
