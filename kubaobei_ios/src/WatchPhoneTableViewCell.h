//
//  WatchPhoneTableViewCell.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchPhoneTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *listLabel;
-(void)setIntroductionText:(NSString*)text;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headView;

- (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width;
@end
