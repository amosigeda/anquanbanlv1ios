//
//  StreetViewViewController.m
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/3/11.
//  Copyright © 2019年 HH. All rights reserved.
//

#import "StreetViewViewController.h"
#import "JSON.h"
@import AFNetworking;

@interface StreetViewViewController ()<UIWebViewDelegate>  

@end

@implementation StreetViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.webView.scrollView.bounces = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 超时时间
    manager.requestSerializer.timeoutInterval = 60;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"https://apis.map.qq.com/ws/streetview/v1/getpano?location=%@,%@&radius=100&key=77VBZ-TZHCR-YMUW4-W2HOO-UL4N3-AEBII",self.lat,self.lng] parameters:nil error:nil];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [[manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(responseObject){ // 请求成功
            NSString *result = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSError *error = nil;
            // 解析成json数据
            id object = [parser objectWithString:result error:&error];
            if (!error && object) {
                NSString *pano = [[object objectForKey:@"detail"] objectForKey:@"id"];
                if(pano.length){
                    NSURLRequest *streetViewRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://jiejing.qq.com/#pano=%@&heading=352&pitch=5&poi=detail&addr=1&minimap=0&region=0&search=0&direction=1&isappinstalled=-1",pano]]];
                    [self.webView loadRequest:streetViewRequest];
                }
            }
        }
    }] resume];
}

- (void)setviewinfo{
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
