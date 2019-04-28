//
//  heartViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "heartViewController.h"
#import "StepTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "DeviceModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "EditHeadAndNameViewController.h"
#import "STAlertView.h"
#import "DXAlertView.h"
#import "LoginViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "WatchFirmwareViewController.h"
#import "JSON.h"
#import "OMGToast.h"

extern NSString *str_heartnum;
@interface heartViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSUserDefaults *defaults;
    NSArray *titleArray;
    
    NSMutableArray *array;
    DeviceModel *model;
    DataManager *manager;
    UIAlertView *alertView;
    NSIndexPath *_indexPath;
}
@end

@implementation heartViewController

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"watch_heart_num", nil),NSLocalizedString(@"结果：", nil), nil];

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView.hidden = YES;
    self.tableView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = NO;

    //设置tableView不能滚动
    [self.tableView setScrollEnabled:NO];
    //在此处调用一下就可以啦 ：此处假设tableView的name叫：tableView
    [self setExtraCellLineHidden:self.tableView];
}

//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"cell1";
    NSString *hear_number = [[NSString alloc] init];
    
    if(str_heartnum.length==0)
    {
        hear_number=@"68";
    }
    else{
        hear_number = [NSString stringWithString: str_heartnum];
    }
    
    UINib *nib = [UINib nibWithNibName:@"StepTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    StepTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[StepTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    cell.title.text = [titleArray objectAtIndex:indexPath.row];
    
    if(indexPath.row == 0)
    {
        cell.listLabel.text = [NSString stringWithFormat:@"%@ %@",hear_number,NSLocalizedString(@"watch_heart_mon", nil)];
    }
    else if(indexPath.row == 1)
    {
        cell.listLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"正常", nil)];
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self.navigationController.navigationBar setHidden:NO];
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
