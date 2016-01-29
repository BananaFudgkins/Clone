//
//  InterfaceController.h
//  CloneWatch Extension
//
//  Created by Deja Jackson on 10/26/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "Parse.h"

@interface InterfaceController : WKInterfaceController <WCSessionDelegate>

@property (strong, nonatomic) IBOutlet WKInterfaceButton *feedInterfaceButton;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *profileInterfaceButton;

@end
