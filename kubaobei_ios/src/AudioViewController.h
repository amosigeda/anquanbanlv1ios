//
//  AudioViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

typedef enum {
    
    kMessageFrom=0,
    kMessageTo
    
}ChartMessageType;

#import <UIKit/UIKit.h>
#import "MACCustomTextField.h"
//#import "UITextView+WZB.h"
#import "YZInputView.h"
@interface AudioViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *speakButton;
@property (weak, nonatomic) IBOutlet UILabel *speakLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
//@property (weak, nonatomic) IBOutlet MACCustomTextField *textField;
@property (weak, nonatomic) IBOutlet YZInputView *textView;



//@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,assign) ChartMessageType messageType;


@end
