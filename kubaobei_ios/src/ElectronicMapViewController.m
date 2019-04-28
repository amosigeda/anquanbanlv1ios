//
//  ElectronicMapViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "ElectronicMapViewController.h"
#import "WatchAnnotationView.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "LocationModel.h"
#import "SearchNameViewController.h"
#import "SearchViewController.h"
#import "ElectronicViewController.h"
#import "Constants.h"

@interface ElectronicMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate>
{
    MKCircle *circleTargePlace;
    MKCoordinateSpan theSpan;
    MKPointAnnotation *annotation;
    UIButton* rightBtn;
    DataManager *manager;
    DeviceModel *deviceModel;
    NSMutableArray *deviceArray;
    NSArray *nameArr;
    NSUserDefaults *defaults;
    CLLocationCoordinate2D locationCar;
    LocationModel *localModel;
    CLLocationCoordinate2D coordinate;
    NSMutableArray *searchArray;
    
    BOOL isGPS;
}
@end

@implementation ElectronicMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.cancel_Btn.backgroundColor = MCN_buttonColor;
    self.del_btn.backgroundColor = MCN_buttonColor;
    self.comfire_Btn.backgroundColor = MCN_buttonColor;
    manager = [DataManager shareInstance];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    localModel = [[manager isSelectLocationTable:deviceModel.DeviceID] objectAtIndex:0];
    
    nameArr = [[NSArray alloc] init];
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    
    if([[defaults objectForKey:@"eleMapType"] intValue] == 0)
    {
        [self.navigationItem setRightBarButtonItem:rightBtnItem];
        
    }
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    [self.mapView addGestureRecognizer:tap];
    
    self.mapView.delegate = self;
    //地图
    [ self.mapView setZoomEnabled:YES];
    [ self.mapView setScrollEnabled:YES];
    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    //{
    //self.mapView.showsScale = YES;
    //}
    //self.mapView.sc= CGPointMake(self.mapView.scaleOrigin.x, 22);  //设置比例尺位置
    
    self.fence_label.text = NSLocalizedString(@"fence", nil);
    self.in_fence_Label.text = NSLocalizedString(@"in_fence", nil);
    self.out_fence_Label.text = NSLocalizedString(@"out_fence", nil);
    self.fence_name_Label.text = NSLocalizedString(@"electronic_fence_name", nil);
    self.fence_switch_Label.text = NSLocalizedString(@"fence_switch", nil);
    
    [self.cancel_Btn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.del_btn setTitle:NSLocalizedString(@"del", nil) forState:UIControlStateNormal];
    [self.cancel_btn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.submit_btn setTitle:NSLocalizedString(@"submit", nil) forState:UIControlStateNormal];
    [self.comfire_Btn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    self.alarm_mode_Label.text = NSLocalizedString(@"alarm_mode", nil);
    
    if(deviceModel.CurrentFirmware.length==0)
    {
        deviceModel.CurrentFirmware=@"00000000";
    }
    
    /*
     if(([deviceModel.CurrentFirmware rangeOfString:@"D10_CHUANGMT"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D9_CHUANGMT"].location != NSNotFound)
     ||([deviceModel.CurrentFirmware rangeOfString:@"D9_TP_CHUANGMT"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D12_CHUANGMT"].location != NSNotFound)
     ||([deviceModel.DeviceType isEqualToString:@"2"]))
     */
    if(1)
    {
        isGPS = NO;
    }
    else{
        isGPS = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    rightBtn.enabled = YES;
    
    theSpan.latitudeDelta=0.01;
    
    theSpan.longitudeDelta=0.01;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center= CLLocationCoordinate2DMake(localModel.Latitude.doubleValue,localModel.Longitude.doubleValue);
    
    theRegion.span=theSpan;
    [self.mapView setRegion:theRegion];
    
    if(isGPS)
    {
        [self.slider setMaximumValue:100.0];
        [self.slider setMinimumValue:20.0];
    }
    else
    {
        [self.slider setMaximumValue:100.0];
        [self.slider setMinimumValue:50.0];
    }
    
    [self.bgView.layer setCornerRadius:10];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderWidth = 1;
    self.bgView.layer.borderColor = [navigationBarColor CGColor];
    self.nameTextView.delegate = self;
    
    if([[defaults objectForKey:@"addOrEdit"] intValue] == 0)
    {
        self.delebtn.hidden = NO;
        self.nameTextView.text = [defaults objectForKey:@"genfencenameee"];
        
    }
    else
    {
        self.delebtn.hidden = YES;
        self.nameTextView.text = @"";
    }
    if([[defaults objectForKey:@"eleType"] intValue] == 0)
    {
        
        if([[self.dic objectForKey:@"Entry"] intValue] == 0)
        {
            self.swip1.on = NO;
        }
        else
        {
            self.swip1.on = YES;
            
        }
        if([[self.dic objectForKey:@"Exit"] intValue] == 0)
        {
            self.swip2.on = NO;
        }
        else
        {
            self.swip2.on = YES;
            
        }
        
        if([[self.dic objectForKey:@"Enable"] intValue] == 0)
        {
            self.swip3.on = NO;
        }
        else
        {
            self.swip3.on = YES;
            
        }
        
        if([[defaults objectForKey:@"eleMapType"] intValue] == 0)
        {
            
            if([[self.dic objectForKey:@"Lat"] intValue] == 0 && [[self.dic objectForKey:@"Lat"] intValue] == 0)
            {
                locationCar.latitude = [[defaults objectForKey:@"mylocationLa"] doubleValue];
                locationCar.longitude = [[defaults objectForKey:@"mylocationLo"] doubleValue];
            }
            else
            {
                locationCar.latitude = [[self.dic objectForKey:@"Lat"] doubleValue];
                locationCar.longitude = [[self.dic objectForKey:@"Lng"] doubleValue];
                
            }
        }
        else if ([[defaults objectForKey:@"eleMapType"] intValue] == 1)
        {
            if([[defaults objectForKey:@"eleMapLa"] intValue] == 0 && [[defaults objectForKey:@"eleMapLo"] intValue] == 0)
            {
                locationCar.latitude = [[defaults objectForKey:@"mylocationLa"] doubleValue];
                locationCar.longitude = [[defaults objectForKey:@"mylocationLo"] doubleValue];
            }
            else
            {
                locationCar.latitude = [[defaults objectForKey:@"eleMapLa"] doubleValue];
                locationCar.longitude = [[defaults objectForKey:@"eleMapLo"] doubleValue];
            }
            
        }
        else if ([[defaults objectForKey:@"eleMapType"] intValue] == 2)
        {
            if([[defaults objectForKey:@"eleMapLa"] intValue] == 0 && [[defaults objectForKey:@"eleMapLo"] intValue] == 0)
            {
                locationCar.latitude = [[defaults objectForKey:@"mylocationLa"] doubleValue];
                locationCar.longitude = [[defaults objectForKey:@"mylocationLo"] doubleValue];
            }
            else
            {
                locationCar.latitude = [[defaults objectForKey:@"eleMapLa"] doubleValue];
                locationCar.longitude = [[defaults objectForKey:@"eleMapLo"] doubleValue];
            }
        }
        else
        {
            locationCar.latitude = [[defaults objectForKey:@"mylocationLa"] doubleValue];
            locationCar.longitude = [[defaults objectForKey:@"mylocationLo"] doubleValue];
            
        }
        coordinate = locationCar;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center=locationCar;
        theSpan.latitudeDelta=0.01;
        //
        theSpan.longitudeDelta=0.01;
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        MKPointAnnotation *annotations = [[MKPointAnnotation alloc] init];
        if(annotations)
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
        annotations.coordinate = locationCar;
        [self.mapView addAnnotation:annotations];
        
        if([[defaults objectForKey:@"eleMapType"] intValue] == 0)
        {
            if([[self.dic objectForKey:@"Radii"] intValue] == 0)
            {
                if(isGPS)
                {
                    circleTargePlace=[MKCircle circleWithCenterCoordinate:locationCar radius:200];
                }
                else{
                    circleTargePlace=[MKCircle circleWithCenterCoordinate:locationCar radius:500];
                }
            }
            else
            {
                circleTargePlace=[MKCircle circleWithCenterCoordinate:locationCar radius:[[self.dic objectForKey:@"Radii"] intValue]];
                
            }
            
            if(circleTargePlace)
            {
                [self.mapView removeOverlays:self.mapView.overlays];
            }
            [_mapView addOverlay:circleTargePlace];
            if([[self.dic objectForKey:@"Radii"] intValue] == 0)
            {
                self.slider.value = 0;;
                
            }
            else
            {
                self.slider.value = [[self.dic objectForKey:@"Radii"] intValue] / 10;
                
            }
            
            if([[self.dic objectForKey:@"Radii"] intValue] == 0)
            {
                if(isGPS)
                {
                    self.radiusLabel.text = [NSString stringWithFormat:@"%@: %d%@",NSLocalizedString(@"radius", nil),200,NSLocalizedString(@"m", nil)];
                }
                else{
                    self.radiusLabel.text = [NSString stringWithFormat:@"%@: %d%@",NSLocalizedString(@"radius", nil),500,NSLocalizedString(@"m", nil)];
                }
                
            }
            else
            {
                self.radiusLabel.text = [NSString stringWithFormat:@"%@: %d%@",NSLocalizedString(@"radius", nil),[[self.dic objectForKey:@"Radii"] intValue],NSLocalizedString(@"m", nil)];
                
            }
            
        }
        else
        {
            if(isGPS)
            {
                circleTargePlace=[MKCircle circleWithCenterCoordinate:locationCar radius:200];
            }
            else{
                circleTargePlace=[MKCircle circleWithCenterCoordinate:locationCar radius:500];
            }
            if(circleTargePlace)
            {
                [self.mapView removeOverlays:self.mapView.overlays];
            }
            [_mapView addOverlay:circleTargePlace];
            self.slider.value = [[self.dic objectForKey:@"Radii"] intValue] / 10;
            
            self.radiusLabel.text = [NSString stringWithFormat:@"%@: %d%@",NSLocalizedString(@"radius", nil),(int)self.slider.value*10,NSLocalizedString(@"m", nil)];
        }
    }
    else
    {
        self.slider.value = 20;
        self.swip1.on = YES;
        self.swip2.on = YES;
        self.swip3.on = YES;
        
        if([localModel.Latitude intValue] == 0 &&[localModel.Longitude intValue] == 0)
        {
            locationCar.latitude = [defaults doubleForKey:@"myLa"];
            locationCar.longitude = [defaults doubleForKey:@"myLo"];
        }
        else
        {
            locationCar.latitude = [localModel.Latitude doubleValue];
            locationCar.longitude = [localModel.Longitude doubleValue];
        }
        
        coordinate = CLLocationCoordinate2DMake(locationCar.latitude, locationCar.longitude);
        MKCoordinateRegion theRegion;
        
        theRegion.center=locationCar;
        theSpan.latitudeDelta=0.01;
        //
        theSpan.longitudeDelta=0.01;
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        MKPointAnnotation *annotations = [[MKPointAnnotation alloc] init];
        if(annotations)
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
        annotations.coordinate = locationCar;
        [self.mapView addAnnotation:annotations];
        
        if(isGPS)
        {
            circleTargePlace=[MKCircle circleWithCenterCoordinate:locationCar radius:200];
        }
        else{
            circleTargePlace=[MKCircle circleWithCenterCoordinate:locationCar radius:500];
        }
        if(circleTargePlace)
        {
            [self.mapView removeOverlays:self.mapView.overlays];
        }
        [_mapView addOverlay:circleTargePlace];
        
        if(isGPS)
        {
            self.radiusLabel.text = [NSString stringWithFormat:@"%@: %d%@",NSLocalizedString(@"radius", nil),200,NSLocalizedString(@"m", nil)];
        }
        else{
            self.radiusLabel.text = [NSString stringWithFormat:@"%@: %d%@",NSLocalizedString(@"radius", nil),500,NSLocalizedString(@"m", nil)];
        }
        
    }
}

- (void)showNext
{
    [defaults setValue:@"0" forKey:@"eleType"];
    rightBtn.enabled = NO;
    searchArray = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D myLocatio = CLLocationCoordinate2DMake([defaults doubleForKey:@"myLa"], [defaults doubleForKey:@"myLo"]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocatio, 5000, 5000);
    
    [defaults setDouble:[defaults doubleForKey:@"myLa"] forKey:@"mylocationLa"];
    [defaults setDouble:[defaults doubleForKey:@"myLo"] forKey:@"mylocationLo"];
    [defaults setValue:@"2" forKey:@"search"];
    //初始化一个检索请求对象
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
    //设置检索参数
    req.region=region;
    //兴趣点关键字
    req.naturalLanguageQuery=@"学校";
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
            [searchArray addObject:item];
            NSLog(@"%@",item.name);
        }
        
        SearchViewController *search = [[SearchViewController alloc] init];
        
        search.title = NSLocalizedString(@"search_school", nil);
        
        search.myLocation = myLocatio;
        search.nameArr = searchArray;
        
        [self.navigationController pushViewController:search animated:YES];
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)Tap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:_mapView];
    
    //要把视图上的位置 转化为经纬度的位置
    coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    //创建大头针
    annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    //MKOverlayView *overlayView = [[MKOverlayView alloc] init];
    circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:self.slider.value*10];
    
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotation:annotation];
    [_mapView addOverlay:circleTargePlace];
}

- (IBAction)sliderAtion:(id)sender {
    
    UISlider *slider = sender;
    
    if(annotation == nil)
    {
        annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = locationCar;
    }
    
    circleTargePlace=[MKCircle circleWithCenterCoordinate:annotation.coordinate radius:slider.value*10];
    
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView addOverlay:circleTargePlace];
    
    self.radiusLabel.text = [NSString stringWithFormat:@"%@: %d%@",NSLocalizedString(@"radius", nil),(int)slider.value*10,NSLocalizedString(@"m", nil)];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation)
        
        return nil;
    //大头针视图
    //注意：为了提高显示效率。显示大头针加入复用机制
    static NSString *annotationId = @"ann";
    WatchAnnotationView *pin = (WatchAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
    if(pin == nil){
        
        pin = [[WatchAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
    }
    pin.image = [UIImage imageNamed:@"location_watch"];
    //设置中心点偏移，使得标注底部中间点成为经纬度对应点
    //pin.centerOffset = CGPointMake(0, -18);
    return pin;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKCircleRenderer * render=[[MKCircleRenderer alloc]initWithCircle:overlay];
    render.lineWidth=1;    //填充颜色
    render.fillColor=[UIColor orangeColor];
    render.alpha = 0.4;//线条颜色
    render.strokeColor=[UIColor redColor];
    return render;
    
    
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *_circleView=[[MKCircleView alloc] initWithCircle:overlay];
    _circleView.fillColor =  [UIColor redColor];
    _circleView.strokeColor = [UIColor greenColor];
    _circleView.lineWidth=2.0;
    return _circleView;
}

- (IBAction)cancelAction:(id)sender {
    
    self.bgView.hidden = YES;
}

- (IBAction)confirmAction:(id)sender {
    
    WebService *webService = [WebService newWithWebServiceAction:@"SaveGeoFence" andDelegate:self];
    BOOL isAdd = !([[defaults objectForKey:@"addOrEdit"] intValue] == 0);
    WebServiceParameter *parameter1;
    WebServiceParameter *parameter4;
    WebServiceParameter *parameter5;
    if(isAdd){
        webService.tag = 0;
        parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"security/addwatchfence"];
        parameter5 = [WebServiceParameter newWithKey:@"fenceName" andValue:self.nameTextView.text];
    }else{
        webService.tag = 1;
        parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"security/updatewatchfence"];
        parameter4 = [WebServiceParameter newWithKey:@"id" andValue:[defaults objectForKey:@"genfenceidddd"]];
        parameter5 = [WebServiceParameter newWithKey:@"name" andValue:self.nameTextView.text];
    }
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"entry" andValue:self.swip1.isOn ? @"1" : @"0"];
    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"exit" andValue:self.swip2.isOn ? @"1" : @"0"];
    WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"enable" andValue:self.swip3.isOn?@"1":@"0"];
    WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%f",coordinate.latitude]];
    WebServiceParameter *parameter10 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%f",coordinate.longitude]];
    WebServiceParameter *parameter11 = [WebServiceParameter newWithKey:@"radius" andValue:[NSString stringWithFormat:@"%d",(int)self.slider.value * 10]];
    NSArray *parameter;
    if(isAdd){
        parameter = @[parameter1, parameter2,parameter3,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11];
    }else{
        parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11];
    }
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"SaveGeoFenceResult"];
    
    self.bgView.hidden = YES;
    
}

- (IBAction)dele:(id)sender {
    
    WebService *webService = [WebService newWithWebServiceAction:@"DeleteGeoFence" andDelegate:self];
    webService.tag = 3;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"security/deletewatchfence/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[self.dic objectForKey:@"GeofenceID"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"DeleteGeoFenceResult"];
    
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
                    [OMGToast showWithText:NSLocalizedString(@"add_success", nil) bottomOffset:50 duration:2];
                }else if(ws.tag == 1){
                    [OMGToast showWithText:NSLocalizedString(@"edit_success", nil) bottomOffset:50 duration:2];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"del_success", nil) bottomOffset:50 duration:2];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else if(ws.tag == 0){
                [OMGToast showWithText:NSLocalizedString(@"save_fail", nil) bottomOffset:50 duration:2];
            }else if(ws.tag == 1){
                [OMGToast showWithText:NSLocalizedString(@"save_fail", nil) bottomOffset:50 duration:2];
            }else if(ws.tag == 3){
                [OMGToast showWithText:NSLocalizedString(@"del_fail", nil) bottomOffset:50 duration:2];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (IBAction)swip:(id)sender {
    
    
    
}

- (IBAction)swip2:(id)sender {
}

- (IBAction)tijiao:(id)sender {
    
    self.bgView.hidden = NO;
}

- (IBAction)clean:(id)sender {
    
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    self.slider.value = 0;
    self.radiusLabel.text =[NSString stringWithFormat:@"%@:500%@",NSLocalizedString(@"radius", nil),NSLocalizedString(@"m", nil)] ;
}

- (IBAction)zoomIn:(id)sender {
    
    if (self.mapView.region.span.latitudeDelta>60||self.mapView.region.span.longitudeDelta>60) {
        return;
    }
    theSpan.latitudeDelta=self.mapView.region.span.latitudeDelta/2;
    
    theSpan.longitudeDelta=self.mapView.region.span.longitudeDelta/2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapView centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapView setRegion:theRegion];
}

- (IBAction)zoomOut:(id)sender {
    
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
