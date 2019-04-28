//
//  ProblemFeedbackViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "ProblemFeedbackViewController.h"
#import "FeedbackViewController.h"


@interface ProblemFeedbackViewController ()
{
    NSUserDefaults *defaults;

}
@end

@implementation ProblemFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"showRight"];
    [defaults setObject:@"0" forKey:@"showLeft"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.feedback_Btn.backgroundColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
   

}



- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (IBAction)feedback:(id)sender {
    
    FeedbackViewController *vc = [[FeedbackViewController alloc] init];
    vc.title = @"意见反馈";
    [self.navigationController pushViewController:vc animated:YES];
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
