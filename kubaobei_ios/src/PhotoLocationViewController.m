//
//  PhotoLocationViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "PhotoLocationViewController.h"
#import "PhotoAnnotationView.h"
#import "WatchAnnotationView.h"

@interface PhotoLocationViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@end

@implementation PhotoLocationViewController

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
    
    self.mapView.delegate = self;
    
    [ self.mapView setZoomEnabled:YES];
    [ self.mapView setScrollEnabled:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
        self.mapView.showsScale = YES;
    }
    
    self.address_Label.text = self.address;
    self.source_Label.text =[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"source", nil),self.source];
    self.time_Label.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"time", nil),self.time] ;

    
    MKCoordinateRegion theRegion;
    MKCoordinateSpan theSpan;

    theRegion.center= CLLocationCoordinate2DMake(self.lat.doubleValue, self.lng.doubleValue);
    theSpan.latitudeDelta=0.002;
    //
    theSpan.longitudeDelta=0.002;
    theRegion.span=theSpan;
    
    [self.mapView setRegion:theRegion];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    if(annotation)
    {
        [self.mapView removeAnnotation:annotation];
    }
    annotation.coordinate = CLLocationCoordinate2DMake(self.lat.doubleValue, self.lng.doubleValue);
    [self.mapView addAnnotation:annotation];

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //大头针视图
    //注意：为了提高显示效率。显示大头针加入复用机制
    static NSString *annotationId = @"4rrrn";
    WatchAnnotationView *pin = (WatchAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
    if(pin == nil){
        
        pin = [[WatchAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        
      //  [pin createUI:self.image];
    }
    pin.image = [UIImage imageNamed:@"location_watch"];
    
    return pin;
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
