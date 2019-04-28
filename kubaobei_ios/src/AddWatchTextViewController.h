//
//  AddWatchTextViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SYQRCodeViewController.h"

@interface AddWatchTextViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *IMEITextField;
@property (weak, nonatomic) IBOutlet UILabel *list_Label;
@property (weak, nonatomic) IBOutlet UIButton *bindIng;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *prolist_Label;

@property (weak, nonatomic) IBOutlet UILabel *pc_List_Label;
@property (weak, nonatomic) IBOutlet UITextField *input_TextField;
@property (weak, nonatomic) IBOutlet UIButton *cancel_Btn;
@property (weak, nonatomic) IBOutlet UIButton *ok_Btn;
@property (nonatomic, copy) void (^SYQRCodeSuncessBlock) (SYQRCodeViewController *,NSString *);//扫描结果

@end
