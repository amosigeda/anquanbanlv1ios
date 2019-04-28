//
//  HomeViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "HomeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "YCHomeAnnotationView.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "OMGToast.h"
#import "SearchViewController.h"
#import "LoginViewController.h"
#import "XiaoquSetViewController.h"
#import "DeviceSetModel.h"


@interface HomeViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,WebServiceProtocol>
{
    CLGeocoder *_geocoder;
    int mapType;
    NSUserDefaults *defaults;
    DeviceModel *model;
    DeviceSetModel *deviceSetModel;
    NSMutableArray *deviceSetArray;
    NSMutableArray *array;
    MKCoordinateSpan theSpan;
    DataManager *manager;
    UIButton* rightBtn;
    NSMutableArray *nameArr;
//    CLLocationCoordinate2D myLocation;
    CLLocationCoordinate2D coor;

}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _geocoder=[[CLGeocoder alloc]init];
    nameArr = [[NSMutableArray alloc] init];

    mapType = 0;
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.saveButton.backgroundColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
        self.mapView.showsScale = YES;
    }
    [self.saveButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];

}

- (void)showSearch
{
    rightBtn.enabled = NO;
    
    nameArr = [[NSMutableArray alloc] init];
    
    //self.mapView.showsUserLocation = YES;
    CLLocationCoordinate2D myLocatio = CLLocationCoordinate2DMake([defaults doubleForKey:@"myLa"], [defaults doubleForKey:@"myLo"]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocatio, 5000, 5000);
    [defaults setDouble:[defaults doubleForKey:@"myLa"] forKey:@"mylocationLa"];
    [defaults setDouble: [defaults doubleForKey:@"myLo"]forKey:@"mylocationLo"];
    [defaults setValue:@"1" forKey:@"search"];
    //初始化一个检索请求对象
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
    //设置检索参数
    req.region=region;
    //兴趣点关键字
    req.naturalLanguageQuery=@"小区";
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
        
        SearchViewController *search = [[SearchViewController alloc] init];
        
        search.title = NSLocalizedString(@"nearby_neighborhood", nil);
        search.isPosition = _isPosition;
        _la=@"iii";
        search.la = _la;
        search.myLocation = _myLocation;
        search.nameArr = nameArr;
        [self.navigationController pushViewController:search animated:YES];
        
    }];
}
#pragma mark: - 地图点击事件
- (void)Tap:(UITapGestureRecognizer *)tap
{
    self.saveButton.enabled = NO;
    self.adressLabel.text = NSLocalizedString(@"get_location", nil);
    
    CGPoint point = [tap locationInView:_mapView];
    
    //要把视图上的位置 转化为经纬度的位置
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    //创建大头针
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    MKOverlayView *overlayView = [[MKOverlayView alloc] init];
    MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
    coor=_myLocation;
    _myLocation = coordinate;
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotation:annotation];
    [_mapView addOverlay:circleTargePlace];
    [self findAddressString:[NSString stringWithFormat:@"%f",coordinate.latitude] longitude:[NSString stringWithFormat:@"%f",coordinate.longitude]];
//    WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
//    webService.tag =1112;
//    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
//    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
//    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
//    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
//
//    NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
//    // webservice请求并获得结果
//    webService.webServiceParameter = parameter;
//    [webService getWebServiceResult:@"GetAddressResult"];
//
//    CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//
//    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//
//        if(placemarks == nil)
//        {
//            [OMGToast showWithText:@"请选择正确的位置" bottomOffset:50 duration:3];
//            return ;
//        }
//
//        CLPlacemark *placemark=[placemarks firstObject];
//        self.adressLabel.text = [NSString stringWithFormat:@"%@",placemark.name];
//        [defaults setObject:placemark.name forKey:@"homeAddress"];
//        [defaults setDouble:coordinate.latitude forKey:@"home_coordinate_latitude"];
//        [defaults setDouble:coordinate.longitude forKey:@"home_coordinate_longitude"];
//
//        self.saveButton.enabled = YES;
//    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //大头针视图
    //注意：为了提高显示效率。显示大头针加入复用机制
    static NSString *annotationId = @"anna";
    YCHomeAnnotationView *pin = (YCHomeAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
    if(pin == nil){
        
        pin = [[YCHomeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
    }
    pin.image = [UIImage imageNamed:@"home_pin"];
    //设置中心点偏移，使得标注底部中间点成为经纬度对应点
    //pin.centerOffset = CGPointMake(0, -18);
    return pin;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *_circleView=[[MKCircleView alloc] initWithCircle:overlay];
        _circleView.fillColor =  [UIColor colorWithRed:137/255.0 green:170/255.0 blue:213/255.0 alpha:0.2];
        _circleView.strokeColor = [UIColor colorWithRed:117/255.0 green:161/255.0 blue:220/255.0 alpha:0.8];
        _circleView.lineWidth=2.0;
        return _circleView;
    }
    return nil;
}

- (IBAction)Zomm:(id)sender {
    
    theSpan.latitudeDelta=self.mapView.region.span.latitudeDelta/2;
    
    theSpan.longitudeDelta=self.mapView.region.span.longitudeDelta/2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapView centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapView setRegion:theRegion];
}

- (IBAction)Zemm:(id)sender {
    if (self.mapView.region.span.latitudeDelta>60||self.mapView.region.span.longitudeDelta>60) {
        return;
    }
    
    theSpan.latitudeDelta=self.mapView.region.span.latitudeDelta*2;
    
    theSpan.longitudeDelta=self.mapView.region.span.longitudeDelta*2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapView centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapView setRegion:theRegion];
    
}

- (IBAction)maoType:(id)sender {
    
    if(mapType==0)
    {
        mapType=1;
        [self.mapButton setBackgroundImage:[UIImage imageNamed:@"planar_map"] forState:UIControlStateNormal];
        [self.mapView setMapType:MKMapTypeSatellite];
    }else{
        [self.mapButton setBackgroundImage:[UIImage imageNamed:@"satellite_maps"] forState:UIControlStateNormal];
        mapType=0;
        [self.mapView setMapType:MKMapTypeStandard];
    }
}

- (IBAction)saveBtn:(id)sender{
    coor=_myLocation;

    [defaults setDouble:_myLocation.latitude forKey:@"homeMapLa"];
    [defaults setDouble:_myLocation.longitude forKey:@"homeMapLo"];
    [defaults setValue:self.adressLabel.text forKey:@"homeMapNa"];
    //获取当前地址信息
//    model.HomeAddress = self.adressLabel.text;
//    XiaoquSetViewController* xiaoqu = [[XiaoquSetViewController alloc]init];
//    NSString* str = self.adressLabel.text;
//    xiaoqu.block(str);
    manager.homeText = self.adressLabel.text;
    [self.navigationController popViewControllerAnimated:YES];
    deviceSetArray =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    deviceSetModel = [deviceSetArray objectAtIndex:0];
    array =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    model.HomeAddress = self.adressLabel.text;
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateDevice" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchinfo/updateHomeAndFamily"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"id" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"homeAddress" andValue:[defaults objectForKey:@"homeAddress"]];
    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"homeLat" andValue:[defaults objectForKey:@"home_coordinate_latitude"]];
    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"homeLng" andValue:[defaults objectForKey:@"home_coordinate_longitude"]];
    WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"schoolAddress" andValue:model.SchoolAddress];
    WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"schoolLat" andValue:model.SchoolLat];
    WebServiceParameter *parameter10 = [WebServiceParameter newWithKey:@"schoolLng" andValue:model.SchoolLng];
    WebServiceParameter *parameter11;
    if(deviceSetModel.ClassDisabled1.length && deviceSetModel.ClassDisabled2.length){
        parameter11 = [WebServiceParameter newWithKey:@"classDisable1" andValue:[NSString stringWithFormat:@"%@-%@",deviceSetModel.ClassDisabled1,deviceSetModel.ClassDisabled2]];
    }else{
        parameter11 = [WebServiceParameter newWithKey:@"classDisable1" andValue:@"00:00"];
    }
    WebServiceParameter *parameter12;
    if(deviceSetModel.ClassDisabled3.length && deviceSetModel.ClassDisabled4.length){
        parameter12 = [WebServiceParameter newWithKey:@"classDisable2" andValue:[NSString stringWithFormat:@"%@-%@",deviceSetModel.ClassDisabled3,deviceSetModel.ClassDisabled4]];
    }else{
        parameter12 = [WebServiceParameter newWithKey:@"classDisable2" andValue:@"00:00"];
    }
    WebServiceParameter *parameter13 = [WebServiceParameter newWithKey:@"weekDisable" andValue:deviceSetModel.WeekDisabled];
    WebServiceParameter *parameter14 = [WebServiceParameter newWithKey:@"latestTime" andValue:model.LatestTime];
    
    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11,parameter12,parameter13,parameter14];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"UpdateDeviceResult"];
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
                    self.adressLabel.text = addstring;
                }else{
                    self.saveButton.enabled = YES;
                    self.adressLabel.text = addstring;
                    [defaults setObject:addstring forKey:@"homeAddress"];
                    [defaults setDouble:latitude.doubleValue forKey:@"home_coordinate_latitude"];
                    [defaults setDouble:longitude.doubleValue forKey:@"home_coordinate_longitude"];
                }
                break;
            }
        }else{
            self.adressLabel.text = @"无法查找地址";
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
            if(code == 1){
                if(ws.tag == 0){
                    [manager updataSQL:@"favourite_info" andType:@"HomeAddress" andValue:[defaults objectForKey:@"homeAddress"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"favourite_info" andType:@"HomeLat" andValue:[defaults objectForKey:@"home_coordinate_latitude"]andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"favourite_info" andType:@"HomeLng" andValue:[defaults objectForKey:@"home_coordinate_longitude"]andBindle:[defaults objectForKey:@"binnumber"]];
                    
                    
                    [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:1];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    NSArray * address = [object objectForKey:@"Nearby"];
                    if(address.count != 0 && address.count>1)
                    {
                        self.adressLabel.text = [NSString stringWithFormat:@"%@%@%@%@,%@,%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"],[[address objectAtIndex:1] objectForKey:@"POI"]];
                        [defaults setObject:[NSString stringWithFormat:@"%@%@%@%@,%@,%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"],[[address objectAtIndex:1] objectForKey:@"POI"]] forKey:@"homeAddress"];
                    }
                    else
                    {
                        self.adressLabel.text = [NSString stringWithFormat:@"%@%@%@%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"]];
                        [defaults setObject:[NSString stringWithFormat:@"%@%@%@%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"]] forKey:@"homeAddress"];
                        
                    }
                    
                    [defaults setDouble:coor.latitude forKey:@"home_coordinate_latitude"];
                    [defaults setDouble:coor.longitude forKey:@"home_coordinate_longitude"];
                    self.saveButton.enabled = YES;
                }
 
            }else if(ws.tag == 0){
                    [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:1];
                }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)viewWillAppear:(BOOL)animated
{
    rightBtn.enabled = YES;

    self.mapView.showsUserLocation = NO;
    manager = [DataManager shareInstance];
    
    array =   [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    self.mapView.delegate = self;
    //获取用户的位置
    CLLocationCoordinate2D co =  _mapView.userLocation.coordinate;
    NSLog(@"long = %f,lan = %f",co.longitude,co.latitude);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    [self.mapView addGestureRecognizer:tap];
    if([[defaults objectForKey:@"homeMapType"] intValue ] == 0)
    {
        if(model.HomeLat.doubleValue > 0&&model.HomeLng.doubleValue > 0)
        {
            CLLocationCoordinate2D coordinate;       //创建大头针
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            
            coordinate.latitude = model.HomeLat.doubleValue;
            coordinate.longitude = model.HomeLng.doubleValue;
            
            annotation.coordinate = coordinate;
            MKOverlayView *overlayView = [[MKOverlayView alloc] init];
            MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
            [_mapView removeOverlays:_mapView.overlays];
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotation:annotation];
            [_mapView addOverlay:circleTargePlace];
            
            theSpan.latitudeDelta=0.01;
            
            theSpan.longitudeDelta=0.01;
            
            MKCoordinateRegion theRegion;
            
            theRegion.center= coordinate;
            
            theRegion.span=theSpan;
            
            [self.mapView setRegion:theRegion];
            self.adressLabel.text = model.HomeAddress;
            
        }
        else
        {
            [self.mapView showsUserLocation];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([defaults doubleForKey:@"myLa"], [defaults doubleForKey:@"myLo"]);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            MKOverlayView *overlayView = [[MKOverlayView alloc] init];
            annotation.coordinate = coordinate;
            
            MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
            [_mapView removeOverlays:_mapView.overlays];
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotation:annotation];
            [_mapView addOverlay:circleTargePlace];
            
            
            theSpan.latitudeDelta=0.01;
            
            theSpan.longitudeDelta=0.01;
            
            MKCoordinateRegion theRegion;
            
            theRegion.center= coordinate;
            
            theRegion.span=theSpan;
            
            [self.mapView setRegion:theRegion];
            [defaults setDouble:coordinate.latitude forKey:@"home_coordinate_latitude"];
            [defaults setDouble:coordinate.longitude forKey:@"home_coordinate_longitude"];
            [self findAddressString:[NSString stringWithFormat:@"%f",coordinate.latitude] longitude:[NSString stringWithFormat:@"%f",coordinate.longitude]];
//            WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
//            webService.tag =1112;
//            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
//            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
//            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
//            WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
//
//            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
//            // webservice请求并获得结果
//            webService.webServiceParameter = parameter;
//            [webService getWebServiceResult:@"GetAddressResult"];
//
//            CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//            [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//                CLPlacemark *placemark=[placemarks firstObject];
//                self.adressLabel.text = [NSString stringWithFormat:@"%@",placemark.name];
//            }];
        }
    }
    else if([[defaults objectForKey:@"homeMapType"] intValue] == 1)
    {
        CLLocationCoordinate2D coordinate;       //创建大头针
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        
        coordinate.latitude = [defaults doubleForKey:@"homeMapLa"];
        coordinate.longitude = [defaults doubleForKey:@"homeMapLo"];
        
        [defaults setDouble:coordinate.latitude forKey:@"home_coordinate_latitude"];
        [defaults setDouble:coordinate.longitude forKey:@"home_coordinate_longitude"];
        MKOverlayView *overlayView = [[MKOverlayView alloc] init];
        MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
              
        annotation.coordinate = coordinate;
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [_mapView addAnnotation:annotation];
        [_mapView addOverlay:circleTargePlace];
        
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center= coordinate;
        
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        self.adressLabel.text = [defaults objectForKey:@"homeMapNa"];
        [defaults setObject:self.adressLabel.text forKey:@"homeAddress"];
        
        
    }
    else if([[defaults objectForKey:@"homeMapType"] intValue] == 2)
    {
        CLLocationCoordinate2D coordinate;       //创建大头针
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        
        coordinate.latitude = [defaults doubleForKey:@"homeMapLa"];
        coordinate.longitude = [defaults doubleForKey:@"homeMapLo"];
        
        [defaults setDouble:coordinate.latitude forKey:@"home_coordinate_latitude"];
        [defaults setDouble:coordinate.longitude forKey:@"home_coordinate_longitude"];
        MKOverlayView *overlayView = [[MKOverlayView alloc] init];
        MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
     
        
        annotation.coordinate = coordinate;
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [_mapView addAnnotation:annotation];
        [_mapView addOverlay:circleTargePlace];
        
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center= coordinate;
        
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        [self findAddressString:[NSString stringWithFormat:@"%f",coordinate.latitude] longitude:[NSString stringWithFormat:@"%f",coordinate.longitude]];
        
//        WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
//        webService.tag =1112;
//        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
//        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
//        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
//        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
//
//        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
//        // webservice请求并获得结果
//        webService.webServiceParameter = parameter;
//        [webService getWebServiceResult:@"GetAddressResult"];
//
//        CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//            CLPlacemark *placemark=[placemarks firstObject];
//            self.adressLabel.text = [NSString stringWithFormat:@"%@",placemark.name];
//            [defaults setObject:self.adressLabel.text forKey:@"homeAddress"];
//
//        }];
    }
    else
    {
        CLLocationCoordinate2D coordinate;       //创建大头针
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        
        coordinate.latitude = [defaults doubleForKey:@"mylocationLa"];
        coordinate.longitude = [defaults doubleForKey:@"mylocationLo"];
        
        [defaults setDouble:coordinate.latitude forKey:@"home_coordinate_latitude"];
        [defaults setDouble:coordinate.longitude forKey:@"home_coordinate_longitude"];
        MKOverlayView *overlayView = [[MKOverlayView alloc] init];
        MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
        [_mapView addOverlay:circleTargePlace];
        
        annotation.coordinate = coordinate;
        [self.mapView addAnnotation:annotation];
        
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center= coordinate;
        
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        [self findAddressString:[NSString stringWithFormat:@"%f",coordinate.latitude] longitude:[NSString stringWithFormat:@"%f",coordinate.longitude]];
        
//        WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
//        webService.tag =1112;
//        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
//        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
//        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
//        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
//
//        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
//        // webservice请求并获得结果
//        webService.webServiceParameter = parameter;
//        [webService getWebServiceResult:@"GetAddressResult"];
//
//        CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//            CLPlacemark *placemark=[placemarks firstObject];
//            self.adressLabel.text = [NSString stringWithFormat:@"%@",placemark.name];
//            [defaults setObject:self.adressLabel.text forKey:@"homeAddress"];
//
//        }];
    }
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
