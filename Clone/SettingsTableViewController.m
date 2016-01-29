//
//  SettingsTableViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/12/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "KVNProgress.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

    self.saveSwitch.onTintColor = UIColorFromRGB(0x1c9ef1);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any setup as soon as the view becomes visible.
    
    if ([[PFUser currentUser] objectForKey:@"savephotos"]) {
        if ([[[PFUser currentUser] objectForKey:@"savephotos"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            self.saveSwitch.on = YES;
        } else {
            [self.saveSwitch setOn:NO animated:YES];
        }
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"savephotos"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save your profile", @"nope")];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutPressed:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure you want to log out?", @"bruh") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *logout = [UIAlertAction actionWithTitle:NSLocalizedString(@"Log out", @"logout") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
            if (!error) {
                [self presentLoginController];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't log you out", @"logouterror")];
            }
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:logout];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)resetPressed:(UIButton *)sender {
    UIAlertController *resetAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Reset Password", @"reset") message:NSLocalizedString(@"Please enter the email address for your account.", @"message") preferredStyle:UIAlertControllerStyleAlert];
    [resetAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Email", @"Email");
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.returnKeyType = UIReturnKeyDone;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *done = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *alertTextField = resetAlert.textFields[0];
        if ([alertTextField hasText] && [self validateEmail:alertTextField.text]) {
            [PFUser requestPasswordResetForEmailInBackground:alertTextField.text block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Password reset email sent successfully", @"success")];
                } else {
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't send password reset email", @"error")];
                }
            }];
        } else {
            UIAlertController *validEmailBitch = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Email Address", @"emailplease") message:NSLocalizedString(@"Please enter a valid email address before proceeding.", @"message") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self presentViewController:resetAlert animated:YES completion:nil];
            }];
            [validEmailBitch addAction:cancel];
            [self presentViewController:validEmailBitch animated:YES completion:nil];
        }
    }];
    [resetAlert addAction:done];
    [resetAlert addAction:cancel];
    [self presentViewController:resetAlert animated:YES completion:nil];
}

- (IBAction)saveSwitchSwitched:(UISwitch *)sender {
    if ([sender isOn]) {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"savephotos"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save your profile", @"error")];
            }
        }];
    } else {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"savephotos"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save your profile", @"error")];
            }
        }];
    }
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

- (void)presentLoginController {
    LoginViewController *loginController = [[LoginViewController alloc] init];
    SignUpViewController *signUpController = [[SignUpViewController alloc] init];
    loginController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsPasswordForgotten | PFLogInFieldsFacebook | PFLogInFieldsTwitter | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton;
    loginController.signUpController = signUpController;
    loginController.delegate = self;
    signUpController.delegate = self;
    
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"user"] = user;
    [currentInstallation saveInBackground];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSelectorOnMainThread:@selector(logoutPressed:) withObject:self waitUntilDone:NO];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"editprofile" sender:self];
        } else if (indexPath.row == 2) {
            [self performSelectorOnMainThread:@selector(resetPressed:) withObject:self waitUntilDone:NO];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"notificationsettings" sender:self];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"terms" sender:self];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"licenses" sender:self];
        } else if (indexPath.row == 2) {
            [self performSegueWithIdentifier:@"privacypolicy" sender:self];
        }
    }
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
