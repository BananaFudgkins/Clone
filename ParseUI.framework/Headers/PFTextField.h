/*
 *  Copyright (c) 2014, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>

#import <ParseUI/ParseUIConstants.h>

<<<<<<< HEAD
NS_ASSUME_NONNULL_BEGIN

/**
=======
PFUI_ASSUME_NONNULL_BEGIN

/*!
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 `PFTextFieldSeparatorStyle` bitmask specifies the style of the separators,
 that should be used for a given `PFTextField`.

 @see PFTextField
 */
typedef NS_OPTIONS(uint8_t, PFTextFieldSeparatorStyle){
<<<<<<< HEAD
    /** No separators are visible. */
    PFTextFieldSeparatorStyleNone = 0,
    /** Separator on top of the text field. */
    PFTextFieldSeparatorStyleTop = 1 << 0,
    /** Separator at the bottom of the text field. */
    PFTextFieldSeparatorStyleBottom = 1 << 1
};

/**
=======
    /*! No separators are visible. */
    PFTextFieldSeparatorStyleNone = 0,
    /*! Separator on top of the text field. */
    PFTextFieldSeparatorStyleTop = 1 << 0,
    /*! Separator at the bottom of the text field. */
    PFTextFieldSeparatorStyleBottom = 1 << 1
};

/*!
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 `PFTextField` class serves as a stylable subclass of `UITextField`.
 It includes styles that are specific to `ParseUI` framework and allows advanced customization.
 */
@interface PFTextField : UITextField

<<<<<<< HEAD
/**
 Separator style bitmask that should be applied to this textfield.

 Default: `PFTextFieldSeparatorStyleNone`
=======
/*!
 @abstract Separator style bitmask that should be applied to this textfield.

 @discussion Default: <PFTextFieldSeparatorStyleNone>
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

 @see PFTextFieldSeparatorStyle
 */
@property (nonatomic, assign) PFTextFieldSeparatorStyle separatorStyle;

<<<<<<< HEAD
/**
 Color that should be used for the separators, if they are visible.

 Default: `227,227,227,1.0`.
 */
@property (nullable, nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/**
=======
/*!
 @abstract Color that should be used for the separators, if they are visible.

 @discussion Default: `227,227,227,1.0`.
 */
@property (PFUI_NULLABLE_PROPERTY nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/*!
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 This method is a convenience initializer that sets both `frame` and `separatorStyle` for an instance of `PFTextField.`

 @param frame          The frame rectangle for the view, measured in points.
 @param separatorStyle Initial separator style to use.

 @return An initialized instance of `PFTextField` or `nil` if it couldn't be created.
 */
- (instancetype)initWithFrame:(CGRect)frame separatorStyle:(PFTextFieldSeparatorStyle)separatorStyle;

@end

<<<<<<< HEAD
NS_ASSUME_NONNULL_END
=======
PFUI_ASSUME_NONNULL_END
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
