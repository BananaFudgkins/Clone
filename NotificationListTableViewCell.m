//
//  NotificationListTableViewCell.m
//  
//
//  Created by Deja Jackson on 7/26/15.
//
//

#import "NotificationListTableViewCell.h"

@implementation NotificationListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.width / 2;
    self.profilePicImageView.clipsToBounds = YES;
    self.profilePicImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profilePicImageView.backgroundColor = [UIColor whiteColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.profilePicImageView.image = nil;
    self.notificationContentLabel.text = nil;
    self.dateLabel.text = nil;
}

@end
