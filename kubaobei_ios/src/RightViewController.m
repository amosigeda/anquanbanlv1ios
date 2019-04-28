//
//  RightViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "RightViewController.h"
@interface RightViewController ()

@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:93/255.0 green:0 blue:96/255.0 alpha:1];
    // Do any additional setup after loading the view from its nib.
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(newThread) object:nil];
    [thread start];
    
}

- (void)newThread
{
    @autoreleasepool
    {
        //在当前Run Loop中添加timer，模式是默认的NSDefaultRunLoopMode
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ChangeCircle) userInfo:nil repeats:YES];
        //开始执行新线程的Run Loop
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)ChangeCircle
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessage:) name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSMS:) name:@"refreshSMS" object:nil];
    
}

-(void)refreshMessage:(NSNotification *)n
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        //Update UI in UI thread here
        if([n.object intValue] > 0)
        {
            self.messageCircle.hidden = NO;
        }
        else
        {
            self.messageCircle.hidden = YES;
        }
    });
}

-(void)refreshSMS:(NSNotification *)n
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if([n.object intValue] > 0)
        {
            self.SMSCircle.hidden = NO;
        }
        else
        {
            self.SMSCircle.hidden = YES;
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSettAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
}

- (IBAction)showBookView:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
}

- (IBAction)showWatchPhone:(id)sender {
    
    self.SMSCircle.hidden = YES;
      [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchPhone" object:self];
}

- (IBAction)showMessage:(id)sender {
    
    self.messageCircle.hidden = YES;
      [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessageRecord" object:self];
}

- (IBAction)showProblem:(id)sender {
    
      [[NSNotificationCenter defaultCenter] postNotificationName:@"showProblem" object:self];
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
