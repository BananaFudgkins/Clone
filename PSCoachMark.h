//
//  PSCoachMark.h
//  PSCoachMark
//
//  Created by Patrick Steiner on 15.01.15.
//  Copyright (c) 2015 Patrick Steiner. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    /** Coach Mark is shown center in the given view. This is the default. */
    PSCoachMarkModeNormal,
    
    /** Coach Mark is shown above the given view. */
    PSCoachMarkModeAbove
} PSCoachMarkMode;

typedef enum {
    /** Dim up view. */
    PSDimModeUp,
    
    /** Dim down view. */
    PSDimModeDown
} PSDimMode;

@interface PSCoachMark : UIView

/**
 * Displays a coach mark over the given view and a given text.
 */
+ (instancetype)showCoachMarkAddedTo:(UIView *)view withAttributedText:(NSAttributedString *)attributedInfoText withMode:(PSCoachMarkMode)mode;

/**
 * The width of the coach mark. Default: 100.
 */

@property (assign) CGFloat width;

/**
 * The height of the coach mark. Default: 44.
 */
@property (assign) CGFloat height;

/**
 * The margin around the coach mark. Default: 10.
 */
@property (assign) CGFloat margin;

/**
 * The label text. Default: none.
 */
@property (copy) NSAttributedString *labelText;

/**
 * The label background color. Default: gray.
 */
@property (nonatomic, strong) UIColor *markColor;

/**
 * The current coach mark mode.
 */
@property (assign) PSCoachMarkMode mode;

/**
 * Show the view, without a animation.
 */
- (void)show;

/**
 * Show the view, with or without a animation.
 */
- (void)showWithAnimation:(BOOL)animated;

/**
 * Hide the view, without a animation.
 */
- (void)hide;

/**
 * Hide the view, with or without animation.
 */
- (void)hideWithAnimation:(BOOL)animated;

/**
 * Hide the few after a given amount of seconds, with or without animation.
 */
- (void)hideWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end
