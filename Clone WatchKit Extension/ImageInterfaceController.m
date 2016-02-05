//
//  ImageInterfaceController.m
//  
//
//  Created by Deja Jackson on 8/7/15.
//
//

#import "ImageInterfaceController.h"

@interface ImageInterfaceController ()

@end

@implementation ImageInterfaceController

- (void)awakeWithContext:(NSData *)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    
    [self.postInterfaceImage setImageData:context];
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



