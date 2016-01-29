//
//  GlanceController.h
//  CloneWatch Extension
//
//  Created by Deja Jackson on 10/26/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

#import "Parse.h"

@interface GlanceController : WKInterfaceController <WCSessionDelegate>

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *headerInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *usernameInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *dateInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *postContentInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *postInterfaceImage;

@end
