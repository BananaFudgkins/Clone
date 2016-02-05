//
//  NotificationListTableViewCell.h
//  
//
//  Created by Deja Jackson on 7/26/15.
//
//

#import <UIKit/UIKit.h>
#import <DXTimestampLabel.h>

@interface NotificationListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) IBOutlet UILabel *notificationContentLabel;
@property (strong, nonatomic) IBOutlet DXTimestampLabel *dateLabel;

@end
