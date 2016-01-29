//
//  FeedRowController.h
//  Clone
//
//  Created by Deja Jackson on 10/26/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface FeedRowController : NSObject

@property (strong, nonatomic) IBOutlet WKInterfaceImage *profilePicInterfaceImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *usernameInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *postContentInterfaceLabel;

@end
