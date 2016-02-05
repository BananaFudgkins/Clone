//
//  ComposeViewController.h
//  Clone
//
//  Created by Deja Jackson on 6/12/15.
//  Copyright © 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Parse/Parse.h>
#import "OtherComposeTextView.h"
#import "TGCameraViewController.h"

@interface ComposeViewController : UIViewController <UITextViewDelegate, TGCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSArray *assets;
@property (strong, nonatomic) IBOutlet OtherComposeTextView *composeTextView;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UIImageView *profilepicImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *composeScrollView;

@end
