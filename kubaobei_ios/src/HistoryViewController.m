//
//  HistoryViewController.m
///  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "HistoryViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "HistoryAnnotationView.h"
#import "WatchAnnotationView.h"
#import "HistoryAnntaionView.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "GMDCircleLoader.h"
#import "CustomAnnotation.h"
#import "LocationModel.h"
#import "Constants.h"

@interface HistoryViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,JTCalendarDataSource>
{
    NSUserDefaults *defaults;
    NSString *startTime;
    NSMutableArray *dataArray;
    MKCoordinateSpan theSpan;
    CLLocationCoordinate2D locationCar;
    CLLocationCoordinate2D locationCar_next;
    CLLocationCoordinate2D locationCar_prev;
    int mapType;
    int index;
    bool play;
    float interval;
    NSTimer *timer;
    MKPointAnnotation *annotations;
    CustomAnnotation *cusAnn;
    DataManager *manager;
    DeviceModel *model;

    BOOL isShow;
    BOOL start;
    BOOL g_start;
    BOOL isGPS;
    
    NSMutableArray *deviceArray;
    NSMutableArray *array;
    int index_old;
    CLLocationCoordinate2D locationNew;
}
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mapType = 0;
    isShow = NO;
    start = NO;
    defaults = [NSUserDefaults standardUserDefaults];
    dataArray = [[NSMutableArray alloc] init];
    self.navigationController.navigationBar.barTintColor =navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    UIButton * rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setImage:[UIImage imageNamed:@"day_normal"] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    manager = [DataManager shareInstance];
    model =  [[manager isSelect:[defaults objectForKey:@"binnumber"]] objectAtIndex:0];
    
    self.mapView.delegate = self;
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    self.bgView.layer.borderWidth = 1;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
        self.mapView.showsScale = YES;
    }
    //self.mapView.scaleOrigin= CGPointMake(_mapView.scaleOrigin.x, 22);  //设置比例尺位置
    
    self.bgView.layer.borderColor = [navigationBarColor CGColor];
    self.calendar = [JTCalendar new];
    
    [self.calendar setMenuMonthsView:self.MouthView];
    [self.calendar setContentView:self.ContentView];
    [self.calendar setDataSource:self];
    
    NSDateFormatter *deteFormatter = [[NSDateFormatter alloc] init];
    [deteFormatter setDateFormat:@"yyyy-MM-dd"];
    startTime = [deteFormatter stringFromDate:[NSDate  date]];
    [self.uiSlider_Speed setMaximumValue:100.0];
    [self.uiSlider_Speed setMinimumValue:10.0];
    
    [self.uiSlider_Speed setValue:20];
    [self.uiProgress_index setProgress:0];
    [self loadData];
    [defaults setObject:0 forKey:@"annType"];
    
    
    self.pross_Label.text = NSLocalizedString(@"play_progress", nil);
    self.speed_Label.text = NSLocalizedString(@"play_speed", nil);
    [self.stop_Btn setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
    [self.follow_Btn setTitle:NSLocalizedString(@"follow", nil) forState:UIControlStateNormal];
    [self.startbtn setTitle:NSLocalizedString(@"start", nil) forState:UIControlStateNormal];
    [self.forward_Btn setTitle:NSLocalizedString(@"forward", nil) forState:UIControlStateNormal];
    [self.back_Btn setTitle:NSLocalizedString(@"rewind", nil) forState:UIControlStateNormal];
    [self.hidelbs_Btn setTitle:NSLocalizedString(@"Hide_lbs", nil) forState:UIControlStateNormal];
    [self.hidelbsSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    g_start=NO;
    
    if(model.CurrentFirmware.length==0)
    {
        model.CurrentFirmware=@"00000000";
    }
    
    if(([model.CurrentFirmware rangeOfString:@"D10_CHUANGMT"].location != NSNotFound)||([model.CurrentFirmware rangeOfString:@"D9_CHUANGMT"].location != NSNotFound)||([model.CurrentFirmware rangeOfString:@"D9_TP_CHUANGMT"].location != NSNotFound)||([model.CurrentFirmware rangeOfString:@"D12_CHUANGMT"].location != NSNotFound))
    {
        isGPS = NO;
        self.hidelbs_Btn.hidden = YES;
        self.hidelbsSwitch.hidden = YES;
        
    }
    else{
        isGPS = YES;
        self.hidelbs_Btn.hidden = NO;
        self.hidelbsSwitch.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.calendar reloadData]; // （必须要在这里调用）Must be call in viewDidAppear
}

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    startTime = dateString;
    [self.startbtn setTitle:NSLocalizedString(@"start", nil) forState:UIControlStateNormal];

    self.bgView.hidden = YES;
    index = 0;
    isShow = NO;
    g_start=NO;

    self.uiProgress_index.progress = 0;
    
    [timer invalidate];
    [self loadData];
}


- (void)showNext
{
    
    if (!isShow) {
        self.bgView.hidden = NO;
        isShow = YES;
    }
    else
    {
        self.bgView.hidden = YES;
        isShow = NO;
    }
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    
    if (isButtonOn)
    {
        [self loadData];
    }
    else
    {
        for(int i = 0; i < dataArray.count;i++)
        {
            if([[[dataArray objectAtIndex:i] objectForKey:@"LocationType"] intValue] == 2)
            {
                [dataArray removeObjectAtIndex:i];
            }
        }
    }
}

- (void)hidelbs
{
    if(self.hidelbsSwitch.isOn == NO&&g_start==NO)
    {
        for(int i = 0; i < dataArray.count;i++)
        {
            if([[[dataArray objectAtIndex:i] objectForKey:@"LocationType"] intValue] == 2)
            {
                [dataArray removeObjectAtIndex:i];
            }
        }
    }
    
}

- (void)loadData
{
    [GMDCircleLoader setOnView:self.view withTitle:NSLocalizedString(@"load", nil) animated:YES];
    [self.mapView removeOverlays:self.mapView.overlays];

    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceHistory" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"location/track"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"starttime" andValue:[NSString stringWithFormat:@"%@ 00:00:00",startTime]];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"endtime" andValue:[NSString stringWithFormat:@"%@ 23:59:59",startTime]];

    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceHistoryResult"];
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
            
            [GMDCircleLoader hideFromView:self.view animated:YES];

            if(code == 1){
                [dataArray removeAllObjects];
                dataArray = [object objectForKey:@"List"];
                
                [defaults setObject:@"0" forKey:@"ShowAnn"];
                [self correctTrack];
                [self showView];
                self.bottomBgView.hidden = NO;
            }else{
                self.bottomBgView.hidden = YES;
                [self.mapView removeAnnotations:self.mapView.annotations];
                [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:3];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)showView
{
    
    for(int i = 0; i < dataArray.count;i++)
    {
        locationCar.latitude = [[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue];
        locationCar.longitude = [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"]  doubleValue];
        
        if(locationCar.latitude>90.0)
        {
            [dataArray removeObjectAtIndex:i];
        }
        
        theSpan.latitudeDelta=self.mapView.region.span.latitudeDelta;
        
        theSpan.longitudeDelta=self.mapView.region.span.longitudeDelta;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center=locationCar;
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        
        MKPointAnnotation *annotationss = [[MKPointAnnotation alloc] init];
        annotationss.coordinate = locationCar;
        [self.mapView addAnnotation:annotationss];
        
    }

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    static NSString *annotationId1 = @"4rfdfdrrn";
    static NSString *annotationId2 = @"4rrVBNMFVBNMFVBNM";
    
    [self hidelbs];
    
    if ([annotation isKindOfClass:[CustomAnnotation class]])
    {
        //注意：为了提高显示效率。显示大头针加入复用机制
        
            if(index < dataArray.count)
            {
                HistoryAnntaionView *pindd = (HistoryAnntaionView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationId2];
                pindd = [[HistoryAnntaionView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId2];
                
                NSString *str;
                if([[[dataArray objectAtIndex:index] objectForKey:@"LocationType"] intValue] == 1)
                {
                    str = @"GPS";
                    
                }
                else if([[[dataArray objectAtIndex:index] objectForKey:@"LocationType"] intValue] == 2)
                {
                    if(isGPS==NO)
                    {
                        str = @"GPS";
                    }
                    else{
                        str = @"LBS";
                    }
                    
                }
                else
                {
                    str = @"WIFI";
                }
                
                [pindd createUIWithName:model.BabyName andType:str andTime:[[dataArray objectAtIndex:index] objectForKey:@"Time"]];
                
                return pindd;
                
            }
    }
    else
    {
            //大头针视图
            //注意：为了提高显示效率。显示大头针加入复用机制
            
            HistoryAnnotationView *pin = (HistoryAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationId1];
            if(pin == nil){
                
                pin = [[HistoryAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId1];
            }
            pin.image = [UIImage imageNamed:@"history_point"];
        
            return pin;
    }
    return nil;
}

- (void)setviewinfo
{
    self.bgView.hidden = YES;
    [timer invalidate];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

- (IBAction)slideAction:(id)sender {
    if(start)
    {
        if(timer)
        {
            [timer invalidate];
            timer=nil;
        }
        
        if(index == 0)
        {
            self.uiProgress_index.progress = 0;
            [self.mapView removeOverlays:self.mapView.overlays];
        }
        
        if(dataArray.count>300)
        {
            interval=dataArray.count / self.uiSlider_Speed.value/7;
        }
        else if(dataArray.count>100&&dataArray.count<=300)
        {
            interval=dataArray.count / self.uiSlider_Speed.value/5;
        }
        else if(dataArray.count>50&&dataArray.count<=100){
            interval=dataArray.count / self.uiSlider_Speed.value/3;
        }
        else{
            interval=dataArray.count / self.uiSlider_Speed.value/1;
        }
        
        timer=[NSTimer scheduledTimerWithTimeInterval:interval
                                               target:self
                                             selector:@selector(doHistory)
                                             userInfo:nil repeats:YES];
    }

}


- (IBAction)startAction:(id)sender {
    if(!start)
    {
        //[self hidelbs];
        
        [self.startbtn setTitle:NSLocalizedString(@"pause", nil) forState:UIControlStateNormal];
        if(timer)
        {
            [timer invalidate];
            timer=nil;
        }
        
        if(index == 0)
        {
             self.uiProgress_index.progress = 0;
            [self.mapView removeOverlays:self.mapView.overlays];
        }
        
        if(dataArray.count>300)
        {
            interval=dataArray.count / self.uiSlider_Speed.value/7;
        }
        else if(dataArray.count>100&&dataArray.count<=300)
        {
            interval=dataArray.count / self.uiSlider_Speed.value/5;
        }
        else if(dataArray.count>50&&dataArray.count<=100){
            interval=dataArray.count / self.uiSlider_Speed.value/3;
        }
        else{
            interval=dataArray.count / self.uiSlider_Speed.value/1;
        }
        
        timer=[NSTimer scheduledTimerWithTimeInterval:interval
                                               target:self
                                             selector:@selector(doHistory)
                                             userInfo:nil repeats:YES];
        start = YES;
        g_start= YES;
    }
    else
    {
        [self.startbtn setTitle:NSLocalizedString(@"start", nil) forState:UIControlStateNormal];
        [timer invalidate];
        start = NO;
    }
}

- (IBAction)forwardAction:(id)sender {
    //if(g_start==YES)
    {
        if(start==YES)
        {
            [self.startbtn setTitle:NSLocalizedString(@"start", nil) forState:UIControlStateNormal];
            start = NO;
        }
        [timer invalidate];

        if(index>index_old)
        {
            index_old=index;
        }
        if(index < dataArray.count)
        {
            [defaults setObject:@"1" forKey:@"annType"];
            [self.mapView removeAnnotation:cusAnn];
            
            [self showDeviceback];
            
            index++;
            //index=index_old;

            [self.uiProgress_index setProgress:(1/interval/10)*index/self.uiSlider_Speed.value animated:YES];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"annType"];
            
            index = 0;
            self.uiProgress_index.progress = 0;
            [timer invalidate];
            
            [self.mapView removeAnnotation:cusAnn];
        }
    }
    
}

- (IBAction)forwardlongressAction:(id)sender {
    //if(g_start==YES)
    {
        [timer invalidate];
        
        if(timer)
        {
            timer=nil;
        }
        
        if(index == 0)
        {
            self.uiProgress_index.progress = 0;
            [self.mapView removeOverlays:self.mapView.overlays];
        }
        
        interval=dataArray.count / self.uiSlider_Speed.value/11;
        
        timer=[NSTimer scheduledTimerWithTimeInterval:interval
                                               target:self
                                             selector:@selector(doHistoryforward)
                                             userInfo:nil repeats:YES];
    }
    
}

- (IBAction)backAction:(id)sender {
    //if(g_start==YES)
    {
        if(start==YES)
        {
            [self.startbtn setTitle:NSLocalizedString(@"start", nil) forState:UIControlStateNormal];
            start = NO;
        }
        [timer invalidate];
        
        if(index < dataArray.count)
        {
            [defaults setObject:@"1" forKey:@"annType"];
            [self.mapView removeAnnotation:cusAnn];
            
            [self showDeviceback];
            
            index--;
            //index=index_old;
        
            [self.uiProgress_index setProgress:(1/interval/10)*index/self.uiSlider_Speed.value animated:YES];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"annType"];
            
            index = 0;
            self.uiProgress_index.progress = 0;
            [timer invalidate];
            
            [self.mapView removeAnnotation:cusAnn];
        }
    }
}

- (IBAction)backlongressAction:(id)sender {
    //if(g_start==YES)
    {
        [timer invalidate];
        
        if(timer)
        {
            [timer invalidate];
            timer=nil;
        }
        
        if(index == 0)
        {
            self.uiProgress_index.progress = 0;
            [self.mapView removeOverlays:self.mapView.overlays];
        }
        
        interval=dataArray.count / self.uiSlider_Speed.value/11;
        
        timer=[NSTimer scheduledTimerWithTimeInterval:interval
                                               target:self
                                             selector:@selector(doHistoryback)
                                             userInfo:nil repeats:YES];
    }
    
}

- (void)doHistoryforward
{
    if(index < dataArray.count)
    {
        [defaults setObject:@"1" forKey:@"annType"];
        [self.mapView removeAnnotation:cusAnn];
        
        [self showDeviceback];
        
        index_old=index-1;
        index++;
        
        [self.uiProgress_index setProgress:(1/interval/13)*index/self.uiSlider_Speed.value animated:YES];
    }
    else
    {
        [defaults setObject:@"0" forKey:@"annType"];
        
        index = 0;
        self.uiProgress_index.progress = 0;
        [timer invalidate];
        
        [self.mapView removeAnnotation:cusAnn];
    }
}


- (void)doHistoryback
{
    if(index < dataArray.count)
    {
        [defaults setObject:@"1" forKey:@"annType"];
        [self.mapView removeAnnotation:cusAnn];
        
        [self showDeviceback];
        
        index_old=index-1;
        index--;
        [self.uiProgress_index setProgress:(1/interval/13)*index/self.uiSlider_Speed.value animated:YES];
    }
    else
    {
        [defaults setObject:@"0" forKey:@"annType"];
        
        index = 0;
        self.uiProgress_index.progress = 0;
        [timer invalidate];
        
        [self.mapView removeAnnotation:cusAnn];
    }
}

- (void)doHistory
{
    if(index < dataArray.count)
    {
        [defaults setObject:@"1" forKey:@"annType"];
        [self.mapView removeAnnotation:cusAnn];

        [self showDevice];
        
        index_old=index-1;
        index++;
        
        [self.uiProgress_index setProgress:(1/interval/10)*index/self.uiSlider_Speed.value animated:YES];
    }
    else
    {
        [defaults setObject:@"0" forKey:@"annType"];

        index = 0;
        self.uiProgress_index.progress = 0;
        [timer invalidate];
        
        [self.mapView removeAnnotation:cusAnn];
    }
}

- (void)showDeviceback
{
    locationCar.latitude = [[[dataArray objectAtIndex:index] objectForKey:@"Latitude"] doubleValue];
    locationCar.longitude = [[[dataArray objectAtIndex:index] objectForKey:@"Longitude"] doubleValue];
    
    MKCoordinateRegion theRegion;
    
    if(self.gensuiSwitch.isOn == YES)
    {
        theSpan.latitudeDelta=0.003;
        //
        theSpan.longitudeDelta=0.003;
        
        theRegion.center=locationCar;
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
    }
    
    cusAnn = [[CustomAnnotation alloc] init];
    cusAnn.coordinate = locationCar;
    
    [self.mapView addAnnotation:cusAnn];
}

- (void)showDevice
{
    locationCar.latitude = [[[dataArray objectAtIndex:index] objectForKey:@"Latitude"] doubleValue];
    locationCar.longitude = [[[dataArray objectAtIndex:index] objectForKey:@"Longitude"] doubleValue];
    
    MKCoordinateRegion theRegion;
    
    if(self.gensuiSwitch.isOn == YES)
    {
        theSpan.latitudeDelta=0.003;
        //
        theSpan.longitudeDelta=0.003;
        
        theRegion.center=locationCar;
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
    }
    
    cusAnn = [[CustomAnnotation alloc] init];
    cusAnn.coordinate = locationCar;

    [self.mapView addAnnotation:cusAnn];
    if(index > 0)
    {
        MKMapPoint *coos;
        coos = malloc(sizeof(CLLocationCoordinate2D)*2);
        CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([defaults doubleForKey:@"hisLat"],[defaults doubleForKey:@"hisLog"]);
        CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake(locationCar.latitude , locationCar.longitude);
        coos[0] = MKMapPointForCoordinate(coord1);
        coos[1] = MKMapPointForCoordinate(coord2);
        MKPolyline *line = [MKPolyline polylineWithPoints:coos count:2];
        [self.mapView addOverlay: line];
        
    }
    
    [defaults setDouble:[[[dataArray objectAtIndex:index] objectForKey:@"Latitude"] doubleValue] forKey:@"hisLat"];
    [defaults setDouble:[[[dataArray objectAtIndex:index] objectForKey:@"Longitude"] doubleValue] forKey:@"hisLog"];
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *lineview=[[MKPolylineView alloc] initWithOverlay:overlay] ;
        lineview.strokeColor=[[UIColor redColor] colorWithAlphaComponent:0.5];
        lineview.lineWidth=5;
        return lineview;
    }
    return nil;
}

- (IBAction)stopAction:(id)sender {
    index = 0;
    
    self.uiProgress_index.progress = 0;
    [self.startbtn setTitle:NSLocalizedString(@"start", nil) forState:UIControlStateNormal];
    start = NO;
    [timer invalidate];
    [self.mapView removeAnnotation:cusAnn];
    [self.mapView removeOverlays:self.mapView.overlays];
}
- (IBAction)cancelAction:(id)sender {
    self.bottomBgView.hidden = YES;
    [self.mapView removeAnnotation:cusAnn];
    index = 0;
    [self.mapView removeOverlays:self.mapView.overlays];

    [timer invalidate];
}

- (IBAction)zoomOut:(id)sender {
    
    theSpan.latitudeDelta=self.mapView.region.span.latitudeDelta/2;
    
    theSpan.longitudeDelta=self.mapView.region.span.longitudeDelta/2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapView centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapView setRegion:theRegion];
}

- (IBAction)zoomIn:(id)sender {
    
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

- (IBAction)mapType:(id)sender {
    
    if(mapType==0)
    {
        mapType=1;
        [self.mapType setImage:[UIImage imageNamed:@"planar_map"] forState:UIControlStateNormal];
        [self.mapView setMapType:MKMapTypeSatellite];
    }else{
        [self.mapType setImage:[UIImage imageNamed:@"satellite_maps"] forState:UIControlStateNormal];
        mapType=0;
        [self.mapView setMapType:MKMapTypeStandard];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//基站历史轨迹优化
#pragma mark - calculate distance  根据2个经纬度计算距离

#define PI 3.1415926
//+(double) distancePoint:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2{
double distancePoint(double lat1, double lon1, double lat2, double lon2) {
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}

double LantitudeLongitudeDist(double n1, double e1, double n2, double e2) {
    
    double jl_jd = 102834.74258026089786013677476285;
    double jl_wd = 111712.69150641055729984301412873;
    double b = fabs((e1 - e2) * jl_jd);
    double a = fabs((n1 - n2) * jl_wd);
    double dist = sqrt((a * a + b * b));
    return dist;
}

- (void)filterTrack
{
    for (int i = 1; i < dataArray.count-1;i++)
    {
        locationCar.latitude = [[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue];
        locationCar.longitude = [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"] doubleValue];
        
        locationCar_next.latitude = [[[dataArray objectAtIndex:i-1] objectForKey:@"Latitude"] doubleValue];
        locationCar_next.longitude = [[[dataArray objectAtIndex:i-1] objectForKey:@"Longitude"] doubleValue];
        
        locationCar_prev.latitude = [[[dataArray objectAtIndex:i+1] objectForKey:@"Latitude"] doubleValue];
        locationCar_prev.longitude = [[[dataArray objectAtIndex:i+1] objectForKey:@"Longitude"] doubleValue];
        
        if(locationCar.latitude>90.0)
        {
            locationCar.latitude-=90;
        }
        if(locationCar_next.latitude>90.0)
        {
            locationCar_next.latitude-=90;
        }
        if(locationCar_prev.latitude>90.0)
        {
            locationCar_prev.latitude-=90;
        }
        double c = distancePoint(locationCar.latitude, locationCar.longitude, locationCar_next.latitude, locationCar_next.longitude);
        
        if (c > 800){
            double b = distancePoint(locationCar_next.latitude, locationCar_next.longitude, locationCar_prev.latitude, locationCar_prev.longitude);
            if (b > 0){
                if (c / b >= 2) {
                    locationCar.latitude=(locationCar_next.latitude+locationCar_prev.latitude)/2;
                    locationCar.longitude=(locationCar_next.longitude+locationCar_prev.longitude)/2;
                }
            }
        }
        
    }
}

- (void)CoordinateOptimization
{
    for (int i = 1; i < dataArray.count - 1; i++)
    {
        locationCar.latitude = [[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue];
        locationCar.longitude = [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"] doubleValue];
        locationCar_next.latitude = [[[dataArray objectAtIndex:i-1] objectForKey:@"Latitude"] doubleValue];
        locationCar_next.longitude = [[[dataArray objectAtIndex:i-1] objectForKey:@"Longitude"] doubleValue];
        
        if(locationCar.latitude>90.0)
        {
            locationCar.latitude-=90;
        }
        if(locationCar_next.latitude>90.0)
        {
            locationCar_next.latitude-=90;
        }

        double c = distancePoint(locationCar.latitude, locationCar.longitude, locationCar_next.latitude,  locationCar_next.longitude);
        
        if (c < 800) {
            int j = 0;
            for (j = i + 1; j < dataArray.count - 1; j++) {
                
                //locationCar_prev.latitude = [[[dataArray objectAtIndex:j] objectForKey:@"Latitude"] doubleValue];
                //locationCar_prev.longitude = [[[dataArray objectAtIndex:j] objectForKey:@"Longitude"] doubleValue];
                
                double c_1 = distancePoint([[[dataArray objectAtIndex:i-1] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i-1] objectForKey:@"Longitude"] doubleValue], [[[dataArray objectAtIndex:j] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:j] objectForKey:@"Longitude"] doubleValue]);
                if (c_1 > 800) {
                    j++;
                    if (j < dataArray.count - 1) {
                        double c_2 = distancePoint([[[dataArray objectAtIndex:i-1] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i-1] objectForKey:@"Longitude"] doubleValue], [[[dataArray objectAtIndex:j] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:j] objectForKey:@"Longitude"] doubleValue]);
                        if (c_2 > 800) {
                            break;
                        }
                    }
                }
            }
            int n = i - 1;
            double lat = 0;
            double lon = 0;
            for (; n < j; n++) {
                lat += [[[dataArray objectAtIndex:n] objectForKey:@"Latitude"] doubleValue];
                lon += [[[dataArray objectAtIndex:n] objectForKey:@"Longitude"] doubleValue];
            }
            lat /= j - i + 1;
            lon /= j - i + 1;
            
            for (; i <= j; i++)
            {
                NSMutableDictionary *dic_history = [dataArray objectAtIndex:i-1];
                
                locationNew.latitude = lat;
                locationNew.longitude = lon;
                
                [dic_history setObject:[NSNumber numberWithDouble:lat] forKey:@"Latitude"];
                [dic_history setObject:[NSNumber numberWithDouble:lon] forKey:@"Longitude"];
                
                //[defaults setObject:[NSNumber numberWithDouble:locationNew.latitude] forKey:[[dataArray objectAtIndex:i-1] objectForKey:@"Latitude"]];
                //[defaults setObject:[NSNumber numberWithDouble:locationNew.longitude] forKey:[[dataArray objectAtIndex:i-1] objectForKey:@"Longitude"]];
        
                //[[[dataArray objectAtIndex:i-1] objectAtIndex:2] replaceObjectAtIndex:i-1 withObject:[NSNumber numberWithDouble:lat]];
                //[[[dataArray objectAtIndex:i-1] objectAtIndex:4] replaceObjectAtIndex:i-1 withObject:[NSNumber numberWithDouble:lon]];
                
               // [defaults setDouble:lat forKey:@"Latitude"];
                //[defaults setDouble:lon forKey:@"Longitude"];

            }
        }
    }
}

- (void)CoordinateOptimizationLbs
{
    int count=0;
    NSMutableArray  *dataArray_r=[[NSMutableArray alloc]init];
    NSMutableArray  *dataArray_l=[[NSMutableArray alloc]init];
    
    for(int i = 1; i < dataArray.count - 1; i++)
    {
        locationCar.latitude = [[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue];
        locationCar.longitude = [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"] doubleValue];
        locationCar_next.latitude = [[[dataArray objectAtIndex:i-1] objectForKey:@"Latitude"] doubleValue];
        locationCar_next.longitude = [[[dataArray objectAtIndex:i-1] objectForKey:@"Longitude"] doubleValue];
        
        if(locationCar.latitude>90.0)
        {
            locationCar.latitude-=90;
        }
        if(locationCar_next.latitude>90.0)
        {
            locationCar_next.latitude-=90;
        }
        
        if(([[[dataArray objectAtIndex:i] objectForKey:@"LocationType"] intValue] == 1)||([[[dataArray objectAtIndex:i] objectForKey:@"LocationType"] intValue] == 3))
        {
            [dataArray_r addObject:[dataArray objectAtIndex:i]];
            count=0;
        }
        else if(locationCar.latitude==locationCar_next.latitude&&locationCar_next.latitude==locationCar_next.longitude)
        {
            count++;
        }
        else
        {
            if(count>=2){
                [dataArray_l addObject:[dataArray objectAtIndex:i]];
            }
            count=0;
        }
    }
    
    for(int i = 0; i < dataArray.count; i++)
    {
        if([[[dataArray objectAtIndex:i] objectForKey:@"LocationType"] intValue] == 2)
        {
            for(int j = 0; j < dataArray_r.count; j++)
            {
                double d = distancePoint([[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"] doubleValue], [[[dataArray_r objectAtIndex:j] objectForKey:@"Latitude"] doubleValue], [[[dataArray_r objectAtIndex:j] objectForKey:@"Longitude"] doubleValue]);
                
                if (d <= 400)
                {
                    NSMutableDictionary *dic_t = [dataArray objectAtIndex:i];
                    
                    [dic_t setObject:[[dataArray_r objectAtIndex:j]  objectForKey:@"Latitude"]  forKey:@"Latitude"];
                    [dic_t setObject:[[dataArray_r objectAtIndex:j]  objectForKey:@"Longitude"]  forKey:@"Longitude"];
                    break;
                }
            }
        }
    }
    
    for(int i = 0; i < dataArray.count; i++)
    {
        if([[[dataArray objectAtIndex:i] objectForKey:@"LocationType"] intValue] == 2)
        {
            for(int j = 0; j < dataArray_l.count; j++)
            {
                double d = distancePoint([[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"] doubleValue], [[[dataArray_l objectAtIndex:j] objectForKey:@"Latitude"] doubleValue], [[[dataArray_l objectAtIndex:j] objectForKey:@"Longitude"] doubleValue]);
                
                if (d <= 400)
                {
                    NSMutableDictionary *dic_t = [dataArray objectAtIndex:i];
                    
                    [dic_t setObject:[[dataArray_l objectAtIndex:j]  objectForKey:@"Latitude"]  forKey:@"Latitude"];
                    [dic_t setObject:[[dataArray_l objectAtIndex:j]  objectForKey:@"Longitude"]  forKey:@"Longitude"];
                    break;
                }
            }
        }
    }
    
    for(int i = 0; i < dataArray.count-1; i++)
    {
        if([[[dataArray objectAtIndex:i] objectForKey:@"LocationType"] intValue] == 2)
        {
            double e = distancePoint([[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"] doubleValue], [[[dataArray objectAtIndex:i+1] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i+1] objectForKey:@"Longitude"] doubleValue]);
            
            if(e>400)
            {
                if(i>=1)
                {
                    double e0 = distancePoint([[[dataArray objectAtIndex:i-1] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i-1] objectForKey:@"Longitude"] doubleValue], [[[dataArray objectAtIndex:i+1] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i+1] objectForKey:@"Longitude"] doubleValue]);
                    
                    if (e0 <= 400){
                        NSMutableDictionary *dic_t = [dataArray objectAtIndex:i];

                        [dic_t setObject:[[dataArray objectAtIndex:i-1]  objectForKey:@"Latitude"]  forKey:@"Latitude"];
                        [dic_t setObject:[[dataArray objectAtIndex:i-1]  objectForKey:@"Longitude"]  forKey:@"Longitude"];
                    }
                }
                else if((i+2)<dataArray.count)
                {
                    double e1 = distancePoint([[[dataArray objectAtIndex:i] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i] objectForKey:@"Longitude"] doubleValue], [[[dataArray objectAtIndex:i+2] objectForKey:@"Latitude"] doubleValue], [[[dataArray objectAtIndex:i+2] objectForKey:@"Longitude"] doubleValue]);
                    
                    if (e1 <= 400){
                        NSMutableDictionary *dic_t = [dataArray objectAtIndex:i+1];

                        [dic_t setObject:[[dataArray objectAtIndex:i]  objectForKey:@"Latitude"]  forKey:@"Latitude"];
                        [dic_t setObject:[[dataArray objectAtIndex:i]  objectForKey:@"Longitude"]  forKey:@"Longitude"];
                    }
                }
                else
                {
                    NSMutableDictionary *dic_t = [dataArray objectAtIndex:i+1];
                    
                    [dic_t setObject:[[dataArray objectAtIndex:i]  objectForKey:@"Latitude"]  forKey:@"Latitude"];
                    [dic_t setObject:[[dataArray objectAtIndex:i]  objectForKey:@"Longitude"]  forKey:@"Longitude"];

                }
            }
        }
    }
}

- (void)correctTrack
{
    if(dataArray.count<=3){
        return;
    }
    [self filterTrack];
    
    if(isGPS==NO)
    {
        [self CoordinateOptimization];
    }
    else
    {
        [self CoordinateOptimizationLbs];
    }
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
