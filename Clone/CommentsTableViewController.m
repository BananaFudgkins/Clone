//
//  CommentsTableViewController.m
//  
//
//  Created by Deja Jackson on 7/19/15.
//
//

#import "CommentsTableViewController.h"
#import "CommentsTextView.h"
#import "KVNProgress.h"
#import "OtherProfilePageViewController.h"

@interface CommentsTableViewController ()

@end

@implementation CommentsTableViewController {
    NSMutableArray *commentsArray;
    NSMutableArray *searchResultsArray;
    NSMutableArray *usersArray;
    UITapGestureRecognizer *textLabelRecognizer;
}

#pragma mark - Initializer

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    return self;
}

// Uncomment if you are using Storyboard.
// You don't need to call initWithCoder: anymore
+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do view setup here.
    self.shouldScrollToBottomAfterKeyboardShows = YES;
    self.shakeToClearEnabled = YES;
    
    self.textView.placeholder = NSLocalizedString(@"Add a comment...", @"comment");
    self.textView.placeholderColor = [UIColor lightGrayColor];
    self.textView.returnKeyType = UIReturnKeySend;
    
    [self.rightButton setTitle:NSLocalizedString(@"Send", @"send") forState:UIControlStateNormal];
    [self registerPrefixesForAutoCompletion:@[@"@"]];
    
    self.tableView.estimatedRowHeight = 34.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.autoCompletionView.rowHeight = 34.0;
    
    [self loadComments];
    
    if (self.isModal == YES) {
        UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
        self.navigationItem.leftBarButtonItem = closeButtonItem;
    }
    
    textLabelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textLabelTapped:)];
    
    PFQuery *userQuery = [PFUser query];
    userQuery.limit = 20;
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            usersArray = objects.mutableCopy;
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get list of users", @"couldn't")];
        }
        if (objects.count == 0) {
            userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
    }];
    
}

- (void)loadComments {
    // Load the comments from Parse for this post.
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingIndicator];
    
    PFQuery *commentsQuery = [PFQuery queryWithClassName:@"Comments"];
    [commentsQuery whereKey:@"post" equalTo:self.postObject];
    [commentsQuery orderByDescending:@"createdAt"];
    [commentsQuery includeKey:@"user"];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            commentsArray = objects.mutableCopy;
            [loadingIndicator stopAnimating];
            self.navigationItem.rightBarButtonItem = nil;
            [self.tableView reloadData];
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get comments", @"error")];
        }
    }];
}

- (IBAction)closePressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SLKTextViewController Events

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status
{
    // Notifies the view controller that the keyboard changed status.
    // Calling super does nothing
}

- (void)textWillUpdate
{
    // Notifies the view controller that the text will update.
    // Calling super does nothing
    
    [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated
{
    // Notifies the view controller that the text did update.
    // Must call super
    
    [super textDidUpdate:animated];
}

- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [super textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if ([text isEqualToString:@"\n"]) {
        [self saveComment];
        return NO;
    }
    return YES;
}

- (BOOL)canPressRightButton
{
    // Asks if the right button can be pressed
    
    return [super canPressRightButton];
}

- (void)didPressRightButton:(id)sender
{
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    // Must call super
    
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    [self saveComment];
    
    [super didPressRightButton:sender];
}

- (void)saveComment {
    
    PFObject *comment = [PFObject objectWithClassName:@"Comments"];
    comment[@"user"] = [PFUser currentUser];
    comment[@"content"] = self.textView.text;
    comment[@"post"] = self.postObject;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            self.navigationItem.title = NSLocalizedString(@"Sending...", @"sending");
            UIActivityIndicatorView *progressIndicator = [[UIActivityIndicatorView alloc] init];
            progressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            [progressIndicator startAnimating];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:progressIndicator];
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't send comment", @"error")];
        }
        if (succeeded) {
            if ([self.textView isFirstResponder]) {
                [self.textView resignFirstResponder];
            }
            self.navigationItem.title = NSLocalizedString(@"Comments", @"comments");
            self.navigationItem.rightBarButtonItem = nil;
            if ([[[self.postObject objectForKey:@"user"] objectForKey:@"pushcomments"] isEqualToNumber:[NSNumber numberWithBool:YES]] && [self.postObject objectForKey:@"user"] != [PFUser currentUser]) {
                PFPush *commentPush = [[PFPush alloc] init];
                PFQuery *installationQuery = [PFInstallation query];
                [installationQuery whereKey:@"user" equalTo:[self.postObject objectForKey:@"user"]];
                [commentPush setQuery:installationQuery];
                NSString *message = [NSString stringWithFormat:@"%@ commented on your post: \"%@\"", [[PFUser currentUser] username], [comment objectForKey:@"content"]];
                [commentPush setData:@{@"alert": message, @"badge" :@"Increment", @"category":@"Comment", @"post":self.postObject}];
                [commentPush sendPushInBackground];
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
            UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
            
            [self.tableView beginUpdates];
            [commentsArray insertObject:comment atIndex:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
            
            if (self.postObject[@"user"] == [PFUser currentUser] && comment[@"user"] != [PFUser currentUser]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"usercommented" object:comment userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:commentsArray.count + 1] forKey:@"comment"]];
            }
            
            if ([self.postObject objectForKey:@"user"] != [PFUser currentUser]) {
                PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                notification[@"foruser"] = [self.postObject objectForKey:@"user"];
                notification[@"fromuser"] = [PFUser currentUser];
                notification[@"type"] = @"Comment";
                NSString *notificationContent = [NSString stringWithFormat:@"%@ commented on your post: \"%@\"", [[PFUser currentUser] username], [comment objectForKey:@"content"]];
                notification[@"content"] = notificationContent;
                [notification saveInBackground];
            }
        }
    }];
}

/*
// Uncomment these methods for aditional events
- (void)didPressLeftButton:(id)sender
{
    // Notifies the view controller when the left button's action has been triggered, manually.
 
    [super didPressLeftButton:sender];
}
 
- (id)keyForTextCaching
{
    // Return any valid key object for enabling text caching while composing in the text view.
    // Calling super does nothing
}

- (void)didPasteMediaContent:(NSDictionary *)userInfo
{
    // Notifies the view controller when a user did paste a media content inside of the text view
    // Calling super does nothing
}

- (void)willRequestUndo
{
    // Notification about when a user did shake the device to undo the typed text
 
    [super willRequestUndo];
}
*/

#pragma mark - SLKTextViewController Edition

// Uncomment these methods to enable edit mode
- (void)didCommitTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
 
    [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender
{
    // Notifies the view controller when tapped on the left "Cancel" button
 
    [super didCancelTextEditing:sender];
}

#pragma mark - SLKTextViewController Autocompletion

// Uncomment these methods to enable autocompletion mode
- (BOOL)canShowAutoCompletion
{
    // Asks of the autocompletion view should be shown
    
    [searchResultsArray removeAllObjects];
    
    if([self.foundPrefix isEqualToString:@"@"]) {
        if (self.foundWord.length > 0) {
            searchResultsArray = [usersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username BEGINSWITH[c] %@", self.foundWord]].mutableCopy;
        }
    }
 
    return searchResultsArray.count > 0;
}

- (CGFloat)heightForAutoCompletionView
{
    // Asks for the height of the autocompletion view
 
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cellHeight * searchResultsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.autoCompletionView) {
        return 34.0;
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Returns the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Returns the number of rows in the section.
    
    if ([tableView isEqual:self.autoCompletionView]) {
        return searchResultsArray.count;
    }
    
    return commentsArray.count;
}

// Uncomment these methods to configure the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    cell.transform = self.tableView.transform;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([tableView isEqual:self.tableView]) {
        PFObject *comment = commentsArray[indexPath.row];
        cell.detailTextLabel.text = [comment objectForKey:@"content"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0];
        cell.textLabel.textColor = UIColorFromRGB(0x1c9ef1);
        cell.textLabel.text = [[comment objectForKey:@"user"] objectForKey:@"username"];
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.userInteractionEnabled = YES;
    } else if ([tableView isEqual:self.autoCompletionView]) {
        cell.transform = self.autoCompletionView.transform;
        PFUser *searchedUser = searchResultsArray[indexPath.row];
        cell.textLabel.text = searchedUser.username;
    }
    return cell;
}

- (UIView *)superviewOfType:(Class)superviewClass forView:(UIView *)view {
    if (view.superview != nil) {
        if ([view.superview isKindOfClass:superviewClass]) {
            return view.superview;
        } else {
            return [self superviewOfType:superviewClass forView:view.superview];
        }
    }
    return nil;
}

- (IBAction)textLabelTapped:(UITapGestureRecognizer *)sender {
    /*
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForRowAtPoint:location];
    PFObject *comment = commentsArray[selectedIndexPath.row];
    OtherProfilePageViewController *profilePage = [self.storyboard instantiateViewControllerWithIdentifier:@"otheruser"];
    profilePage.userToQuery = [comment objectForKey:@"user"];
    [self.navigationController pushViewController:profilePage animated:YES];
    */
}

#pragma mark - <UITableViewDelegate>

// Uncomment this method to handle the cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.autoCompletionView]) {
        
        PFUser *searchedUser = searchResultsArray[indexPath.row];
        
        [self acceptAutoCompletionWithString:searchedUser.username keepPrefix:YES];
        
    }
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.tableView.emptyDataSetDelegate = nil;
    self.tableView.emptyDataSetSource = nil;
}

@end
