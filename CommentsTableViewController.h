//
//  CommentsTableViewController.h
//  
//
//  Created by Deja Jackson on 7/19/15.
//
//

#import "SLKTextViewController.h"
#import <Parse/Parse.h>

@interface CommentsTableViewController : SLKTextViewController

@property (strong, nonatomic) PFObject *postObject;
@property (nonatomic) BOOL isModal;

@end
