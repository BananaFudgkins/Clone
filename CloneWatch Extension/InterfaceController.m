//
//  InterfaceController.m
//  CloneWatch Extension
//
//  Created by Deja Jackson on 10/26/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    
    [self.feedInterfaceButton setBackgroundColor:UIColorFromRGB(0x1c9ef1)];
    [self.profileInterfaceButton setBackgroundColor:UIColorFromRGB(0x1c9ef1)];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        if (session.isReachable != YES) {
            WKAlertAction *cancel = [WKAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:WKAlertActionStyleCancel handler:^{}];
            [self presentAlertControllerWithTitle:NSLocalizedString(@"Apple Watch not paired", @"unpair") message:NSLocalizedString(@"Your Apple Watch is not paired with your iPhone. Please pair your Apple Watch with your iPhone and try again.", @"tryagain") preferredStyle:WKAlertControllerStyleAlert actions:@[cancel]];
        } else {
            [session sendMessage:[NSDictionary dictionaryWithObject:@"login" forKey:@"message"] replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                if (replyMessage[@"sessiontoken"]) {
                    // Log the user in after getting the session token.
                    [self presentControllerWithName:@"login" context:nil];
                    [PFUser becomeInBackground:replyMessage[@"sessiontoken"] block:^(PFUser *user, NSError *error) {
                        if (user) {
                            [self dismissController];
                        } else {
                            WKAlertAction *cancel = [WKAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:WKAlertActionStyleCancel handler:^{}];
                            [self presentAlertControllerWithTitle:NSLocalizedString(@"Login Error", @"error") message:error.userInfo[@"error"] preferredStyle:WKAlertControllerStyleAlert actions:@[cancel]];
                        }
                    }];
                } else {
                    // The user isn't logged in on their iPhone. Bring up a prompt saying so.
                    [self presentAlertControllerWithTitle:NSLocalizedString(@"Not logged in", @"login") message:NSLocalizedString(@"You are not logged in to Clone. Please login on your iPhone and try again.", @"login") preferredStyle:WKAlertControllerStyleAlert actions:@[]];
                }
            } errorHandler:^(NSError * _Nonnull error) {
                WKAlertAction *cancel = [WKAlertAction actionWithTitle:NSLocalizedString(@"OK", @"cancel") style:WKAlertActionStyleCancel handler:^{}];
                [self presentAlertControllerWithTitle:NSLocalizedString(@"Error", @"error") message:error.localizedDescription preferredStyle:WKAlertControllerStyleAlert actions:@[cancel]];
            }];
        }
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



