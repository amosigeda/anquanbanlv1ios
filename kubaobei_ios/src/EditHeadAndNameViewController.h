//
//  EditHeadAndNameViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditHeadAndNameViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *cuntomLabel;
@property (weak, nonatomic) IBOutlet UIButton *fatherButton;
@property (weak, nonatomic) IBOutlet UIButton *matherButton;
@property (weak, nonatomic) IBOutlet UIButton *grandpaButton;
@property (weak, nonatomic) IBOutlet UIButton *grandmaButton;
@property (weak, nonatomic) IBOutlet UIButton *grandfatherButton;
@property (weak, nonatomic) IBOutlet UIButton *grandmotherButton;
@property (weak, nonatomic) IBOutlet UIButton *customButton;
@property (weak, nonatomic) IBOutlet UITextField *inputNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *fatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *motherLabel;
@property (weak, nonatomic) IBOutlet UILabel *grandPaLabel;

@property (weak, nonatomic) IBOutlet UILabel *grandMaLabel;
@property (weak, nonatomic) IBOutlet UILabel *grandfatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *grandmotherLabel;
@property (weak, nonatomic) IBOutlet UILabel *customLabel;

/** 判断是否为管理员号码的属性条件 */
@property (copy, nonatomic) NSString * bindNumber;

@end
