//
//  ProfilePageInterfaceController.h
//  
//
//  Created by Deja Jackson on 8/6/15.
//
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ProfilePageInterfaceController : WKInterfaceController

@property (strong, nonatomic) IBOutlet WKInterfaceImage *profilePicInterfaceImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *usernameInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *realNameInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *bioInterfaceLabel;

@end
