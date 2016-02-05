//
//  TermsViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/17/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "TermsViewController.h"
#import "KVNProgress.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.termsWebView.delegate = self;
    self.termsWebView.scalesPageToFit = YES;
    NSURL *url = [NSURL URLWithString:@"http://www.pixelbypixelgames.com/clones-terms-of-use.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.termsWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [KVNProgress showErrorWithStatus:error.localizedFailureReason];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [KVNProgress show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [KVNProgress dismiss];
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
