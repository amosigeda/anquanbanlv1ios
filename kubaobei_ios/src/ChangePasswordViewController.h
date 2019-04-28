//
//  ChangePasswordViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *againPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *showPass1;
@property (weak, nonatomic) IBOutlet UIButton *showPass2;



@end
