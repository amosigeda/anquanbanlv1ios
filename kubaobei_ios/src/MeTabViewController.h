//
//  MeTabViewController.h
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/1/9.
//  Copyright © 2019年 HH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeTabViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *ivPortrait;
@property (weak, nonatomic) IBOutlet UILabel *lbMainPage;
@property (weak, nonatomic) IBOutlet UILabel *lbCollectionCount;
@property (weak, nonatomic) IBOutlet UILabel *lbCollection;
@property (weak, nonatomic) IBOutlet UILabel *lbAttentCount;
@property (weak, nonatomic) IBOutlet UILabel *lbAttent;
@property (weak, nonatomic) IBOutlet UILabel *lbFansCount;
@property (weak, nonatomic) IBOutlet UILabel *lbFans;

@property (weak, nonatomic) IBOutlet UILabel *lbFirst;
@property (weak, nonatomic) IBOutlet UILabel *lbSecond;
@property (weak, nonatomic) IBOutlet UILabel *lbThird;
@property (weak, nonatomic) IBOutlet UILabel *lbFourth;
@property (weak, nonatomic) IBOutlet UILabel *lbFifth;
@property (weak, nonatomic) IBOutlet UILabel *lbSixth;

- (IBAction)firstAction:(id)sender;
- (IBAction)secondAction:(id)sender;
- (IBAction)thirdAction:(id)sender;
- (IBAction)fourthAction:(id)sender;
- (IBAction)fifthAction:(id)sender;
- (IBAction)sixthAction:(id)sender;

@end
