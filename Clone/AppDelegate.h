//
//  AppDelegate.h
//  Clone
//
//  Created by Deja Jackson on 6/11/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

