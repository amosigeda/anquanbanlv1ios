//
//  OperateModeViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "OperateModeViewController.h"
#import "LightTimeTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DeviceModel.h"
#import "DeviceSetModel.h"
#import "LoginViewController.h"

@interface OperateModeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *titleArray;
    NSMutableArray *array;
    DeviceSetModel *model;
    NSUserDefaults *defaults;
    NSIndexPath *_indexPath;
    DeviceModel *deviceModel;
    DataManager *manager ;
}
@end

@implementation OperateModeViewController

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
    
    titleArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"operating_mode_intelligent", nil),NSLocalizedString(@"operating_mode_follow", nil),NSLocalizedString(@"operating_mode_normal", nil),NSLocalizedString(@"operating_mode_savepower", nil),nil];
    
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    self.tableVIew.rowHeight = 50;
    
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"cell1";
    
    UINib *nib = [UINib nibWithNibName:@"LightTimeTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    LightTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[LightTimeTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    cell.titleLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.gouImage.hidden = YES;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableVIew reloadData];
    LightTimeTableViewCell *cell = [self.tableVIew cellForRowAtIndexPath:indexPath];
    cell.gouImage.hidden = NO;
    
    if(indexPath.row == 0)
    {
        [defaults setObject:@"0" forKey:@"Dingwei_Mode"];
        [defaults setObject:@"0" forKey:@"Dingwei_Time"];
    }
    else if(indexPath.row == 1)
    {
        [defaults setObject:@"1" forKey:@"Dingwei_Mode"];
        [defaults setObject:@"3" forKey:@"Dingwei_Time"];
    }
    else if(indexPath.row == 2)
    {
        [defaults setObject:@"1" forKey:@"Dingwei_Mode"];
        [defaults setObject:@"10" forKey:@"Dingwei_Time"];
    }
    else if(indexPath.row == 3)
    {
        [defaults setObject:@"1" forKey:@"Dingwei_Mode"];
        [defaults setObject:@"60" forKey:@"Dingwei_Time"];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    DataManager *manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    [defaults setObject:model.locationMode forKey:@"Dingwei_Mode"];
    [defaults setObject:model.locationTime forKey:@"Dingwei_Time"];
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
