//
//  PostDetailsViewController.m
//  
//
//  Created by Deja Jackson on 7/6/15.
//
//

#import "PostDetailsViewController.h"
#import "KVNProgress.h"

@interface PostDetailsViewController ()

@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profilepicImageView.layer.cornerRadius = self.profilepicImageView.frame.size.width / 2;
    self.profilepicImageView.clipsToBounds = YES;
    
    // Check if the user of this post has a profile photo.
    PFUser *postUser = [self.post objectForKey:@"user"];
    PFFile *profilePicFile = [postUser objectForKey:@"profilepic"];
    if (profilePicFile) {
        [profilePicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.profilepicImageView.image = [UIImage imageWithData:data];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get profile photo", @"error")];
            }
        }];
    }
    
    if (self.isModal == YES) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
    }
    
    // Set the username label's text to this post's user's username. Yeah that's a lot of ownership.
    self.usernameLabel.text = [[self.post objectForKey:@"user"] objectForKey:@"username"];
    
    // Set the content text view's text to be the content of the post. If there isn't any, well the text view will just be empty
    if ([self.post objectForKey:@"content"]) {
        self.postcontentTextView.text = [self.post objectForKey:@"content"];
    }
    
    // Set the post image view to the image of the post.
    PFFile *imageFile = [self.post objectForKey:@"image"];
    if (imageFile) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.postImageView.image = [UIImage imageWithData:data];
            } else {
                [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get post's image", @"error")];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closePressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float)i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
