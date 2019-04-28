//
//  SearchNameViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "SearchNameViewController.h"
#import "SearchTableViewCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SearchViewController.h"
#import "ScoolMapViewController.h"
#import "HomeViewController.h"
#import "ElectronicMapViewController.h"

@interface SearchNameViewController ()
{
    NSUserDefaults *defaults;
}
@end

@implementation SearchNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.rowHeight = 50;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nameArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[defaults objectForKey:@"search"] intValue] == 0)
    {
        MKMapItem * item=self.nameArr[indexPath.row];
        [defaults setDouble:item.placemark.coordinate.latitude forKey:@"schoolMapLa"];
        [defaults setDouble:item.placemark.coordinate.longitude forKey:@"schoolMapLo"];
        [defaults setValue:item.name forKey:@"schoolMapNa"];
        [defaults setValue:@"1" forKey:@"schoolMapType"];
        ScoolMapViewController *search = [[ScoolMapViewController alloc] init];
        search.title = NSLocalizedString(@"set_school_location", nil);
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[search class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
        
    }
    else if([[defaults objectForKey:@"search"] intValue] == 1)
    {
        MKMapItem * item=self.nameArr[indexPath.row];
        [defaults setDouble:item.placemark.coordinate.latitude forKey:@"homeMapLa"];
        [defaults setDouble:item.placemark.coordinate.longitude forKey:@"homeMapLo"];
        [defaults setValue:item.name forKey:@"homeMapNa"];
        [defaults setValue:@"1" forKey:@"homeMapType"];
        HomeViewController *search = [[HomeViewController alloc] init];
        search.title = NSLocalizedString(@"set_home_location", nil);
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[search class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
    else
    {
        MKMapItem * item=self.nameArr[indexPath.row];
        [defaults setDouble:item.placemark.coordinate.latitude forKey:@"eleMapLa"];
        [defaults setDouble:item.placemark.coordinate.longitude forKey:@"eleMapLo"];
        [defaults setValue:item.name forKey:@"eleMapNa"];
        [defaults setValue:@"1" forKey:@"eleMapType"];
        ElectronicMapViewController *search = [[ElectronicMapViewController alloc] init];
        search.title = NSLocalizedString(@"fence", nil);
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[search class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"Search";
    
    UINib *nib = [UINib nibWithNibName:@"SearchTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[SearchTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
        
    }
    
    MKMapItem * item=[self.nameArr objectAtIndex:indexPath.row];
    cell.nameLabel.text=item.name;
    
    return cell;
    
}

- (void)setviewinfo
{
    [defaults setObject:@"0" forKey:@"schoolMapType"];
    [defaults setObject:@"0" forKey:@"homeMapType"];

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
