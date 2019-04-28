//
//  WatchSetAlarmViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatchModel.h"
@interface WatchSetAlarmViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *list_Label;
@property (nonatomic,strong) NSArray<WatchModel *>* watchModelArr;
@end
