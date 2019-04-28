//
//  FindTabViewController.m
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/1/9.
//  Copyright © 2019年 HH. All rights reserved.
//

#import "FindTabViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

@interface FindTabViewController ()<UIWebViewDelegate,UIScrollViewDelegate>

@end

@implementation FindTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.navigationItem.title = NSLocalizedString(@"find", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.webView.scrollView.bounces = NO;
//    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
//    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.webView.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//    self.webView.scalesPageToFit=YES;

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
