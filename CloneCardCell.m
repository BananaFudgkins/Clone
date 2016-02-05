//
//  CloneCardCell.m
//  Clone
//
//  Created by Deja Jackson on 6/12/15.
//  Copyright © 2015 Pixel by Pixel Games. All rights reserved.
//

#import "CloneCardCell.h"

@implementation CloneCardCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self cardSetup];
    [self imageSetup];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.profilepicButton setBackgroundImage:nil forState:UIControlStateNormal];
    self.postContentLabel.text = nil;
    self.dateLabel.text = nil;
    self.usernameLabel.text = nil;
}

- (void)cardSetup {
    [self.cardView setAlpha:1];
    self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.shadowOffset = CGSizeMake(-.2f, -.2f);
    self.cardView.layer.shadowRadius = 1;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cardView.bounds];
    self.cardView.layer.shadowPath = path.CGPath;
    self.cardView.layer.shadowOpacity = 0.2;
}

- (void)imageSetup {
    self.profilepicButton.layer.cornerRadius = self.profilepicButton.frame.size.width / 2;
    self.profilepicButton.clipsToBounds = YES;
    self.profilepicButton.contentMode = UIViewContentModeScaleAspectFill;
    self.profilepicButton.backgroundColor = [UIColor whiteColor];
}

@end
