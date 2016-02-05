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
#import <pop/POP.h>
#import <LGRefreshView.h>
#import <QuartzCore/QuartzCore.h>

#import "UIScrollView+EmptyDataSet.h"
#import "SKPSMTPMessage.h"

@interface HomeTableViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SKPSMTPMessageDelegate, LGRefreshViewDelegate>

@property (strong, nonatomic) LGRefreshView *refreshView;
@property (assign, nonatomic) CATransform3D initialTransform;
@property (strong, nonatomic) NSMutableSet *shownIndexes;

@end
