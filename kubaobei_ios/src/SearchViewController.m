//
//  SearchViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "SearchViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SearchTableViewCell.h"
#import "SearchNameViewController.h"
#import "ScoolMapViewController.h"
#import "DataManager.h"
#import "LocationModel.h"
#import "DeviceModel.h"
#import "HomeViewController.h"
#import "ElectronicMapViewController.h"

@interface SearchViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSArray * array;
    NSUserDefaults *defaults;
    NSMutableArray *nameArr;
    DataManager *manager;
    DeviceModel *deviceModel;
    LocationModel *locationModel;
    NSArray *deviceArray;
    NSMutableArray *locationArray;
    
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    nameArr = [[NSMutableArray alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
    locationArray = [[NSMutableArray alloc] init];
    deviceArray = [[NSMutableArray alloc] init];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.searchBar.delegate= self;
    self.searchBar.placeholder = NSLocalizedString(@"input_serach_address", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [UIView new];
    
    [self loadData];
    
    manager = [DataManager shareInstance];
    
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    locationArray = [manager isSelectLocationTable:deviceModel.DeviceID];
    locationModel = [locationArray objectAtIndex:0];
    if([deviceModel.DeviceType isEqualToString:@"2"])
    {
        self.watch_address_Label.text = NSLocalizedString(@"watch_location_d8", nil);
    }
    else{
        self.watch_address_Label.text = NSLocalizedString(@"watch_location", nil);
    }
    self.phone_address_label.text = NSLocalizedString(@"phone_location", nil);
    self.around_address_label.text = NSLocalizedString(@"nearby_school", nil);
}

- (void)loadData
{
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.myLocation, 5000, 5000);
//    //初始化一个检索请求对象
//    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
//    //设置检索参数
//    req.region=region;
//    //兴趣点关键字
//    req.naturalLanguageQuery=@"学校";
//    //初始化检索
//    MKLocalSearch * ser = [[MKLocalSearch alloc]initWithRequest:req];
//    //开始检索，结果返回在block中
//    [ser startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
//        //兴趣点节点数组
//        array = [NSArray arrayWithArray:response.mapItems];
//        for (int i=0; i<array.count; i++) {
//            MKMapItem * item=array[i];
//            MKPointAnnotation * point = [[MKPointAnnotation alloc]init];
//            point.title=item.name;
//            point.subtitle=item.phoneNumber;
//            point.coordinate=item.placemark.coordinate;
//            [nameArr addObject:item];
//            
//            
//            NSLog(@"%@",item.name);
//        }
//    }];
//    
//    [self.tableView reloadData];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.nameArr.count;
    
    
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


#pragma mark - searchdelegate

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return  YES;
}

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //当scope改变时调用
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"1");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"2");
    //初始化一个检索请求对象
    CLLocationCoordinate2D myLocation = CLLocationCoordinate2DMake([defaults doubleForKey:@"mylocationLa"], [defaults doubleForKey:@"mylocationLo"]);
    _myLocation = myLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation, 50000000000000, 500000000000000);
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
    //设置检索参数
    req.region=region;
    //兴趣点关键字
    req.naturalLanguageQuery= searchBar.text;
    //初始化检索
    MKLocalSearch * ser = [[MKLocalSearch alloc]initWithRequest:req];
    //开始检索，结果返回在block中
    [ser startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        //兴趣点节点数组
        NSArray * arr = [NSArray arrayWithArray:response.mapItems];
        for (int i=0; i<arr.count; i++) {
            MKMapItem * item=arr[i];
            MKPointAnnotation * point = [[MKPointAnnotation alloc]init];
            point.title=item.name;
            point.subtitle=item.phoneNumber;
            point.coordinate=item.placemark.coordinate;
            [nameArr addObject:item];
            NSLog(@"%@",item.name);
            
        }
        
        SearchNameViewController *search = [[SearchNameViewController alloc] init];
        
        search.title = NSLocalizedString(@"search_result", nil);
        search.nameArr = nameArr;
        
        [self.navigationController pushViewController:search animated:YES];
        
    }];
    
    [self.view endEditing:YES];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.la = @"dddd";
    MKMapItem * item=self.nameArr[indexPath.row];
    if([[defaults objectForKey:@"search"] intValue] == 0)
    {
        
        [defaults setDouble:item.placemark.coordinate.latitude forKey:@"schoolMapLa"];
        [defaults setDouble:item.placemark.coordinate.longitude forKey:@"schoolMapLo"];
        [defaults setValue:item.name forKey:@"schoolMapNa"];
        [defaults setValue:@"1" forKey:@"schoolMapType"];
        ScoolMapViewController *search = [[ScoolMapViewController alloc] init];
        search.title = NSLocalizedString(@"set_school_location", nil);
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else if([[defaults objectForKey:@"search"] intValue] == 1)
    {
//        MKMapItem * item=self.nameArr[indexPath.row];
        [defaults setDouble:item.placemark.coordinate.latitude forKey:@"homeMapLa"];
        [defaults setDouble:item.placemark.coordinate.longitude forKey:@"homeMapLo"];
        [defaults setValue:item.name forKey:@"homeMapNa"];
        [defaults setValue:@"1" forKey:@"homeMapType"];
//        HomeViewController *search = [[HomeViewController alloc] init];
        for (UIViewController *viewController in self.navigationController.viewControllers)
        {
            if ([viewController isKindOfClass:[HomeViewController class]])
            {
                HomeViewController *search = viewController;
                search.myLocation = item.placemark.coordinate;
                [self.navigationController popToViewController:search animated:YES];
                return;
            }
                
        }
            [self.navigationController popViewControllerAnimated:YES];
        
       
    }
    else
    {
//        MKMapItem * item=self.nameArr[indexPath.row];
        [defaults setDouble:item.placemark.coordinate.latitude forKey:@"eleMapLa"];
        [defaults setDouble:item.placemark.coordinate.longitude forKey:@"eleMapLo"];
        [defaults setValue:item.name forKey:@"eleMapName"];
        [defaults setValue:@"1" forKey:@"eleMapType"];

//        ElectronicMapViewController *search = [[ElectronicMapViewController alloc] init];
//        search.title = @"电子围栏";
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"3");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)showLocation:(id)sender {
    
    if([[defaults objectForKey:@"search"] intValue] == 0)
    {
        [defaults setValue:@"2" forKey:@"schoolMapType"];
        [defaults setDouble:locationModel.Latitude.doubleValue forKey:@"schoolMapLa"];
        [defaults setDouble:locationModel.Longitude.doubleValue forKey:@"schoolMapLo"];
        
        ScoolMapViewController *school = [[ScoolMapViewController alloc] init];
        school.title =NSLocalizedString(@"set_school_location", nil);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([[defaults objectForKey:@"search"] intValue] == 1)
    {
        [defaults setValue:@"2" forKey:@"homeMapType"];
        [defaults setDouble:locationModel.Latitude.doubleValue forKey:@"homeMapLa"];
        [defaults setDouble:locationModel.Longitude.doubleValue forKey:@"homeMapLo"];
        
        HomeViewController *school = [[HomeViewController alloc] init];
        school.title = NSLocalizedString(@"set_home_location", nil);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [defaults setValue:@"2" forKey:@"eleMapType"];
        [defaults setDouble:locationModel.Latitude.doubleValue forKey:@"eleMapLa"];
        [defaults setDouble:locationModel.Longitude.doubleValue forKey:@"eleMapLo"];
        
        ElectronicMapViewController *school = [[ElectronicMapViewController alloc] init];
        school.title = NSLocalizedString(@"fence", nil);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)showPhoneLocation:(id)sender {
    
    if([[defaults objectForKey:@"search"] intValue] == 0)
    {
        [defaults setValue:@"3" forKey:@"schoolMapType"];
        
        ScoolMapViewController *school = [[ScoolMapViewController alloc] init];
        school.title = NSLocalizedString(@"set_school_location", nil);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([[defaults objectForKey:@"search"] intValue] == 1)
    {
        [defaults setValue:@"3" forKey:@"homeMapType"];
        
        HomeViewController *school = [[HomeViewController alloc] init];
        school.title = NSLocalizedString(@"set_home_location", nil);
        [self.navigationController popViewControllerAnimated:YES];

    }
    else
    {
        [defaults setValue:@"3" forKey:@"eleMapType"];
        
        ElectronicMapViewController *school = [[ElectronicMapViewController alloc] init];
        school.title = NSLocalizedString(@"fence", nil);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setviewinfo
{
    [defaults setObject:@"0" forKey:@"schoolMapType"];
    [defaults setObject:@"0" forKey:@"homeMapType"];
    [defaults setObject:@"0" forKey:@"eleMapType"];

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
