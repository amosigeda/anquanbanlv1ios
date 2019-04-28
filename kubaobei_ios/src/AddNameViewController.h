//
//  AddNameViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneshortLabel;

/** 判断是否为管理员号码的属性条件 */
@property (copy, nonatomic) NSString * bindNumber;

@end
