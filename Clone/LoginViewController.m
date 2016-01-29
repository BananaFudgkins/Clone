//
//  LoginViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/11/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login logo"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.logInView.logo = logoImageView;
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    self.logInView.backgroundColor = UIColorFromRGB(0x1c9ef1);
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundColor:[UIColor colorWithRed:0.38 green:0.42 blue:0.45 alpha:1]];
    self.logInView.signUpButton.layer.cornerRadius = 5;
}
- (IBAction)loginPressed:(UIButton *)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.logInView.usernameField) {
        textField.text = textField.text.lowercaseString;
        return YES;
    }
    return YES;
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
