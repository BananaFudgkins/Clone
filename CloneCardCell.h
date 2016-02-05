//
//  CloneCardCell.h
//  Clone
//
//  Created by Deja Jackson on 6/12/15.
//  Copyright © 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DXTimestampLabel.h>

@interface CloneCardCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postContentLabel;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *profilepicButton;
@property (strong, nonatomic) IBOutlet DXTimestampLabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *likeCountLabel;

@end
