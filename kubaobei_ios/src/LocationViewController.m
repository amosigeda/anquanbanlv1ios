//
//  LocationViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "LocationViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DataManager.h"
#import "DeviceModel.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "WatchAnnotationView.h"
#import "LocationModel.h"
#import "ZFCDoubleBounceActivityIndicatorView.h"
#import "Common.h"
#import "LoginViewController.h"


@interface LocationViewController ()<MKMapViewDelegate,WebServiceProtocol,CLLocationManagerDelegate,UIAlertViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D locationPerson;
    MKCoordinateSpan theSpan;
    DataManager *manager;
    DeviceModel *deviceModel;
    DeviceSetModel *deviceSetModel;
    NSArray *array;
    NSArray *setArray;
    NSUserDefaults *defaults;
    CLLocationCoordinate2D locationCar;
    NSDictionary * device;
    CLLocationDistance meters;
    CLGeocoder *_geocoder;
    UIAlertView *alview;
    LocationModel *locationModel;
    NSMutableArray *locationArray;
    int mapType;
    NSString *severTimer ;
    NSTimer *refreshTimer;
}
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mapType = 0;
    self.addressLabel.text = NSLocalizedString(@"get_location_b", nil);

    _geocoder=[[CLGeocoder alloc]init];
    locationArray = [[NSMutableArray alloc] init];
    defaults = [NSUserDefaults standardUserDefaults];
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
    
    self.mapVIew.delegate = self;
    
    [ self.mapVIew setZoomEnabled:YES];
    [ self.mapVIew setScrollEnabled:YES];
  //  [ self.mapVIew setShowsUserLocation:YES];

    
    if([[defaults objectForKey:@"messageToLocation"] intValue] == 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoadNew) name:@"refreshLocation" object:nil];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
        self.mapVIew.showsScale = YES;
    }
    if([[defaults objectForKey:@"messageToLocation"] intValue] == 1){
        self.refreshBtn.enabled = NO;
    }
}

- (void)getLoadNew
{
    array =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [array objectAtIndex:0];
    
    locationArray = [manager isSelectLocationTable:deviceModel.DeviceID];
    locationModel = [locationArray objectAtIndex:0];

    locationCar.latitude = [[defaults objectForKey:@"MapLat"] doubleValue];
    locationCar.longitude = [[defaults objectForKey:@"MapLng"] doubleValue];
    if([[defaults objectForKey:@"MapTime"] length] != 0)
    {
        severTimer = [[defaults objectForKey:@"MapTime"] substringWithRange:NSMakeRange(11, 5)];
    }
    else
    {
        severTimer = @"";
    }
    
      theSpan.latitudeDelta=self.mapVIew.region.span.latitudeDelta;
    
    theSpan.longitudeDelta=self.mapVIew.region.span.longitudeDelta;

    MKCoordinateRegion theRegion;
    
    theRegion.center=locationCar;
    theSpan.latitudeDelta=0.006;
    //
    theSpan.longitudeDelta=0.006;
    theRegion.span=theSpan;
    
    [self.mapVIew setRegion:theRegion];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    if(annotation)
    {
        [self.mapVIew removeAnnotation:annotation];
    }
    annotation.coordinate = locationCar;
    [self.mapVIew addAnnotation:annotation];
    
    if(locationModel.LocationType.intValue == 0)
    {
        [self.mapVIew removeAnnotation:annotation];
    }

    CLLocation *location=[[CLLocation alloc]initWithLatitude:locationCar.latitude longitude:locationCar.longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        if(placemark.name == nil)
        {
            self.addressLabel.text = NSLocalizedString(@"failed_to_get_the_location_information", nil);
        }
        else
        {
            self.addressLabel.text = [NSString stringWithFormat:@"%@",placemark.name];
            self.timeLabel.text = severTimer;

        }
    }];

    if(locationModel.LocationType.intValue == 1)
    {
        self.LocationTypeImage.image = [UIImage imageNamed:@"gps_icon"];
    }
    else if(locationModel.LocationType.intValue == 2)
    {
        self.LocationTypeImage.image = [UIImage imageNamed:@"lbs_icon"];
    }
    else if(locationModel.LocationType.intValue == 3)
    {
        self.LocationTypeImage.image = [UIImage imageNamed:@"WIFI_icon"];
    }
    else
    {
        self.LocationTypeImage.hidden = YES;
        self.addressLabel.text = NSLocalizedString(@"Temporarily_no_data", nil);
    }
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
   // [self.mapVIew removeFromSuperview];
  //  [self.view addSubview:self.mapVIew];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.mapVIew removeFromSuperview];
}

- (void)getLocation
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    severTimer = locationModel.DeviceTime;

    if([[defaults objectForKey:@"messageToLocation"] intValue ] == 0)
    {
        locationCar.latitude = [locationModel.Latitude doubleValue];
        locationCar.longitude = [locationModel.Longitude doubleValue];
        if(locationModel.DeviceTime.length != 0)
        {
            severTimer = locationModel.DeviceTime;
            
        }
        else
        {
            severTimer = @"";
        }
    }
    else
    {
        locationCar.latitude = [[defaults objectForKey:@"MapLat"] doubleValue];
        locationCar.longitude = [[defaults objectForKey:@"MapLng"] doubleValue];
        if([[defaults objectForKey:@"MapTime"] length] != 0)
        {
            severTimer = [defaults objectForKey:@"MapTime"];
        }
        else
        {
            severTimer = @"";
        }
        self.LocationTypeImage.hidden = YES;
        self.timeLabel.hidden = YES;
        self.refreshBtn.hidden = YES;
    }
    
    theSpan.latitudeDelta=self.mapVIew.region.span.latitudeDelta;
    
    theSpan.longitudeDelta=self.mapVIew.region.span.longitudeDelta;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=locationCar;
    theSpan.latitudeDelta=0.006;
    //
    theSpan.longitudeDelta=0.006;
    theRegion.span=theSpan;
    
    [self.mapVIew setRegion:theRegion];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    if(annotation)
    {
        [self.mapVIew removeAnnotation:annotation];
    }
    annotation.coordinate = locationCar;
    [self.mapVIew addAnnotation:annotation];
    if(locationModel.LocationType.intValue == 0)
    {
        [self.mapVIew removeAnnotation:annotation];
    }
    [self findAddressString:locationModel.Latitude longitude:locationModel.Longitude];
//    WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
//    webService.tag =1112;
//    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
//    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
//    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:locationModel.Latitude];
//    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:locationModel.Longitude];
//    
//    NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
//    // webservice请求并获得结果
//    webService.webServiceParameter = parameter;
//    [webService getWebServiceResult:@"GetAddressResult"];

    if(locationModel.LocationType.intValue == 1)
    {
        self.LocationTypeImage.image = [UIImage imageNamed:@"gps_icon"];
    }
    else if(locationModel.LocationType.intValue  == 2)
    {
        self.LocationTypeImage.image = [UIImage imageNamed:@"lbs_icon"];
    }
    else if(locationModel.LocationType.intValue  == 3)
    {
        self.LocationTypeImage.image = [UIImage imageNamed:@"WIFI_icon"];
    }
    else
    {
        self.LocationTypeImage.hidden = YES;
        self.addressLabel.text = NSLocalizedString(@"Temporarily_no_data", nil);
    }
}

-(void)findAddressString:(NSString *)latitude longitude:(NSString *)longitude{
    CLLocation * location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
    //位置反编码, IOS5.0之后
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks.count > 0){
            for (CLPlacemark *placemark in placemarks) {
                //CLPlacemark 地标
                //            NSLog(@"位置:%@", placemark.name);
                //            NSLog(@"街道:%@", placemark.thoroughfare);
                //            NSLog(@"子街道:%@", placemark.subThoroughfare);
                //            NSLog(@"市:%@", placemark.locality);
                //            NSLog(@"区\\县:%@", placemark.subLocality);
                //            NSLog(@"行政区:%@", placemark.administrativeArea);
                //            NSLog(@"国家:%@", placemark.country);
                NSString *addstring = @"";
                if(placemark.administrativeArea.length>0){
                    addstring = placemark.administrativeArea;
                }
                if(placemark.locality.length>0){
                    addstring = [NSString stringWithFormat:@"%@%@",addstring,placemark.locality];
                }
                if(placemark.subLocality.length>0){
                    addstring = [NSString stringWithFormat:@"%@%@",addstring,placemark.subLocality];            }
                if(placemark.thoroughfare.length>0){
                    addstring = [NSString stringWithFormat:@"%@%@",addstring,placemark.thoroughfare];            }
                if(addstring.length == 0){
                    addstring = @"无法查找地址";
                    self.addressLabel.text = addstring;
                }
                self.addressLabel.text = addstring;
                self.timeLabel.text = severTimer;
                break;
            }
        }else{
            self.addressLabel.text = @"无法查找地址";
            self.timeLabel.text = severTimer;
        }
    }];
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService *ws = theWebService;
    
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            if(code == 1)
            {
                if(ws.tag == 0)
                {
                    ZFCDoubleBounceActivityIndicatorView *doubleBounce = [[ZFCDoubleBounceActivityIndicatorView alloc] init];
                    doubleBounce.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
                    [doubleBounce startAnimating];
                    if(doubleBounce)
                    {
                        [doubleBounce removeFromSuperview];
                    }
                    [self.view addSubview:doubleBounce];
                    [NSTimer scheduledTimerWithTimeInterval:10 target:doubleBounce selector:@selector(stopAnimating) userInfo:nil repeats:NO];
 
                    
                }
                else
                {
                    NSArray * address = [object objectForKey:@"Nearby"];
                    if(address.count != 0 && address.count>1)
                    {
                        if([[defaults objectForKey:@"messageToLocation"] intValue ] == 0)
                        {
                            self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@,%@,%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"],[[address objectAtIndex:1] objectForKey:@"POI"]];
                            self.timeLabel.text = severTimer;
                        }
                        else
                        {
                            self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@,%@,%@ %@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"],[[address objectAtIndex:1] objectForKey:@"POI"],severTimer];
                        }
                    }
                    else
                    {
                        if([[defaults objectForKey:@"messageToLocation"] intValue ] == 0)
                        {
                            self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"]];
                            self.timeLabel.text = severTimer;
                        }
                        else
                        {
                            self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@ %@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],severTimer];
                        }
                    }
                }
            }
        }
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //大头针视图
    //注意：为了提高显示效率。显示大头针加入复用机制
    static NSString *annotationId = @"4rrrn";
    WatchAnnotationView *pin = (WatchAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
    if(pin == nil){
        
        pin = [[WatchAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
    }
    pin.image = [UIImage imageNamed:@"location_watch"];
    return pin;
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
    manager = [DataManager shareInstance];
    
    array =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [array objectAtIndex:0];
    
    locationArray = [manager isSelectLocationTable:deviceModel.DeviceID];
    locationModel = [locationArray objectAtIndex:0];
    
    [self getLocation];
}

- (IBAction)mapType:(id)sender {
    
    if(mapType==0)
    {
        mapType=1;
        [self.mapType setBackgroundImage:[UIImage imageNamed:@"planar_map"] forState:UIControlStateNormal];
        [self.mapVIew setMapType:MKMapTypeSatellite];
    }else{
        [self.mapType setBackgroundImage:[UIImage imageNamed:@"satellite_maps"] forState:UIControlStateNormal];
        mapType=0;
        [self.mapVIew setMapType:MKMapTypeStandard];
    }
}

- (IBAction)zoomOut:(id)sender {
    
    theSpan.latitudeDelta=self.mapVIew.region.span.latitudeDelta/2;
    
    theSpan.longitudeDelta=self.mapVIew.region.span.longitudeDelta/2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapVIew centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapVIew setRegion:theRegion];
}

- (IBAction)zoomIn:(id)sender {
    
    if (self.mapVIew.region.span.latitudeDelta>60||self.mapVIew.region.span.longitudeDelta>60) {
        return;
    }
    theSpan.latitudeDelta=self.mapVIew.region.span.latitudeDelta*2;
    
    theSpan.longitudeDelta=self.mapVIew.region.span.longitudeDelta*2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapVIew centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapVIew setRegion:theRegion];
}

- (IBAction)refreshBtn:(id)sender {

    WebService *webService = [WebService newWithWebServiceAction:@"RefreshDeviceState" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"RefreshDeviceStateResult"];
    
    self.refreshBtn.enabled  = NO;
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(changeBtnUse) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.mapVIew removeFromSuperview];
    self.mapVIew.delegate = nil;
}

- (void)changeBtnUse
{
    self.refreshBtn.enabled = YES;
    
    [refreshTimer invalidate];
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
