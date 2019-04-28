//
//  MeTabViewController.m
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/1/9.
//  Copyright © 2019年 HH. All rights reserved.
//

#import "MeTabViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "APPSetViewController.h"
#import "QuestionAndHelpViewController.h"
#import "FeedbackViewController.h"
#import "AboutWatchViewController.h"
#import "BabyListViewController.h"
#import "BabySelectViewController.h"

@interface MeTabViewController ()

@end

@implementation MeTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.navigationItem.title = NSLocalizedString(@"me", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initViews];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.rdv_tabBarController setTabBarHidden:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:NO];
}

-(void)initViews{
    self.lbMainPage.text = NSLocalizedString(@"me_main_page", nil);
    self.lbCollection.text = NSLocalizedString(@"me_collection", nil);
    self.lbAttent.text = NSLocalizedString(@"me_attent", nil);
    self.lbFans.text = NSLocalizedString(@"me_fans", nil);
    self.lbFirst.text = NSLocalizedString(@"home_type", nil);
    self.lbSecond.text = NSLocalizedString(@"home_type19", nil);
    self.lbThird.text = NSLocalizedString(@"home_type20", nil);
    self.lbFourth.text = NSLocalizedString(@"home_type21", nil);
    self.lbFifth.text = NSLocalizedString(@"home_type22", nil);
    self.lbSixth.text = NSLocalizedString(@"home_type15", nil);
    self.lbCollectionCount.text = @"0";
    self.lbAttentCount.text = @"0";
    self.lbFansCount.text = @"0";
}

-(IBAction)firstAction:(id)sender{
    BabyListViewController *baby = [[BabyListViewController alloc] init];
    baby.title = NSLocalizedString(@"babyinfo", nil);
    [self.navigationController pushViewController:baby animated:YES];
}

-(IBAction)secondAction:(id)sender{
    AboutWatchViewController *about = [[AboutWatchViewController alloc] init];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"deviceModelType"] == 1){
        about.title = NSLocalizedString(@"about_watch_d8", nil);
    }else{
        about.title = NSLocalizedString(@"about_watch", nil);
    }
    [self.navigationController pushViewController:about animated:YES];
}

-(IBAction)thirdAction:(id)sender{
    BabySelectViewController *baby = [[BabySelectViewController alloc] init];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"deviceModelType"] == 1){
        baby.title = NSLocalizedString(@"select_watch_d8", nil);
    }else{
        baby.title = NSLocalizedString(@"select_watch", nil);
    }
    [self.navigationController pushViewController:baby animated:YES];
}

-(IBAction)fourthAction:(id)sender{
    QuestionAndHelpViewController *vc = [[QuestionAndHelpViewController alloc] init];
    vc.title = NSLocalizedString(@"Help_str", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)fifthAction:(id)sender{
    FeedbackViewController *pro = [[FeedbackViewController alloc] init];
    pro.title = NSLocalizedString(@"problem_feedback", nil);
    [self.navigationController pushViewController:pro animated:YES];
}

-(IBAction)sixthAction:(id)sender{
    APPSetViewController *appset = [[APPSetViewController alloc] init];
    appset.title = NSLocalizedString(@"setting", nil);
    [self.navigationController pushViewController:appset animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
