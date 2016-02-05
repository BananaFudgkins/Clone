//
//  CommentsTextView.m
//  Clone
//
//  Created by Deja Jackson on 6/20/15.
//  Copyright © 2015 Pixel by Pixel Games. All rights reserved.
//

#import "CommentsTextView.h"

@implementation CommentsTextView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.placeholder = NSLocalizedString(@"Add a comment here...", @"comment");
    self.placeholderColor = [UIColor lightGrayColor];
    self.pastableMediaTypes = SLKPastableMediaTypeNone;
    
    self.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0].CGColor;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

@end
