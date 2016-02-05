//
//  PSCoachMark.m
//  PSCoachMark
//
//  Created by Patrick Steiner on 15.01.15.
//  Copyright (c) 2015 Patrick Steiner. All rights reserved.
//

#import "PSCoachMark.h"

@interface PSCoachMark()

@property (nonatomic, strong) UILabel *label;

@end

@implementation PSCoachMark

+ (instancetype)showCoachMarkAddedTo:(UIView *)view withAttributedText:(NSAttributedString *)attributedInfoText withMode:(PSCoachMarkMode)mode {
    PSCoachMark *coachMark = [[self alloc] initWithView:view andMode:mode];
    
    coachMark.labelText = attributedInfoText;
    
    [view addSubview:coachMark];

    return coachMark;
}

- (id)initWithView:(UIView *)view andMode:(PSCoachMarkMode)mode {
    NSAssert(view, @"View must not be nil");
    [self setupDefaultsSizes];
    
    self.mode = mode;
    
    if (mode == PSCoachMarkModeAbove) {
        return [self initWithFrame:[self centerCoachMarkAboveView:view.bounds]];
    } else {
        return [self initWithFrame:[self centerCoachMarkInView:view.bounds]];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _markColor = [UIColor grayColor];
        
        [self setupGestureRecognizer];
        [self setupLabel];
        [self registerForKVO];
    }
    
    return self;
}

- (void)dealloc {
    [self unregisterFromKVO];
}

#pragma mark - Setup

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleTap];
    
    [self setUserInteractionEnabled:YES];
}

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
    //[self removeFromSuperview];
    [self setHidden:YES];
}

- (void)setupLabel {
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.adjustsFontSizeToFitWidth = NO;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.attributedText = _labelText;
    
    // enable multi line support
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.numberOfLines = 0;
    
    [self addSubview:_label];
}

#pragma mark - UI

- (void)drawRect:(CGRect)rect {
    CGFloat borderOffset = 5;
    CGFloat cornerRadius = 5;
    
    CGRect innerRect = CGRectMake((CGRectGetMinX(rect) + borderOffset), (CGRectGetMinY(rect) + borderOffset), (_width - (2 * borderOffset)), (_height - (2 * borderOffset)));
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:cornerRadius];
    [_markColor setFill];
    [roundedRect fill];

    if (_mode == PSCoachMarkModeAbove) {
        // Draw the pointing triangle
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, (CGRectGetMidX(rect) - 5), (CGRectGetMaxY(rect) - borderOffset)); // (mid - 5) bottom
        CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect)); // mid (bottom - 5)
        CGContextAddLineToPoint(context, (CGRectGetMidX(rect) + 5), (CGRectGetMaxY(rect) - borderOffset)); // (mid + 5) bottom
        CGContextClosePath(context);
        
        CGContextSetFillColorWithColor(context, _markColor.CGColor);
        CGContextFillPath(context);
    }
}

- (void)show {
    [self showWithAnimation:NO];
}

- (void)showWithAnimation:(BOOL)animated {
    if (animated) {
        [self addDimAnimationToView:self withDimMode:PSDimModeUp];
    } else {
        self.alpha = 1.0;
        [self setHidden:NO];
    }
}

- (void)hide {
    [self hideWithAnimation:NO];
}

- (void)hideWithAnimation:(BOOL)animated {
    if (animated) {
        [self addDimAnimationToView:self withDimMode:PSDimModeDown];
    } else {
        [self setHidden:YES];
    }
}

- (void)hideWithAnimation:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(hideDelayed:)
               withObject:[NSNumber numberWithBool:animated]
               afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated {
    [self hideWithAnimation:[animated boolValue]];
}

#pragma mark - UI animation

- (void)addDimAnimationToView:(UIView *)view withDimMode:(PSDimMode)dimMode {
    [UIView animateWithDuration:0.3 animations:^{
        if (dimMode == PSDimModeDown) {
            view.alpha = 0.0;
        } else {
            view.alpha = 1.0;
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            if (dimMode == PSDimModeDown) {
                [view setHidden:YES];
            } else {
                [view setHidden:NO];
            }
        }
    }];
}

#pragma mark - Layout

- (void)setupDefaultsSizes {
    // size
    _width = 100;
    _height = 44;
    _margin = 10;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // resize the label
    [_label setFrame: self.bounds];
}

/**
 * Center the coach mark over the view
 */
- (CGRect)centerCoachMarkAboveView:(CGRect)viewBounds {
    CGFloat xPoint = viewBounds.origin.x + (viewBounds.size.width / 2) - (_width / 2);
    CGFloat yPoint = viewBounds.origin.y - (_height + _margin);
    
    return CGRectMake(xPoint, yPoint, _width, _height);
}

- (CGRect)centerCoachMarkInView:(CGRect)viewBounds {
    CGFloat xPoint = (viewBounds.size.width / 2) - (_width / 2);
    CGFloat yPoint = (viewBounds.size.height / 2) - (_height / 2);
    
    return CGRectMake(xPoint, yPoint, _width, _height);
}

- (void)updateCoachMarkPosition {
    switch (self.mode) {
        case PSCoachMarkModeAbove:
            [self setFrame:[self centerCoachMarkAboveView:self.superview.bounds]];
            break;
            
        default:
            [self setFrame:[self centerCoachMarkInView:self.superview.bounds]];
            break;
    }
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"width", @"height", @"margin", @"labelText", @"markColor", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIForKeypath:keyPath];
    });
}

- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"width"] || [keyPath isEqualToString:@"height"] || [keyPath isEqualToString:@"margin"]) {
        [self updateCoachMarkPosition];
    } else if ([keyPath isEqualToString:@"labelText"]) {
        _label.attributedText = _labelText;
    }
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

@end
