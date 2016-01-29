//
//  SearchTableViewController.h
//  Clone
//
//  Created by Deja Jackson on 6/13/15.
//  Copyright (c) 2015 Pixel by Pixel Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UIScrollView+EmptyDataSet.h"

@interface SearchTableViewController : UITableViewController <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UISearchDisplayDelegate, UISearchBarDelegate>

@end
