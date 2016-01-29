//
//  OtherComposeTextView.m
//  
//
//  Created by Deja Jackson on 7/13/15.
//
//

#import "OtherComposeTextView.h"

@implementation OtherComposeTextView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.placeholder = NSLocalizedString(@"What's happening?", @"what");
    self.placeholderColor = [UIColor lightGrayColor];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
}

@end
