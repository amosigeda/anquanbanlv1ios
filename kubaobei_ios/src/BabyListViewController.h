//
//  BabyListViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ZHPickView.h"
@interface BabyListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)ZHPickView *pickview;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property(nonatomic,strong)NSIndexPath *indexPath;
@end
