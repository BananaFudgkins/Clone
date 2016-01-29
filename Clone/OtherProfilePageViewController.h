//
//  OtherProfilePageViewController.h
//  Clone
//
//  Created by Deja Jackson on 6/17/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UIScrollView+EmptyDataSet.h"
#import "SKPSMTPMessage.h"

@interface OtherProfilePageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SKPSMTPMessageDelegate>

@property (strong, nonatomic) PFUser *userToQuery;
@property (strong, nonatomic) IBOutlet UIImageView *profilepicImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *realnameLabel;
@property (strong, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet UITableView *postsTableView;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowingLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFollowersLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersLabel;
@property (strong, nonatomic) IBOutlet UILabel *followingLabel;

@end
