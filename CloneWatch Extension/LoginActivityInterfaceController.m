//
//  LoginActivityInterfaceController.m
//  Clone
//
//  Created by Deja Jackson on 11/7/15.
//  Copyright © 2015 Deja Jackson. All rights reserved.
//

#import "LoginActivityInterfaceController.h"

@interface LoginActivityInterfaceController ()

@end

@implementation LoginActivityInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self.loginActivity setImageNamed:@"Activity"];
    [self.loginActivity startAnimatingWithImagesInRange:NSMakeRange(0, 15) duration:1.0 repeatCount:0];
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



