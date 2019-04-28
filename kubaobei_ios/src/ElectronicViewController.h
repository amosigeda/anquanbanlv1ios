//
//  ElectronicViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ElectronicViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UISwitch *swip1;
@property (weak, nonatomic) IBOutlet UISwitch *swip2;
@property (weak, nonatomic) IBOutlet UISwitch *swip3;
@property (weak, nonatomic) IBOutlet UILabel *fence_label;
@property (weak, nonatomic) IBOutlet UILabel *in_fence_label;
@property (weak, nonatomic) IBOutlet UILabel *out_fence_Label;
@property (weak, nonatomic) IBOutlet UIButton *cancel_Btn;
@property (weak, nonatomic) IBOutlet UILabel *fence_switch_label;
@property (weak, nonatomic) IBOutlet UIButton *del_Btn;
@property (weak, nonatomic) IBOutlet UIButton *comfirm_Btn;
@property (weak, nonatomic) IBOutlet UILabel *check_fence_Label;
@property (weak, nonatomic) IBOutlet UILabel *alarm_mode_Label;

@end
