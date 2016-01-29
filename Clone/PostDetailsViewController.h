//
//  PostDetailsViewController.h
//  
//
//  Created by Deja Jackson on 7/6/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PostDetailsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *profilepicImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postcontentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) PFObject *post;

@end
