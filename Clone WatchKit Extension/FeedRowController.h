//
//  FeedRowController.h
//  
//
//  Created by Deja Jackson on 8/6/15.
//
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface FeedRowController : NSObject

@property (strong, nonatomic) IBOutlet WKInterfaceImage *profilePicInterfaceImage;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *usernameInterfaceLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *postContentInterfaceLabel;

@end
