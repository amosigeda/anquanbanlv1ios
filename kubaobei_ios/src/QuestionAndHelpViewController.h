//
//  QuestionAndHelpViewController.h
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/3/20.
//  Copyright © 2019年 HH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YUFoldingTableView.h"

@interface QuestionAndHelpViewController : UIViewController<YUFoldingTableViewDelegate>
@property (nonatomic, assign) YUFoldingSectionHeaderArrowPosition arrowPosition;

@property (nonatomic, assign) NSInteger index;

@end
