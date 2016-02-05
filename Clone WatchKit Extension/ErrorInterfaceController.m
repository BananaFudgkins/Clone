//
//  ErrorInterfaceController.m
//  
//
//  Created by Deja Jackson on 8/6/15.
//
//

#import "ErrorInterfaceController.h"

@interface ErrorInterfaceController ()

@end

@implementation ErrorInterfaceController

- (void)awakeWithContext:(NSString *)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [self.errorDescriptionInterfaceLabel setText:context];
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



