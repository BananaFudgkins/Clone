//
//  ComposeViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/12/15.
//  Copyright © 2015 Pixel by Pixel Games. All rights reserved.
//

#import "ComposeViewController.h"
#import "KVNProgress.h"
#import "HomeTableViewController.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController {
    UITapGestureRecognizer *tapGestureRecognizer;
    UIBarButtonItem *cameraItem;
    UIBarButtonItem *postItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                target:self
                                                                                action:@selector(cameraPressed:)];
    postItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", @"post")
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(postPressed:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    postItem.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[postItem, cameraItem];
    
    PFFile *profilePicImageFile = [[PFUser currentUser] objectForKey:@"profilepic"];
    if (profilePicImageFile) {
        [profilePicImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.profilepicImageView.image = [UIImage imageWithData:data];
            } else {
                [KVNProgress showErrorWithStatus:error.localizedFailureReason];
            }
        }];
    } else {
        self.profilepicImageView.image = [UIImage imageNamed:@"Shrug"];
    }
    self.usernameLabel.text = [[PFUser currentUser] username];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    self.composeTextView.delegate = self;
    
    self.profilepicImageView.layer.cornerRadius = self.profilepicImageView.frame.size.width / 2;
    self.profilepicImageView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.view removeGestureRecognizer:tapGestureRecognizer];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *trimmedText = [self.composeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedText isEqualToString:@""]) {
        postItem.enabled = NO;
    } else {
        postItem.enabled = YES;
    }
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    if ([self.composeTextView isFirstResponder]) {
        [self.composeTextView resignFirstResponder];
    }
}

- (IBAction)cameraPressed:(UIBarButtonItem *)sender {
    // Present an action sheet to see if the user wants to take a photo or choose an existing one.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        TGCameraNavigationController *camNav = [TGCameraNavigationController newWithCameraDelegate:self];
        [self presentViewController:camNav animated:YES completion:nil];
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        imagePicker.navigationBar.tintColor = [UIColor whiteColor];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)cameraDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image {
    self.postImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image {
    self.postImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.postImageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Used for saving the post to le server.
- (IBAction)postPressed:(UIBarButtonItem *)sender {
    UIActivityIndicatorView *progressIndicator = [[UIActivityIndicatorView alloc] init];
    progressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [progressIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:progressIndicator];
    PFObject *post = [PFObject objectWithClassName:@"Posts"];
    post[@"user"] = [PFUser currentUser];
    post[@"content"] = self.composeTextView.text;
    if ([self.composeTextView isFirstResponder]) {
        [self.composeTextView resignFirstResponder];
    }
    if (self.postImageView.image != nil) {
        NSData *imageData = UIImageJPEGRepresentation(self.postImageView.image, 0.5);
        PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                post[@"image"] = imageFile;
            } else {
                [progressIndicator stopAnimating];
                [progressIndicator removeFromSuperview];
                self.navigationItem.rightBarButtonItem = postItem;
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save image to post", @"error")];
            }
            if (succeeded) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        HomeTableViewController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"feed"];
                    } else if (error) {
                        [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save post", @"error")];
                        [post saveEventually];
                    }
                }];
            }
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [KVNProgress showSuccessWithCompletion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            } else if (error) {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't save post", @"error")];
                [post saveEventually];
            }
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
