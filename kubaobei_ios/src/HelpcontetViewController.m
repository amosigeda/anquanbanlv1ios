//
//  HelpcontetViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "HelpcontetViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"

@interface HelpcontetViewController ()<UIWebViewDelegate,UIScrollViewDelegate>
{
    NSUserDefaults *defaults;
    NSMutableArray *deviceArray;
    DeviceModel *model;
    DataManager *manager;
}
@end

@implementation HelpcontetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];

    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];

    leftBtn.frame = CGRectMake(0, 0, 30, 30);

    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];

    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.webView.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.webView.scalesPageToFit=YES;
    
    manager = [DataManager shareInstance];
    deviceArray = [manager getAllFavourie];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    if(deviceArray.count == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
    }
    else
    {
        model = [deviceArray objectAtIndex:0];
    }
    
//    if([model.DeviceType isEqualToString:@"2"])
//    {
//        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://121.37.58.122/download/d8_app_help.jpg"]];
//        [self.webView loadRequest:request];
//    }
//    else
//    {
//        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://121.37.58.122/download/d9_app_help.jpg"]];
//        [self.webView loadRequest:request];
//    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    if (point.x > 0) {
        scrollView.contentOffset = CGPointMake(0, point.y);//这里不要设置为CGPointMake(0, 0)，这样我们在文章下面左右滑动的时候，就跳到文章的起始位置，不科学
    }
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
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
