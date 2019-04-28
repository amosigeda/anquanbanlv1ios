//
//  BabyHeartTableViewCell.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BabyHeartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *betweenLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeHeadLabel;

@property (weak, nonatomic) IBOutlet UIButton *headButton;
@property (weak, nonatomic) IBOutlet UIImageView *headView;

@end
