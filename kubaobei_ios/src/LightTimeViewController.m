//
//  LightTimeViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "LightTimeViewController.h"
#import "LightTimeTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"

@interface LightTimeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    DataManager *manager;
    NSArray *titleArray;
    NSMutableArray *array;
    DeviceSetModel *model;
    NSUserDefaults *defaults;
    NSIndexPath *_indexPath;
}
@end

@implementation LightTimeViewController

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
    
    titleArray = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"5%@",NSLocalizedString(@"second", nil)],[NSString stringWithFormat:@"10%@",NSLocalizedString(@"second", nil)],[NSString stringWithFormat:@"15%@",NSLocalizedString(@"second", nil)],[NSString stringWithFormat:@"20%@",NSLocalizedString(@"second", nil)],[NSString stringWithFormat:@"30%@",NSLocalizedString(@"second", nil)],[NSString stringWithFormat:@"60%@",NSLocalizedString(@"second", nil)], nil];
    
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    self.tableVIew.rowHeight = 40;
    self.tableVIew.tableFooterView = [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
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
        [defaults setObject:@"5" forKey:@"lightTime"];
    }
    else if(indexPath.row == 1)
    {
        [defaults setObject:@"10" forKey:@"lightTime"];

    }
    else if(indexPath.row == 2)
    {
        [defaults setObject:@"15" forKey:@"lightTime"];
        
    }
    else if(indexPath.row == 3)
    {
        [defaults setObject:@"20" forKey:@"lightTime"];
        
    }
    else if(indexPath.row == 4)
    {
        [defaults setObject:@"30" forKey:@"lightTime"];
        
    }
    else if(indexPath.row == 5)
    {
        [defaults setObject:@"60" forKey:@"lightTime"];
        
    }else{
        [defaults setObject:@"5" forKey:@"lightTime"];
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
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    [defaults setObject:model.BrightScreen forKey:@"lightTime"];

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
