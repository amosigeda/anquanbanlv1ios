//
//  PhotoViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "PhotoViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "OMGToast.h"
#import "PhotoCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "DeviceModel.h"
#import "PhotoModel.h"
#import "PhotoLocationViewController.h"
#import "Constants.h"
#import "PictureSacnViewController.h"

@interface PhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    DataManager *manager;
    NSMutableArray *photoArray;
    DeviceModel *deviceModel;
    PhotoModel *photoModel;
    BOOL isFirst;
    int deleteIndex;
}
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize DeviceHeight = [UIScreen mainScreen].bounds.size;
    
    self.photo_ImageView.frame = CGRectMake(5, 66, DeviceHeight.width - 10, (DeviceHeight.width - 20 * 3) / 4);
    
    defaults  = [NSUserDefaults standardUserDefaults];
    manager = [DataManager shareInstance];
    photoArray = [[NSMutableArray alloc] init];
    
    deviceModel =  [[manager isSelect:[defaults objectForKey:@"binnumber"]] objectAtIndex:0];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    //    UIButton * rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    //
    //    [rightBtn setTitle:NSLocalizedString(@"camera", nil) forState:UIControlStateNormal];
    //    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    //    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    //    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    //
    //    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    //    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    photoArray = [manager isSelectPhotoTable:deviceModel.DeviceID];
    NSLog(@"%@",photoArray);
    self.collectionView.allowsMultipleSelection = NO;//默认为NO,是否可以多选
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [manager deletePhotoWithPhotoID:@"010101"];
    
    if(photoArray.count > 0)
    {
        photoModel = [photoArray objectAtIndex:photoArray.count - 1 ];
        [self.photo_ImageView setImageWithURL:[NSURL URLWithString:photoModel.Path]];
        self.photo_person_Label.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"source", nil),photoModel.Source];
        self.photo_address_Label.text = [NSString stringWithFormat:@"%@",photoModel.Address];
        self.photo_time_Label.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"time", nil),photoModel.CreateTime];
        
    }
    else
    {
        self.list_View.hidden = YES;
        [OMGToast showWithText:NSLocalizedString(@"no_photo", nil) bottomOffset:50 duration:2];
    }
    
    double delayInSeconds =  0.1 ;
    
    dispatch_time_t popTime = dispatch_time ( DISPATCH_TIME_NOW , delayInSeconds * NSEC_PER_SEC );
    
    dispatch_after (popTime, dispatch_get_main_queue (), ^( void ){
        [self.collectionView reloadData];
        
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPhoto) name:@"refreshPhoto" object:nil];
    
    //创建长按手势监听
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressed:)];
    [self.collectionView addGestureRecognizer:longPress];
}

- (IBAction)cameraButton:(id)sender{
    if([deviceModel.DeviceType isEqualToString:@"2"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"album_take_photo", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        [alertView show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"album_take_photo", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        [alertView show];
    }
}

- (void)onLongPressed:(UILongPressGestureRecognizer *)sender {
    
    /*
     if(photoArray.count>1)
     {
     PhotoCollectionViewCell *cell=(PhotoCollectionViewCell *)sender;
     NSIndexPath *indexpath=[self.collectionView indexPathForCell:cell];
     
     NSMutableArray *temp=[NSMutableArray arrayWithArray:photoArray];
     [temp removeObjectAtIndex:indexpath.row];
     photoArray=temp;
     
     [photoArray removeObjectAtIndex:indexpath.item];
     [self.collectionView deleteItemsAtIndexPaths:@[indexpath]];
     
     }
     else{
     [photoArray removeAllObjects];
     [self.collectionView reloadData];
     }
     */
    
    CGPoint point = [sender locationInView:sender.view];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                deleteIndex = indexPath.row;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"Delete_watch_camera", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alertView.tag = 3;
                [alertView show];
                
                //[self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self.collectionView updateInteractiveMovementTargetPosition:point];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self.collectionView endInteractiveMovement];
            break;
        }
        default: {
            [self.collectionView cancelInteractiveMovement];
            break;
        }
    }
    
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditing)
    {
        return YES;
    }
    
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == 0 && destinationIndexPath.section == 0) {
        [photoArray exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
    }
}

- (void)refreshPhoto
{
    [manager deletePhotoWithPhotoID:@"010101"];
    
    [photoArray removeAllObjects];
    photoArray = [manager isSelectPhotoTable:deviceModel.DeviceID];
    
    [self.collectionView reloadData];
    
    [self loadData];
}

- (void)showNext
{
    if([deviceModel.DeviceType isEqualToString:@"2"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"PS_watch_camera_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        [alertView show];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"PS_watch_camera", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        [alertView show];
    }
}

- (void)deleteItem
{
    PhotoCollectionViewCell *cell;
    NSIndexPath *indexpath=[self.collectionView indexPathForCell:cell];
    PhotoModel *pm = [photoArray objectAtIndex:(photoArray.count-deleteIndex-1)];
    [manager deletePhotoWithPhotoID:pm.DevicePhotoId];
    //photoArray中存储的图片的index是展示图片index的逆序。
    [photoArray removeObjectAtIndex:photoArray.count-deleteIndex-1];
    [self.collectionView reloadData];
    //    [self loadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        if(alertView.tag == 3){
            [self deleteItem];
            //
            //            WebService *webService = [WebService newWithWebServiceAction:@"DeleteDevicePhoto" andDelegate:self];
            //            webService.tag = 1;
            //            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            //            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
            //
            //            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"DevicePhotoId" andValue:photoModel.DevicePhotoId];
            //            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
            //            // webservice请求并获得结果
            //            webService.webServiceParameter = parameter;
            //            [webService getWebServiceResult:@"DeleteDevicePhotoResult"];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
                webService.tag = 1;
                WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"controllerDevice/capt"];
                WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
                WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
                WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"come" andValue:@""];
                NSArray *parameter = @[parameter1,parameter2,parameter3,parameter4];
                // webservice请求并获得结果
                webService.webServiceParameter = parameter;
                [webService getWebServiceResult:@"SendDeviceCommandResult"];
            });
        }
    }
}

- (void)loadData
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDevicePhoto" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"tk/getDevicePhoto/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDevicePhotoResult"];
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
                    NSArray * listArray = [object objectForKey:@"List"];
                    for(int i = 0; i < listArray.count;i++)
                    {
                        NSDictionary *dic = [listArray objectAtIndex:i];
                        
                        [manager addPhotoPhotoId:[dic objectForKey:@"DevicePhotoId"] andDeviceID:[dic objectForKey:@"DeviceID"] andSource:[dic objectForKey:@"Source"] andDeviceTime:[dic objectForKey:@"DeviceTime"] andLatitude:[dic objectForKey:@"Latitude"] andLongitude:[dic objectForKey:@"Longitude"] andMark:[dic objectForKey:@"Mark"] andPath:[dic objectForKey:@"Path"] andLength:[dic objectForKey:@"Length"] andCreateTime:[dic objectForKey:@"CreateTime"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andAddress:@""];
                        
                        //                        WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
                        //                        webService.tag =[[dic objectForKey:@"DevicePhotoId"] intValue];
                        //                        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                        //                        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
                        //                        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[dic objectForKey:@"Latitude"]];
                        //                        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[dic objectForKey:@"Longitude"]];
                        //                        NSLog(@"%d", webService.tag);
                        //
                        //                        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
                        //                        // webservice请求并获得结果
                        //                        webService.webServiceParameter = parameter;
                        //                        [webService getWebServiceResult:@"GetAddressResult"];
                    }
                    [photoArray removeAllObjects];
                    photoArray = [manager isSelectPhotoTable:deviceModel.DeviceID];
                    [self.collectionView reloadData];
                }else if(ws.tag == 1){
                    [OMGToast showWithText:NSLocalizedString(@"send_success", nil) bottomOffset:50 duration:3];
                    //                     [manager addPhotoPhotoId:@"010101" andDeviceID:deviceModel.DeviceID andSource:@"" andDeviceTime:@"" andLatitude:@"" andLongitude:@"" andMark:@"" andPath:@"load_photo_icon" andLength:@"" andCreateTime:@"" andUpdateTime:@"" andAddress:@""];
                    //                    int index = [[manager isSelectPhotoTable:deviceModel.DeviceID] count];
                    //                    [photoArray addObject:[[manager isSelectPhotoTable:deviceModel.DeviceID] objectAtIndex:index - 1]];
                    //                    [self.collectionView reloadData];
                }else{
                    for(int i = 0; i < photoArray.count;i++)
                    {
                        PhotoModel *models = [photoArray objectAtIndex:i];
                        if(ws.tag == models.DevicePhotoId.intValue)
                        {
                            NSArray * address = [object objectForKey:@"Nearby"];
                            isFirst = NO;
                            [manager updataSQL:@"photo_table" andType:@"Address" andValue:[NSString stringWithFormat:@"%@%@%@%@,%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"]] andDevicePhotoId:models.DevicePhotoId];
                            
                            [photoArray removeAllObjects];
                            photoArray = [manager isSelectPhotoTable:deviceModel.DeviceID];
                            [self.collectionView reloadData];
                            
                            photoModel = [photoArray objectAtIndex:photoArray.count - 1 ];
                            [self.photo_ImageView setImageWithURL:[NSURL URLWithString:photoModel.Path]];
                            self.photo_person_Label.text = [NSString stringWithFormat:@"来源: %@",photoModel.Source];
                            self.photo_address_Label.text = [NSString stringWithFormat:@"%@",photoModel.Address];
                            self.photo_time_Label.text = [NSString stringWithFormat:@"时间: %@",photoModel.CreateTime];
                        }
                    }
                }
            }else if(ws.tag == 1){
                if(code == 2){
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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    photoModel = [photoArray objectAtIndex:photoArray.count - 1 -  indexPath.row];
    static NSString *collectionCellID = @"myCollectionCell";
    
    UINib *cellNib = [UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:collectionCellID];
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCellID forIndexPath:indexPath];
    
    if([photoModel.Path isEqualToString:@"load_photo_icon"])
    {
        cell.image_ImageView.image = [UIImage imageNamed:@"load_photo_icon"];
    }
    else
    {
        [cell.image_ImageView setImageWithURL:[NSURL URLWithString:photoModel.Path]];
    }
    cell.tag = indexPath.row;
    photoModel = [photoArray objectAtIndex:photoArray.count - 1];
    
    if(!isFirst)
    {
        if(indexPath.row == 0)
        {
            cell.bg_Image.image = [UIImage imageNamed:@"selectphoto_icon"];
        }
        else{
            cell.bg_Image.image = [UIImage imageNamed:@""];
        }
    }
    return cell;
}

#pragma mark -CollectionView datasource

//指定组的个数 ，一个大组！！不是一排，是N多排组成的一个大组(与下面区分)
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//指定单元格的个数 ，这个是一个组里面有多少单元格，e.g : 一个单元格就是一张图片
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photoArray.count;
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 60)/3, ([UIScreen mainScreen].bounds.size.width - 60)/3);
}

//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 16, 0, 16);//分别为上、左、下、右
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 16;
}

//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 4;
}

/*
 // 长按某item，弹出删除和保存菜单
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
 {
 return YES;
 }
 
 // 使删除和保存有效
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
 {
 if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"])
 {
 return YES;
 }
 
 return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
 {
 if([NSStringFromSelector(action) isEqualToString:@"copy:"])
 {
 
 }
 else if([NSStringFromSelector(action) isEqualToString:@"paste:"])
 {
 
 }
 }
 */

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    photoModel = [photoArray objectAtIndex:photoArray.count - 1 - indexPath.row];
    PictureSacnViewController *picVC = [PictureSacnViewController new];
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:photoModel.Path forKey:@"content"];
    [array addObject:dic];
    picVC.picArray = array;
    picVC.currenpage = 1;//当前图片
    [self.navigationController presentViewController:picVC animated:YES completion:nil];
    [self.photo_ImageView setImageWithURL:[NSURL URLWithString:photoModel.Path]];
    self.photo_person_Label.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"source", nil),photoModel.Source];
    self.photo_address_Label.text = [NSString stringWithFormat:@"%@",photoModel.Address];
    self.photo_time_Label.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"time", nil),photoModel.CreateTime];
    
    //    PhotoCollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    //    [cell setBackgroundColor:[UIColor greenColor]];
    
    
    for(PhotoCollectionViewCell *cell in collectionView.visibleCells)
    {
        if(indexPath.row == cell.tag)
        {
            //cell.backgroundColor = [UIColor greenColor];//
            cell.bg_Image.image = [UIImage imageNamed:@"selectphoto_icon"];
            
        }
        else
        {
            cell.backgroundColor = [UIColor clearColor];
            cell.bg_Image.image = [UIImage imageNamed:@""];
            
            //[cell.deleteBtn addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    /*
     if (self.isEditing) {
     [photoArray removeObject:photoModel];
     
     NSInteger index = photoArray.count - 1;
     if (photoArray.count == 0) {
     index = 0;
     }
     
     PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
     cell.isEditing = NO;
     [collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
     // [self saveColumns];
     
     } else {
     // 选择某一个
     }
     
     [self.collectionView reloadData];
     */
}

- (IBAction)showLocation:(id)sender {
    
    PhotoLocationViewController *location = [[PhotoLocationViewController alloc] init];
    location.title  = NSLocalizedString(@"location", nil);
    location.address = photoModel.Address;
    location.lat = photoModel.Latitude;
    location.lng = photoModel.Longitude;
    location.time = photoModel.CreateTime;
    location.image = photoModel.Path;
    location.source = photoModel.Source;
    [self.navigationController pushViewController:location animated:YES];
}
- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [self loadData];
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
