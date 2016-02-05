//
//  FollowingListTableViewCell.m
//  
//
//  Created by Deja Jackson on 8/4/15.
//
//

#import "FollowingListTableViewCell.h"

@implementation FollowingListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profilepicImageView.layer.cornerRadius = self.profilepicImageView.frame.size.width / 2;
    self.profilepicImageView.clipsToBounds = YES;
    self.profilepicImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profilepicImageView.backgroundColor = [UIColor whiteColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.profilepicImageView.image = nil;
    self.usernameLabel.text = nil;
    self.realNameLabel.text = nil;
}

@end
