//
//  ShareViewController.m
//  ShareExtension
//
//  Created by Deja Jackson on 8/27/15.
//  Copyright (c) 2015 Deja Jackson. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController {
    __block UIImage *postImage;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.pixelbypixel.Clone"
                                     containingApplication:@"com.pixelbypixel.Clone"];
    
    // Initialize Parse.
    [Parse setApplicationId:@"zXsU51Bh1AwneejkVIYUMRZzI0MQXIJLy1IM0LOh"
                  clientKey:@"hvDPq4a89vLnKYwkZLBMytS3M2R8qsLiOFpxFC3L"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
    
    if (![PFUser currentUser]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not logged in", @"loggedout") message:NSLocalizedString(@"You are not logged in to Clone. Login in the app and try again.", @"try") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
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
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
