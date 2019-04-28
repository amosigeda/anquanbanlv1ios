//
//  EditPhoneViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPhoneViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *yunyingshang;
@property (weak, nonatomic) IBOutlet UITextField *huafei;
@property (weak, nonatomic) IBOutlet UITextField *liuliang;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *Operator_Label;
@property (weak, nonatomic) IBOutlet UILabel *query_phone_Label;
@property (weak, nonatomic) IBOutlet UILabel *quer_nstructions_Lable;

@end
