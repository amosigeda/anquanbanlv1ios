//
//  MessageNotiViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageNotiViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UISwitch *on1;
@property (weak, nonatomic) IBOutlet UISwitch *on2;
@property (weak, nonatomic) IBOutlet UISwitch *on3;
@property (weak, nonatomic) IBOutlet UILabel *receive_new_message;
@property (weak, nonatomic) IBOutlet UILabel *sound_Label;
@property (weak, nonatomic) IBOutlet UILabel *ord_Label;
@property (weak, nonatomic) IBOutlet UIButton *save_Btn;

@end
