//
//  EditProfileTableViewController.h
//  Clone
//
//  Created by Deja Jackson on 6/13/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TGCameraViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface EditProfileTableViewController : UITableViewController <TGCameraDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *realnameTextField;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *bioTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;
@property (strong, nonatomic) NSArray *assets;

@end
