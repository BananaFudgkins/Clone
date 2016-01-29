//
//  SearchTableViewController.m
//  Clone
//
//  Created by Deja Jackson on 6/13/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import "SearchTableViewController.h"
#import "OtherProfilePageViewController.h"
#import "KVNProgress.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchTableViewController ()

@end

@implementation SearchTableViewController {
    NSMutableArray *searchResults;
    NSMutableArray *users;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    self.searchDisplayController.delegate = self;
    
    searchResults = [NSMutableArray arrayWithCapacity:users.count];
    
    PFQuery *userQuery = [PFUser query];
    userQuery.limit = 60;
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            users = objects.mutableCopy;
        } else {
            [KVNProgress showErrorWithStatus:NSLocalizedString(@"Couldn't get search results", @"error")];
        }
    }];
    
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    [searchResults removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@", searchText];
    searchResults = [users filteredArrayUsingPredicate:predicate].mutableCopy;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    }
    return 0;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],
                                 NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"A trending section usually goes here", @"title") attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName:paragraphStyle};
    
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Most social networks put a trending section here. Clone is still very young so there aren't really enough posts for there to be a trending section yet! Don't worry though, this trending section will come in a later update when more users sign up. For now though just tap that search bar to find people.", @"message") attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"Shrug"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        PFUser *searchedUser = searchResults[indexPath.row];
        OtherProfilePageViewController *otherProfile = [self.storyboard instantiateViewControllerWithIdentifier:@"otheruser"];
        otherProfile.userToQuery = searchedUser;
        [self.navigationController pushViewController:otherProfile animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        CALayer *cellImageLayer = cell.imageView.layer;
        [cellImageLayer setCornerRadius:22];
        [cellImageLayer setMasksToBounds:YES];
        
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        PFUser *searchedUser = searchResults[indexPath.row];
        cell.textLabel.text = searchedUser.username;
        PFFile *profilepicFile = [searchedUser objectForKey:@"profilepic"];
        if (profilepicFile) {
            [profilepicFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    cell.imageView.image = [UIImage imageWithData:data];
                    [cell setNeedsLayout];
                }
            }];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"User"];
            [cell setNeedsLayout];
        }
    }
    
    return cell;
}

- (void)dealloc {
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
