//
//  PsswordSetViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PsswordSetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *againPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property(nonatomic,copy) NSString *imeiStr;

@end
