//
//  EditProfileTableViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/13/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import "KVNProgress.h"
#import "MBProgressHUD.h"

@interface EditProfileTableViewController ()

@end

@implementation EditProfileTableViewController {
    UITapGestureRecognizer *tapGestureRecognizer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameTextField.text = [[PFUser currentUser] username];
    if ([[PFUser currentUser] objectForKey:@"bio"]) {
        self.bioTextField.text = [[PFUser currentUser] objectForKey:@"bio"];
    }
    if ([[PFUser currentUser] objectForKey:@"realname"]) {
        self.realnameTextField.text = [[PFUser currentUser] objectForKey:@"realname"];
    }
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    
    // Notify the view controller when the keyboard will show and hide.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardwillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Notify the view controller when the text in a text field changes.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    } else if ([self.bioTextField isFirstResponder]) {
        [self.bioTextField resignFirstResponder];
    } else if ([self.realnameTextField isFirstResponder]) {
        [self.realnameTextField resignFirstResponder];
    }
}
- (IBAction)changeprofilephotoPressed:(UIButton *)sender {
    UIAlertController *options = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Upload a photo", @"upload") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", @"take") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            TGCameraNavigationController *camNav = [TGCameraNavigationController newWithCameraDelegate:self];
            [self presentViewController:camNav animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No camera detected on this device.", @"nope") message:NSLocalizedString(@"It seems like you don't have a camera on this device. Please buy a phone with a camera and try again.", @"nocamera") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upload Photo", @"upload") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
    
    [options addAction:takePhoto];
    [options addAction:choosePhoto];
    [options addAction:cancel];
    
    options.modalPresentationStyle = UIModalPresentationPopover;
    options.popoverPresentationController.sourceView = sender;
    
    [self presentViewController:options animated:YES completion:nil];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIAlertController *options = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Upload a photo", @"upload") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", @"take") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    TGCameraNavigationController *camNav = [TGCameraNavigationController newWithCameraDelegate:self];
                    [self presentViewController:camNav animated:YES completion:nil];
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No camera detected on this device.", @"nope") message:NSLocalizedString(@"It seems like you don't have a camera on this device. Please buy a phone with a camera and try again.", @"nocamera") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:cancel];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
            
            UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upload Photo", @"upload") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing = YES;
                imagePicker.delegate = self;
                imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
                imagePicker.navigationBar.tintColor = [UIColor whiteColor];
                [self presentViewController:imagePicker animated:YES completion:nil];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel") style:UIAlertActionStyleCancel handler:nil];
            
            [options addAction:takePhoto];
            [options addAction:choosePhoto];
            [options addAction:cancel];
            
            options.modalPresentationStyle = UIModalPresentationPopover;
            options.popoverPresentationController.sourceView = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [self presentViewController:options animated:YES completion:nil];
        }
    }
}

- (IBAction)saveTapped:(UIBarButtonItem *)sender {
    MBProgressHUD *savingHUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    savingHUD.mode = MBProgressHUDModeText;
    savingHUD.labelText = NSLocalizedString(@"Saving your profile...", @"saving");
    if ([self.realnameTextField isFirstResponder]) {
        [self.realnameTextField resignFirstResponder];
    } else if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
    } else if ([self.bioTextField isFirstResponder]) {
        [self.bioTextField resignFirstResponder];
    }
    [[PFUser currentUser] setObject:self.realnameTextField.text forKey:@"realname"];
    [[PFUser currentUser] setUsername:self.usernameTextField.text];
    [[PFUser currentUser] setObject:self.bioTextField.text forKey:@"bio"];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [savingHUD hide:YES];
        } else if (error) {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save your profile", @"error")];
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)keyboardwillHide:(NSNotification *)notification {
    [self.view removeGestureRecognizer:tapGestureRecognizer];
}

- (void)textFieldTextDidChange:(UITextField *)textField {
    if ([self.realnameTextField hasText] || [self.usernameTextField hasText] || [self.bioTextField hasText]) {
        self.saveBarButtonItem.enabled = YES;
    } else {
        self.saveBarButtonItem.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.realnameTextField isFirstResponder]) {
        [self.realnameTextField resignFirstResponder];
        [self.usernameTextField becomeFirstResponder];
    } else if ([self.usernameTextField isFirstResponder]) {
        [self.usernameTextField resignFirstResponder];
        [self.bioTextField becomeFirstResponder];
    } else if ([self.bioTextField isFirstResponder]) {
        [self.bioTextField resignFirstResponder];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save your profile", @"nope")];
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    return YES;
}

- (void)cameraDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:nil];
    MBProgressHUD *savingHUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    savingHUD.mode = MBProgressHUDModeText;
    savingHUD.labelText = NSLocalizedString(@"Saving profile photo...", @"saving");
    PFFile *imageFile = [PFFile fileWithName:@"profilepic.jpg" data:UIImageJPEGRepresentation(image, 0.5)];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:imageFile forKey:@"profilepic"];
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save profile photo", @"error")];
        }
        if(succeeded) {
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save profile photo", @"error")];
                }
                if (succeeded) {
                    [savingHUD hide:YES];
                    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Profile photo saved successfully", @"saved")];
                }
            }];
        }
    }];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:nil];
    MBProgressHUD *savingHUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    savingHUD.mode = MBProgressHUDModeText;
    savingHUD.labelText = NSLocalizedString(@"Saving profile photo...", @"saving");
    PFFile *imageFile = [PFFile fileWithName:@"profilepic.jpg" data:UIImageJPEGRepresentation(image, 0.5)];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:imageFile forKey:@"profilepic"];
        } else {
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
        if(succeeded) {
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save profile photo", @"error")];
                }
                if (succeeded) {
                    [savingHUD hide:YES];
                    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"Profile photo saved successfully", @"saved") completion:^{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
            }];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    MBProgressHUD *savingHUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    savingHUD.mode = MBProgressHUDModeText;
    savingHUD.labelText = NSLocalizedString(@"Saving profile photo...", @"saving");
    PFFile *imageFile = [PFFile fileWithName:@"profilepic.jpg" data:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage], 0.5)];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:imageFile forKey:@"profilepic"];
        } else {
            [savingHUD hide:YES];
            [KVNProgress showErrorWithStatus:error.userInfo[@"error"]];
        }
        if (succeeded) {
            [savingHUD hide:YES];
            [KVNProgress showSuccessWithStatus:error.userInfo[@"error"]];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
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
