//
//  MainMapViewController.m
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/3/6.
//  Copyright © 2019年 HH. All rights reserved.
//

#import "MainMapViewController.h"
#import "MessageRecordViewController.h"
#import "BabySelectViewController.h"
#import "SYQRCodeViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "Constants.h"
#import "OMGToast.h"
#import "JSBadgeView.h"
#import "PictureSacnViewController.h"
#import "NSString+Tools.h"
#import "LXActionSheet.h"
#import "LocationModel.h"
#import "LocationCache.h"
#import "UserModel.h"
#import "MylocationAnnotationView.h"
#import "WatchAnnotationView.h"
#import "ZFCDoubleBounceActivityIndicatorView.h"
#import "StreetViewViewController.h"

@interface MainMapViewController ()<WebServiceProtocol,CLLocationManagerDelegate,MKMapViewDelegate,UIAlertViewDelegate,LXActionSheetDelegate>{
    NSUserDefaults *defaults;
    NSMutableArray *array;
    NSArray *setArray;
    NSMutableArray *deviceArray;
    DataManager *manager ;
    DeviceModel *deviceModel;
    DeviceSetModel *modelset;
    NSMutableArray *locationArray;
    LocationModel *locationModel;
    UIButton *rightBtn;
    NSString *imeiStr;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D locationPerson;
    MKCoordinateSpan theSpan;
    CLLocationCoordinate2D locationCar;
    NSArray *location;
    CLLocationCoordinate2D myLocation;
    //NSMutableArray *locationcache_address;
    NSTimer *doubleBounceTimer;
    UserModel *model;
    ZFCDoubleBounceActivityIndicatorView *doubleBounce;
    JSBadgeView *bageView;
    BOOL isLocationPhone;
}

@end

@implementation MainMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"ic_message"] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    defaults = [NSUserDefaults standardUserDefaults];
    manager = [DataManager shareInstance];
    [self initViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLocation) name:@"refreshLocation" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = deviceArray[0];
    locationArray = [manager isSelectLocationTable:deviceModel.DeviceID];
    if(locationArray != nil && locationArray.count){
        locationModel = locationArray[0];
    }
    [self initMap];
    [self getLocation];
    [self initWatchTypeAndDistance];
    [self getLastLocation];
}

-(void)initViews{
    self.lbAddWatch.text = NSLocalizedString(@"main_add_watch", nil);
    self.lbChangeWatch.text = NSLocalizedString(@"main_change_watch", nil);
    self.lbCall.text = NSLocalizedString(@"main_call", nil);
    self.lbStreetView.text = NSLocalizedString(@"main_street_view", nil);
    self.lbNavi.text = NSLocalizedString(@"main_navi", nil);
    //    JSBadgeView *bageView = [[JSBadgeView alloc] initWithParentView:rightBtn alignment:JSBadgeViewAlignmentTopRight];
    //    bageView.tag = 1;
    //    bageView.badgeText = [NSString stringWithFormat:@"%d", 10];
    self.lbAddress.text = NSLocalizedString(@"get_location_b", nil);
}

-(void)initMap{
    //设置MapView的委托为自己
    [self.mapView setDelegate:self];
    //标注自身位置
    [self.mapView setShowsUserLocation:YES];
    //地图
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        self.mapView.showsScale = YES;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
    }
    locationManager = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
    }else{
        locationManager.delegate = self;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {    //如果没有授权则请求用户授权
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                [locationManager requestWhenInUseAuthorization];
            } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
                
            }
        }
        //设置代理
        locationManager.delegate = self;
        //设置定位精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance = 10.0;//十米定位一次
        locationManager.distanceFilter = distance;
        //启动跟踪定位
        [locationManager startUpdatingLocation];
        [locationManager stopUpdatingHeading];
    }
}

-(void)refreshLocation{
    self.lbCountDown.text = @"1";
    self.lbCountDown.hidden = YES;
    [doubleBounce stopAnimating];
    [doubleBounce removeFromSuperview];
    doubleBounce = nil;
    self.locationBtn.enabled = YES;
    if(doubleBounceTimer){
        [doubleBounceTimer invalidate];
        doubleBounceTimer = nil;
    }
    self.lbCountDown.text = @"1";
    self.lbCountDown.hidden = YES;
    [self getLocation];
}

- (void)getLocation {
    [_mapView removeAnnotations:_mapView.annotations];
    locationArray = [manager isSelectLocationTable:deviceModel.DeviceID];
    if (locationArray.count > 0) {
        locationModel = [locationArray objectAtIndex:0];
    }
    float distance = 0;
    if(myLocation.latitude == 0 && myLocation.longitude == 0){
        locationCar.latitude = [locationModel.Latitude doubleValue];
        locationCar.longitude = [locationModel.Longitude doubleValue];
    }else{
        if(locationModel.wifi && (locationModel.LocationType.intValue == 1 || (locationModel.LocationType.intValue == 2 && [deviceModel.DeviceType isEqualToString:@"1"]))){
            distance = [MapTool getDistance:[locationModel.Latitude floatValue] lng1:[locationModel.Longitude floatValue] lat2:myLocation.latitude lng2:myLocation.longitude];
        }
        if(distance > 100 && distance < 550){
            double present = 100 / distance;
            double lat = myLocation.latitude * present;
            double lon = myLocation.longitude * present;
            locationCar.latitude =  myLocation.latitude + lat;
            locationCar.longitude = myLocation.longitude + lon;
        }else{
            locationCar.latitude = [locationModel.Latitude doubleValue];
            locationCar.longitude = [locationModel.Longitude doubleValue];
        }
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    theSpan.latitudeDelta = self.mapView.region.span.latitudeDelta;
    
    theSpan.longitudeDelta = self.mapView.region.span.longitudeDelta;
    
    MKCoordinateRegion theRegion;
    
    
    if (locationCar.latitude != 0 && locationCar.longitude != 0) {
        //if(!isOnce)å
        {
            isLocationPhone = NO;
            theRegion.center = locationCar;
            theSpan.latitudeDelta = 0.006;
            //
            theSpan.longitudeDelta = 0.006;
            theRegion.span = theSpan;
            
            if ((theRegion.center.latitude>=-90) && (theRegion.center.latitude<=90) && (theRegion.center.longitude>=-180) && (theRegion.center.longitude<=180)) {
                [self.mapView setRegion:theRegion];
            }else{
                NSLog(@"invilid region");
            }
        }
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [_mapView removeAnnotations:_mapView.annotations];
        
        annotation.coordinate = locationCar;
        [self.mapView addAnnotation:annotation];
    }else{
        isLocationPhone = YES;
    }
    if (locationModel.Electricity.intValue <= 0){
        self.ivElectricity.image = [UIImage imageNamed:@"ic_electricity"];
    }else if (locationModel.Electricity.intValue < 20) {
        self.ivElectricity.image = [UIImage imageNamed:@"ic_electricity2"];
    } else if (locationModel.Electricity.intValue < 40) {
        self.ivElectricity.image = [UIImage imageNamed:@"ic_electricity3"];
    } else if (locationModel.Electricity.intValue < 60) {
        self.ivElectricity.image = [UIImage imageNamed:@"ic_electricit4"];
    } else if (locationModel.Electricity.intValue < 80) {
        self.ivElectricity.image = [UIImage imageNamed:@"ic_electricit5"];
    } else {
        self.ivElectricity.image = [UIImage imageNamed:@"ic_electricity6"];
    }
    int electricity = locationModel.Electricity.intValue;
    if(electricity <= 0){
        self.lbElectricity.text = @"0%";
    }else if(electricity == 255){
        self.lbElectricity.text = NSLocalizedString(@"charging", nil);
    }else if(electricity <= 100){
        self.lbElectricity.text = [NSString stringWithFormat:@"%@%%",locationModel.Electricity];
    }else{
        self.lbElectricity.text = @"100%";
    }
    if(locationModel.Latitude.length && locationModel.Longitude.length){
        distance = [MapTool getDistance:[locationModel.Latitude floatValue] lng1:[locationModel.Longitude floatValue] lat2:myLocation.latitude lng2:myLocation.longitude];
    }
    self.lbTime.text = [NSString stringWithFormat:NSLocalizedString(@"location_time", nil),[dateFormatter stringFromDate:[NSDate new]]];
    if (deviceModel.BabyName.length) {
        self.navigationItem.title = deviceModel.BabyName;
        self.lbName.text = [NSString stringWithFormat:NSLocalizedString(@"my_place", nil),deviceModel.BabyName];
    } else {
        self.navigationItem.title = NSLocalizedString(@"baby", nil);
        self.lbName.text = [NSString stringWithFormat:NSLocalizedString(@"my_place", nil),NSLocalizedString(@"baby", nil)];
    }
    
    
    if (locationModel.Latitude.length != 0 && locationModel.Longitude.length != 0) {
        [self findAddressString:locationModel.Latitude longitude:locationModel.Longitude];
    }
}

-(void)initWatchTypeAndDistance{
    if(locationModel){
        float distance;
        
        //比较距离
        if(locationModel.Latitude.length && locationModel.Longitude.length){
            distance = [MapTool getDistance:[locationModel.Latitude floatValue] lng1:[locationModel.Longitude floatValue] lat2:myLocation.latitude lng2:myLocation.longitude];
        }
        
        //测试
        // distance=100;
        
        if (locationModel.LocationType.intValue == 2) {
            //lbs，需要保存第一次位置
            //500-1500米设置半径400米
            if(distance>500 && distance<1500){
                @try {
                    NSMutableArray *ranges=[MapTool getRange:[locationModel.Longitude floatValue] lat:[locationModel.Latitude floatValue] :400];
                    if (ranges.count==4) {
                        //这里设置区域
                        locationCar.longitude=[[ranges objectAtIndex:0] floatValue];
                        locationCar.latitude=[[ranges objectAtIndex:1] floatValue];
                        if (locationCar.latitude != 0 && locationCar.longitude != 0) {
                            myLocation.latitude=locationCar.latitude;
                            myLocation.longitude=locationCar.longitude;
                            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation, 600, 600);
                            
                            if ((region.center.latitude>=-90) && (region.center.latitude<=90) && (region.center.longitude>=-180) && (region.center.longitude<=180)) {
                                [self.mapView setRegion:region animated:YES];
                            }else{
                                NSLog(@"invilid region");
                            }
                            
                        }
                        distance=400;
                    }
                } @catch (NSException *exception) {
                    
                }
            }else if (distance>200 && distance<500){
                //500米内设置200米半径
                @try {
                    NSMutableArray *ranges=[MapTool getRange:[locationModel.Longitude floatValue] lat:[locationModel.Latitude floatValue] :200];
                    if (ranges.count==4) {
                        //这里设置区域
                        locationCar.longitude=[[ranges objectAtIndex:0] floatValue];
                        locationCar.latitude=[[ranges objectAtIndex:1] floatValue];
                        if (locationCar.latitude != 0 && locationCar.longitude != 0) {
                            myLocation.latitude=locationCar.latitude;
                            myLocation.longitude=locationCar.longitude;
                            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation, 600, 600);
                            if ((region.center.latitude>=-90) && (region.center.latitude<=90) && (region.center.longitude>=-180) && (region.center.longitude<=180)) {
                                [self.mapView setRegion:region animated:YES];
                            }else{
                                NSLog(@"invilid region");
                            }
                        }
                        distance=200;
                    }
                } @catch (NSException *exception) {
                    
                }
            }
            
        }else if(locationModel.LocationType.intValue == 3){
            //wifi
            if (distance>10 && distance<100) {
                //附近10米
                @try {
                    NSMutableArray *ranges=[MapTool getRange:[locationModel.Longitude floatValue] lat:[locationModel.Latitude floatValue] :10];
                    if (ranges.count==4) {
                        //这里设置区域
                        locationCar.longitude=[[ranges objectAtIndex:0] floatValue];
                        locationCar.latitude=[[ranges objectAtIndex:1] floatValue];
                        if (locationCar.latitude != 0 && locationCar.longitude != 0) {
                            myLocation.latitude=locationCar.latitude;
                            myLocation.longitude=locationCar.longitude;
                            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation, 600, 600);
                            if ((region.center.latitude>=-90) && (region.center.latitude<=90) && (region.center.longitude>=-180) && (region.center.longitude<=180)) {
                                [self.mapView setRegion:region animated:YES];
                            }else{
                                NSLog(@"invilid region");
                            }
                        }
                        distance=10;
                    }
                } @catch (NSException *exception) {
                    
                }
            }else if(distance>100 && distance<550){
                //手机附近50米
                @try {
                    NSMutableArray *ranges=[MapTool getRange:[locationModel.Longitude floatValue] lat:[locationModel.Latitude floatValue] :50];
                    if (ranges.count==4) {
                        //这里设置区域
                        locationCar.longitude=[[ranges objectAtIndex:0] floatValue];
                        locationCar.latitude=[[ranges objectAtIndex:1] floatValue];
                        if (locationCar.latitude != 0 && locationCar.longitude != 0) {
                            myLocation.latitude=locationCar.latitude;
                            myLocation.longitude=locationCar.longitude;
                            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation, 600, 600);
                            if ((region.center.latitude>=-90) && (region.center.latitude<=90) && (region.center.longitude>=-180) && (region.center.longitude<=180)) {
                                [self.mapView setRegion:region animated:YES];
                            }else{
                                NSLog(@"invilid region");
                            }
                        }
                        distance=50;
                    }
                } @catch (NSException *exception) {
                    
                }
            }
        }
        
        
        
        
        NSString *distanceStr;
        if(distance < 1000){
            distanceStr = [NSString stringWithFormat:NSLocalizedString(@"metre", nil),[NSString stringWithFormat:@"%ld",(int)distance]];
        }else if(fmod(distance/1000, 1) == 0){ //如果有一位小数点
            distanceStr = [NSString stringWithFormat:NSLocalizedString(@"kilometre", nil),[NSString stringWithFormat:@"%.0f",distance/1000]];
        }else if(fmod(distance/100, 1) == 0){ //如果有两位小数点
            distanceStr = [NSString stringWithFormat:NSLocalizedString(@"kilometre", nil),[NSString stringWithFormat:@"%.1f",distance/1000]];
        }else{
            distanceStr = [NSString stringWithFormat:NSLocalizedString(@"kilometre", nil),[NSString stringWithFormat:@"%.2f",distance/1000]];
        }
        if(locationModel.wifi.length){
            self.lbLocationType.text = [NSString stringWithFormat:NSLocalizedString(@"main_location_type", nil),NSLocalizedString(@"wifi_location", nil),distanceStr];
        }else{
            
            NSLog(@"-----下发过来显示---%d",locationModel.LocationType.intValue);
            
            if (locationModel.LocationType.intValue == 1) {      //GPS
                self.lbLocationType.text = [NSString stringWithFormat:NSLocalizedString(@"main_location_type", nil),NSLocalizedString(@"gps_location", nil),distanceStr];
            } else if (locationModel.LocationType.intValue == 2) { //LBS
                /**if ([deviceModel.DeviceType isEqualToString:@"1"]) {
                    
                    self.lbLocationType.text = [NSString stringWithFormat:NSLocalizedString(@"main_location_type", nil),NSLocalizedString(@"gps_location", nil),distanceStr];
                } else {
                    self.lbLocationType.text = [NSString stringWithFormat:NSLocalizedString(@"main_location_type", nil),NSLocalizedString(@"lbs_location", nil),distanceStr];
                }
                    **/
                self.lbLocationType.text = [NSString stringWithFormat:NSLocalizedString(@"main_location_type", nil),NSLocalizedString(@"lbs_location", nil),distanceStr];
            } else if (locationModel.LocationType.intValue == 3){ //WIFI
                self.lbLocationType.text = [NSString stringWithFormat:NSLocalizedString(@"main_location_type", nil),NSLocalizedString(@"wifi_location", nil),distanceStr];
            }else{
                self.lbLocationType.text = [NSString stringWithFormat:NSLocalizedString(@"main_location_type", nil),NSLocalizedString(@"wifi_location", nil),distanceStr];
            }
        }
    }
}

-(void)countDownLocation{
    if ([@"1" isEqualToString:self.lbCountDown.text]) {
        [doubleBounce stopAnimating];
        [doubleBounce removeFromSuperview];
        doubleBounce = nil;
        self.locationBtn.enabled = YES;
        if(doubleBounceTimer){
            [doubleBounceTimer invalidate];
            doubleBounceTimer = nil;
        }
        self.lbCountDown.hidden = YES;
    }else if(self.lbCountDown.text.intValue > 1){
        self.lbCountDown.text = [NSString stringWithFormat:@"%ld",self.lbCountDown.text.intValue - 1];
    }
}

-(void)locationDevice{
    WebService *webService = [WebService newWithWebServiceAction:@"LocationDevice" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"controllerDevice/ask/localtion/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结
    
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"LocationResult"];
}

-(void)getLastLocation{
    WebService *webService = [WebService newWithWebServiceAction:@"GetLastLocation" andDelegate:self];
    webService.tag = 2;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"location/getlastLocation/search/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结
    
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetLastLocationResult"];
}

- (void)setviewinfo{
    if(doubleBounceTimer){
        [doubleBounceTimer invalidate];
        doubleBounceTimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showNext{
    MessageRecordViewController *message = [[MessageRecordViewController alloc] init];
    message.title = NSLocalizedString(@"msg_record", nil);
    [self.navigationController pushViewController:message animated:YES];
}

- (IBAction)locationAction:(id)sender{
    [self locationDevice];
    self.locationBtn.enabled = NO;
}

- (IBAction)findAction:(id)sender{
    UIAlertView *alerview;
    if ([deviceModel.DeviceType isEqualToString:@"2"]) {
        alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_find_watch_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil), NSLocalizedString(@"OK", nil), nil];
    } else {
        alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_find_watch", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil), NSLocalizedString(@"OK", nil), nil];
    }
    alerview.tag = 1;
    [alerview show];
}

- (IBAction)watchAction:(id)sender{
    [self getLastLocation];
    MKCoordinateRegion theRegion;
    theRegion.center = locationCar;
    theSpan.latitudeDelta = 0.006;
    theSpan.longitudeDelta = 0.006;
    theRegion.span = theSpan;
    if ((theRegion.center.latitude>=-90) && (theRegion.center.latitude<=90) && (theRegion.center.longitude>=-180) && (theRegion.center.longitude<=180)) {
        [self.mapView setRegion:theRegion];
    }else{
        NSLog(@"invilid region");
    }
}

- (IBAction)phoneAction:(id)sender{
    MKCoordinateRegion theRegion;
    theRegion.center = myLocation;
    theSpan.latitudeDelta = 0.006;
    theSpan.longitudeDelta = 0.006;
    theRegion.span = theSpan;
    [self.mapView setRegion:theRegion];
    //    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    //    annotation.coordinate = myLocation;
    //    //启动跟踪定位
    //    [locationManager startUpdatingLocation];
    //标注自身位置
    [self.mapView setShowsUserLocation:YES];
}

- (IBAction)addWatchAction:(id)sender{
    SYQRCodeViewController* syq = [[SYQRCodeViewController alloc]init];
    syq.title = NSLocalizedString(@"scans", nil);
    //扫描结果
    syq.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        [syq.navigationController popViewControllerAnimated:YES];
        if ([qrString isValidateIMEI:qrString]){
            imeiStr = qrString;
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"baby_nick", nil) message:NSLocalizedString(@"input_baby_nick", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            alertView.delegate = self;
            alertView.tag = 0;
            [alertView show];
        }else{
            [OMGToast showWithText:NSLocalizedString(@"input_login_IMEIError", nil) bottomOffset:50 duration:3];
        }
    };
    //扫描失败
    syq.SYQRCodeFailBlock = ^(SYQRCodeViewController * syqrcode){
        [OMGToast showWithText:NSLocalizedString(@"scans_error", nil) bottomOffset:50 duration:3];
        [syq dismissViewControllerAnimated:NO completion:nil];
    };
    //扫描取消
    syq.SYQRCodeCancleBlock = ^(SYQRCodeViewController *syqrcode){
        [OMGToast showWithText:NSLocalizedString(@"scan_cancellation", nil) bottomOffset:50 duration:3];
        [syq dismissViewControllerAnimated:NO completion:nil];
    };
    [self.navigationController pushViewController:syq animated:YES];
}

- (IBAction)changeWatchAction:(id)sender{
    BabySelectViewController *baby = [[BabySelectViewController alloc] init];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"deviceModelType"] == 1){
        baby.title = NSLocalizedString(@"select_watch_d8", nil);
    }else{
        baby.title = NSLocalizedString(@"select_watch", nil);
    }
    [self.navigationController pushViewController:baby animated:YES];
}

- (IBAction)callAction:(id)sender{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
    NSString* cloudPlatform = [defaults objectForKey:MAIN_USER_CLOUD_PLAT_FORM];
    if (cloudPlatform.intValue > 0){
        UIStoryboard *UpgradeHardware = [UIStoryboard storyboardWithName:@"DialingNumberController" bundle:nil];
        UIViewController *firstVC = [UpgradeHardware instantiateViewControllerWithIdentifier:@"DialingNumberController"];
        [self.navigationController pushViewController:firstVC animated:YES];
    }else{
        if([deviceModel.DeviceType isEqualToString:@"2"]) {
            LXActionSheet *actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"call", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"watch_no_d8", nil), NSLocalizedString(@"watch_short_phone_d8", nil)]];
            actionSheet.tag = 5;
            [actionSheet showInView:self.view];
        } else {
            LXActionSheet *actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"call", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"watch_no", nil), NSLocalizedString(@"watch_short_phone", nil)]];
            actionSheet.tag = 5;
            [actionSheet showInView:self.view];
        }
    }
}

- (IBAction)streetViewAction:(id)sender{
    StreetViewViewController *streetViewViewController = [StreetViewViewController new];
    streetViewViewController.title = NSLocalizedString(@"main_street_view", nil);
    streetViewViewController.lat = locationModel.Latitude;
    streetViewViewController.lng = locationModel.Longitude;
    [self.navigationController pushViewController:streetViewViewController animated:YES];
    
    //    PictureSacnViewController *picVC = [PictureSacnViewController new];
    //    NSMutableArray *array = [NSMutableArray array];
    //    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //    [dic setObject:[NSString stringWithFormat:@"https://apis.map.qq.com/ws/streetview/v1/image?size=960x640&location=%f,%f&key=77VBZ-TZHCR-YMUW4-W2HOO-UL4N3-AEBII",22.535406,114.023191] forKey:@"content"];
    //    [array addObject:dic];
    //    picVC.picArray = array;
    //    picVC.currenpage = 1;//当前图片
    //    [self.navigationController presentViewController:picVC animated:YES completion:nil];
}

- (IBAction)naviAction:(id)sender{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 22.535406;
    coordinate.longitude = 114.023191;
    [[MapTool sharedMapTool] navigationActionWithCoordinate:coordinate WithENDName:[NSString stringWithFormat:@"%f,%f",coordinate.longitude,coordinate.latitude] tager:self];
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
                }
                self.lbAddress.text = addstring;
                break;
            }
        }else{
            self.lbAddress.text = @"无法查找地址";
        }
    }];
}

-(void)didClickOnButtonIndex:(NSInteger *)buttonIndex{
    if (buttonIndex == 0) {
        if (deviceModel.PhoneNumber.length == 0) {
            if ([deviceModel.DeviceType isEqualToString:@"2"]) {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_no_first_d8", nil) bottomOffset:50 duration:3];
            } else {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_no_first", nil) bottomOffset:50 duration:3];
            }
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",deviceModel.PhoneNumber]]];
        }
    } else if (buttonIndex == 1) {
        if (deviceModel.PhoneCornet.length == 0) {
            if ([deviceModel.DeviceType isEqualToString:@"2"]) {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_cornet_first_d8", nil) bottomOffset:50 duration:3];
            } else {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_cornet_first", nil) bottomOffset:50 duration:3];
            }
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",deviceModel.PhoneCornet]]];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        if(alertView.tag == 0){
            [[alertView textFieldAtIndex:0] resignFirstResponder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WebService *webService = [WebService newWithWebServiceAction:@"AddDevice" andDelegate:self];
                webService.tag = 1;
                WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchAppUser/bindOtherImei"];
                WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
                WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:imeiStr];
                WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"name" andValue:[alertView textFieldAtIndex:0].text];
                NSArray *parameter = @[parameter1,parameter2,parameter3,parameter4];
                // webservice请求并获得结
                
                webService.webServiceParameter = parameter;
                [webService getWebServiceResult:@"AddDeviceResult"];
            });
        }else if(alertView.tag == 1){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
                webService.tag = 0;
                WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"controllerDevice/find/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
                NSArray *parameter = @[parameter1];
                // webservice请求并获得结
                
                webService.webServiceParameter = parameter;
                [webService getWebServiceResult:@"SendDeviceCommandResult"];
            });
        }
    }else if(alertView.tag == 0){
        [[alertView textFieldAtIndex:0] resignFirstResponder];
    }
}

//判断是不是在中国
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //if(isMyLocation)
    if (annotation == mapView.userLocation) {
        static NSString *annotationId = @"4rrrnwwwwwww";
        MylocationAnnotationView *pin = (MylocationAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
        if (pin == nil) {
            pin = [[MylocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        }
        pin.image = [UIImage imageNamed:@"ic_phone_marker"];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        //pin.centerOffset = CGPointMake(0, -18);
        return pin;
    } else {
        //大头针视图
        //注意：为了提高显示效率。显示大头针加入复用机制
        static NSString *annotationId = @"4rrrn";
        WatchAnnotationView *pin = (WatchAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
        if (pin == nil) {
            
            pin = [[WatchAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        }
        pin.image = [UIImage imageNamed:@"location_watch"];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        //pin.centerOffset = CGPointMake(0, -18);
        return pin;
    }
}

//漂移处理
//const double x_pi = M_PI * 3000.0 / 300.0;
//
//void transform_mars_2_bear_paw2(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon) {
//    double x = gg_lon, y = gg_lat;
//    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
//    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
//
//    /*
//     if ([CenterViewController currentResolution] == UIDevice_iPhone4s) {
//     *bd_lon = z * cos(theta) + 0.0045;
//     *bd_lat = z * sin(theta) - 0.0030;
//     }
//     else if ([CenterViewController currentResolution] == UIDevice_iPhone5) {
//     *bd_lon = z * cos(theta) + 0.0045;
//     *bd_lat = z * sin(theta) - 0.0030;
//     }
//     else if ([CenterViewController currentResolution] == UIDevice_iPhone6)
//     {
//     *bd_lon = z * cos(theta) + 0.0045;
//     *bd_lat = z * sin(theta) - 0.0030;
//     }
//     else if ([CenterViewController currentResolution] == UIDevice_iPhone6_plus)
//     {
//     *bd_lon = z * cos(theta) + 0.0045;
//     *bd_lat = z * sin(theta) - 0.0030;
//     }
//     else
//     */
//    {
//        *bd_lon = z * cos(theta) + 0.0045;
//        *bd_lat = z * sin(theta) - 0.0030;
//    }
//
//}
//
//void transform_bear_paw_2_mars(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon) {
//    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
//    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
//    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
//    *gg_lon = z * cos(theta);
//    *gg_lat = z * sin(theta);
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(nonnull CLLocation *)newLocation fromLocation:(nonnull CLLocation *)oldLocation {
    double lat = 0.0;
    double lng = 0.0;
    
    NSLog(@"纬度:%f", newLocation.coordinate.latitude);
    NSLog(@"经度:%f", newLocation.coordinate.longitude);
    //    if (locationCar.latitude == 0 && locationCar.longitude == 0) {
    //        MKCoordinateRegion theRegion;
    //        theRegion.center = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    //        theSpan.latitudeDelta = 0.006;
    //        theSpan.longitudeDelta = 0.006;
    //    }
    //    myLocation = newLocation.coordinate;
    
    //判断是不是属于国内范围
    if (![MainMapViewController isLocationOutOfChina:myLocation]) {
        //transform_bear_paw_2_mars(myLocation.latitude, myLocation.longitude, &lat, &lng);
        //        transform_mars_2_bear_paw(myLocation.latitude, myLocation.longitude, &lat, &lng);
    }
    //    myLocation.latitude = lat;
    //    myLocation.longitude = lng;
    
    [defaults setDouble:lat forKey:@"myLa"];
    [defaults setDouble:lng forKey:@"myLo"];
    //    [locationManager stopUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    myLocation = userLocation.coordinate;
    [self initWatchTypeAndDistance];
    if (locationCar.latitude == 0 && locationCar.longitude == 0) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation, 600, 600);
        if ((region.center.latitude>=-90) && (region.center.latitude<=90) && (region.center.longitude>=-180) && (region.center.longitude<=180)) {
            [self.mapView setRegion:region animated:YES];
        }else{
            NSLog(@"invilid region");
        }
    }
    //    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    //    [_mapView removeAnnotations:_mapView.annotations];
    //    annotation.coordinate = myLocation;
    //    [self.mapView addAnnotation:annotation];
}

- (void)WebServiceGetCompleted:(id)theWebService{
    WebService *ws = theWebService;
    if ([[theWebService soapResults] length] > 0) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            if(ws.tag == 0){
                if(code == 1 || code == 0){
                    if(self.lbCountDown.hidden){
                        self.lbCountDown.hidden = NO;
                        doubleBounce = [[ZFCDoubleBounceActivityIndicatorView alloc] init];
                        doubleBounce.center = self.locationBtn.center;
                        [doubleBounce startAnimating];
                        [self.view addSubview:doubleBounce];
                        if(code == 0){
                            self.lbCountDown.text = @"90";
                        }else{
                            self.lbCountDown.text = @"20";
                        }
                        doubleBounceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownLocation) userInfo:nil repeats:YES];
                    }
                }else if(code == 2){
                    self.locationBtn.enabled = YES;
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    self.locationBtn.enabled = YES;
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }else if(ws.tag == 1){
                if(code == 1){
                    [OMGToast showWithText:NSLocalizedString(@"bind_suc", nil) bottomOffset:50 duration:3];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"bind_error", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"bind_fail", nil) bottomOffset:50 duration:3];
                }
            }else if(ws.tag == 2){
                if(code == 1){
                    [manager deleteLocationWithDeviceID:deviceModel.DeviceID];
                    if(((NSString *)[object objectForKey:@"wifi"]).length){
                        [object setValue:@"3" forKey:@"LocationType"];
                    }
                    [manager addLocationDeviceID:[object objectForKey:@"DeviceID"] andAltitude:[object objectForKey:@"Altitude"] andCourse:[object objectForKey:@"Course"] andLocationType:[object objectForKey:@"LocationType"] andCreateTime:[object objectForKey:@"CreateTime"] andElectricity:[object objectForKey:@"Electricity"] andGSM:[object objectForKey:@"GSM"] andStep:[object objectForKey:@"Step"] andHealth:[object objectForKey:@"Health"] andLatitude:[object objectForKey:@"Latitude"] andLongitude:[object objectForKey:@"Longitude"] andOnline:[object objectForKey:@"Online"] andSatelliteNumber:[object objectForKey:@"SatelliteNumber"] andServerTime:[object objectForKey:@"ServerTime"] andSpeed:[object objectForKey:@"Speed"] andUpdateTime:[object objectForKey:@"UpdateTime"] andDeviceTime:[object objectForKey:@"DeviceTime"]];
                    [self getLocation];
                }
            }else if(ws.tag == 3){
                if(code == 1){
                    [OMGToast showWithText:NSLocalizedString(@"send_success", nil) bottomOffset:50 duration:3];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }else{
                if(code == 1){
                    [OMGToast showWithText:NSLocalizedString(@"send_success", nil) bottomOffset:50 duration:3];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
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
