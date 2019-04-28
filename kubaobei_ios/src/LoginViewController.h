//
//  LoginViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *resignButton;
@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginTips;

@end
