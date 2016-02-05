//
//  ShareViewController.m
//  ShareExtension
//
<<<<<<< HEAD
//  Created by Deja Jackson on 8/27/15.
//  Copyright (c) 2015 Deja Jackson. All rights reserved.
=======
//  Created by Deja Jackson on 6/17/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController {
<<<<<<< HEAD
    __block UIImage *postImage;
=======
    UIImage *photo;
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
<<<<<<< HEAD
    
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.pixelbypixel.Clone"
                                     containingApplication:@"com.pixelbypixel.Clone"];
=======
    // Do any setup as soon as the view becomes visible.
    
    // Enable sharing between this extension and the parent.
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.pixelbypixel.Clone" containingApplication:@"com.pixelbypixel.Clone"];
    
    // Power Clone with Parse Local Datastore.
    [Parse enableLocalDatastore];
    
    // Enable crash reporting.
    [ParseCrashReporting enable];
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
    
    // Initialize Parse.
    [Parse setApplicationId:@"zXsU51Bh1AwneejkVIYUMRZzI0MQXIJLy1IM0LOh"
                  clientKey:@"hvDPq4a89vLnKYwkZLBMytS3M2R8qsLiOFpxFC3L"];
<<<<<<< HEAD
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    
    if (![PFUser currentUser]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not logged in", @"loggedout") message:NSLocalizedString(@"You are not logged in to Clone. Login in the app and try again.", @"try") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
=======
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
<<<<<<< HEAD
    
=======
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
<<<<<<< HEAD
                    if (image && !error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            postImage = image;
                        });
                    }
                }];
                break;
            }
        }
    }
    
    NSData *imageData = UIImageJPEGRepresentation(postImage, 0.5);
    
    PFObject *post = [PFObject objectWithClassName:@"Posts"];
    post[@"user"] = [PFUser currentUser];
    PFFile *photoFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            post[@"image"] = photoFile;
            NSString *trimmedText = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([trimmedText isEqualToString:@""]) {
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                    if (error) {
                        [post saveEventually];
                    }
                }];
            } else {
                post[@"content"] = self.textView.text;
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                    if (error) {
                        [post saveEventually];
                    }
                }];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't save image to post", @"error") message:error.userInfo[@"error"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
            }];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
=======
                    if (!error && image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            photo = image;
                            NSData *imageData = UIImageJPEGRepresentation(photo, 0.5);
                            PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
                            PFObject *post = [PFObject objectWithClassName:@"Posts"];
                            post[@"user"] = [PFUser currentUser];
                            if ([self.textView hasText]) {
                                post[@"content"] = self.textView.text;
                                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (error) {
                                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't save image to post", @"error") message:NSLocalizedString(@"A problem occurred when trying to save your image to this post. Please try again later.", @"mesage") preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:nil];
                                        [alert addAction:cancel];
                                        [self presentViewController:alert animated:YES completion:nil];
                                    } else {
                                        post[@"image"] = imageFile;
                                    }
                                    if (succeeded) {
                                        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            if (error) {
                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't save your post", @"title") message:NSLocalizedString(@"A problem occurred when saving your post. Please check your internet connection and try again later.", @"message") preferredStyle:UIAlertControllerStyleAlert];
                                                UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:nil];
                                                [alert addAction:cancel];
                                                [self presentViewController:alert animated:YES completion:nil];
                                            }
                                            if (succeeded) {
                                                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                            }
                                        }];
                                    }
                                }];
                            } else {
                                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (error) {
                                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't save image to post", @"error") message:NSLocalizedString(@"A problem occurred when trying to save your image to this post. Please try again later.", @"mesage") preferredStyle:UIAlertControllerStyleAlert];
                                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:nil];
                                        [alert addAction:cancel];
                                        [self presentViewController:alert animated:YES completion:nil];
                                    } else {
                                        post[@"image"] = imageFile;
                                    }
                                    if (succeeded) {
                                        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            if (error) {
                                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't save your post", @"title") message:NSLocalizedString(@"A problem occurred when saving your post. Please check your internet connection and try again later.", @"message") preferredStyle:UIAlertControllerStyleAlert];
                                                UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:nil];
                                                [alert addAction:cancel];
                                                [self presentViewController:alert animated:YES completion:nil];
                                            }
                                            if (succeeded) {
                                                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                            }
                                        }];
                                    }
                                }];
                            }
                        });
                    }
                }];
            }
        }
    }
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
