//
//  HomeTableViewController.h
//  Clone
//
//  Created by Deja Jackson on 6/11/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

#import "UIScrollView+EmptyDataSet.h"
#import "SKPSMTPMessage.h"
#import "AFDropdownNotification.h"

@interface HomeTableViewController : UITableViewController <UIViewControllerPreviewingDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SKPSMTPMessageDelegate, AFDropdownNotificationDelegate>

@property (assign, nonatomic) CATransform3D initialTransform;
@property (strong, nonatomic) NSMutableSet *shownIndexes;
@property (strong, nonatomic) PFObject *commentObject;
@property (strong, nonatomic) AFDropdownNotification *notification;

@property (strong, nonatomic) id previewingContext;

@end
