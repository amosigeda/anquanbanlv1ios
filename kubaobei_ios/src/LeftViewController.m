//
//  LeftViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "LeftViewController.h"
#import "OTPageScrollView.h"
#import "OTPageView.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "UIImageView+WebCache.h"
#import "LocationModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LeftTableViewCell.h"
#import "DeviceSetModel.h"
#import "UserModel.h"
#import "EditHeadAndNameViewController.h"
@interface LeftViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation LeftViewController
{
    NSMutableArray *_dataArray;
    DataManager *manager;
    DeviceSetModel *SetModel;
    DeviceModel *model;
    
    NSUserDefaults *defaults;
    NSArray *nameArray;
    NSArray *iconArray;
    BOOL isPhoto;
    BOOL isHistory;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor colorWithRed:93/255.0 green:0 blue:96/255.0 alpha:1];
    defaults = [NSUserDefaults standardUserDefaults];
    _dataArray =[[NSMutableArray alloc] init];
    
    manager = [DataManager shareInstance];
    _dataArray =  [manager getAllFavourie];
    NSMutableArray *array = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    if(array.count  == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
        model = [_dataArray objectAtIndex:0];
        
        [defaults setObject:model.BindNumber forKey:@"binnumber"];
        
    }
    else
    {
        model = [array objectAtIndex:0];
        
    }
    
    [defaults setObject:model.SmsBalanceKey forKey:@"huafei"];
    [defaults setObject:model.SmsFlowKey forKey:@"liuliang"];
    
    if(model.DeviceModelID.length==0)
    {
        model.DeviceModelID=@"10000000";
    }
    
    if([[model.DeviceModelID substringWithRange:NSMakeRange(5,1)] intValue] ==1)
    {
        isPhoto = YES;
    }
    else{
        isPhoto = NO;
    }
    
    if([[model.DeviceModelID substringWithRange:NSMakeRange(0,1)] intValue] ==1)
    {
        isHistory = YES;
    }
    else{
        isHistory = NO;
    }
    
    if([model.DeviceType isEqualToString:@"2"])
    {
        self.baby_switch.text = NSLocalizedString(@"change_watch_d8", nil);
    }
    else{
        self.baby_switch.text = NSLocalizedString(@"change_watch", nil);
    }
    
    if([model.DeviceType isEqualToString:@"2"])
    {
        if(isPhoto)
        {
            if (isHistory)
            {
                
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee_d8",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                }
            }
            else
            {
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                }
                
            }
        }
        else
        {
            if(isHistory)
            {
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_history",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"setting_icon", nil];
                }
                
            }
            else
            {
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"setting_icon", nil];
                }
                
            }
        }
    }
    else
    {
        if(isPhoto)
        {
            if (isHistory)
            {
                
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                }
            }
            else
            {
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                }
                
            }
        }
        else
        {
            if(isHistory)
            {
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_history",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"setting_icon", nil];
                }
                
            }
            else
            {
                if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"setting_icon", nil];
                }
                else
                {
                    nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                    iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"setting_icon", nil];
                }
                
            }
        }
    }
    
    NSMutableArray *time = [manager isSelectLocationTable:model.DeviceID];
    if(time.count != 0)
    {
        LocationModel *Locmodel = [time objectAtIndex:0];
        [defaults setObject:Locmodel.ServerTime forKey:@"ServerTime"];
        
        [defaults setObject:Locmodel.Latitude  forKey:@"Latitude"];
        [defaults setObject:Locmodel.Longitude forKey:@"Longitude"];
        [defaults setObject:Locmodel.LocationType forKey:@"LocationType"];
        
        [self.headView.layer setCornerRadius:45];
        self.headView.layer.masksToBounds = YES;
        self.headView.layer.borderWidth = 2;
        self.headView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        if([model.Photo isEqualToString:@""])
        {
            self.headView.image = [UIImage imageNamed:@"user_head_normal"];
        }
        else
        {
            [self.headView setImageWithURL:[NSURL URLWithString:model.Photo]];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeHead) name:@"changeHeadImage" object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 40;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray* muArr = [NSMutableArray array];
    NSMutableArray* muarr = [NSMutableArray array];
    for (int i = 0; i < nameArray.count; i++)
    {
        if (nameArray[i] != NSLocalizedString(@"health_management", nil) )
        {
            [muArr addObject:nameArray[i]];
            [muarr addObject:iconArray[i]];
        }
        
    }
//    nameArray = muArr.copy;
//    iconArray = muarr.copy;
    if(isPhoto)
    {
        if(isHistory)
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                return 10;
            }
            else
            {
                return 9;
            }
            
        }
        else
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                return 9;
            }
            else
            {
                return 8;
            }
            
        }
    }
    else
    {
        if(isHistory)
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                return 9;
                
            }
            else
            {
                return 8;
            }
            
        }
        else
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                return 8;
                
            }
            else
            {
                return 7;
            }
            
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"watchSetOne";
    
    UINib *nib = [UINib nibWithNibName:@"LeftTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[LeftTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    
    if(isPhoto)
    {
        if(isHistory)
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 8)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            else
            {
                if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 7)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            
        }
        else
        {
            
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 7)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            else
            {
                if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 6)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            
        }
        
    }
    else
    {
        if(isHistory)
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                if(indexPath.row == 0 || indexPath.row == 4 || indexPath.row == 8)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            else
            {
                if(indexPath.row == 0 || indexPath.row == 4 || indexPath.row == 7)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            
        }
        else
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
            {
                if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 6)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            else
            {
                if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 5)
                {
                    cell.line.image = [UIImage imageNamed:@"white_line"];
                }
                else
                    cell.line.image = nil;
            }
            
        }
        
    }
//    if(indexPath.row == 8)
//    {
//        cell.hidden = YES;
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.iconImage.image = [UIImage imageNamed:[iconArray objectAtIndex:indexPath.row]];
    cell.nameLabel.text = [nameArray objectAtIndex:indexPath.row];
    if (nameArray[indexPath.row] == NSLocalizedString(@"health_management", nil)) {
        [cell setHidden:YES];
    }
   
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///
    if(indexPath.row == 2)
    {
        return 0.1;
    }
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isPhoto)//有相册，历史轨迹
    {
        if (isHistory) {
            
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )//中文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchPhone" object:self];
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                    
                }
                else if(indexPath.row == 7)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHistory" object:self];
                    
                }
                else if(indexPath.row == 8)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPhotoView" object:self];
                    
                }
                else if(indexPath.row == 9)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                    
                }
            }
            else //有相册，有历史轨迹，不是中文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                    
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHistory" object:self];
                    
                }
                else if(indexPath.row == 7)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPhotoView" object:self];
                    
                }
                else if(indexPath.row == 8)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                    
                }
            }
        }
        else // 有相册，没有历史轨迹
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )//中文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchPhone" object:self];
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                    
                }
                else if(indexPath.row == 7)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPhotoView" object:self];
                    
                }
                else if(indexPath.row == 8)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                    
                }
            }
            else // 英文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPhotoView" object:self];
                }
                else if(indexPath.row == 7)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                    
                }
            }
        }
    }
    else//没有相册
    {
        if (isHistory)// 有历史轨迹
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )//中文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchPhone" object:self];
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                    
                }
                else if(indexPath.row == 7)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHistory" object:self];
                    
                }
                else if(indexPath.row == 8)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                    
                }
                
            }
            else //没有相册，有历史轨迹，不是中文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                    
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHistory" object:self];
                    
                }
                else if(indexPath.row == 7)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                    
                }
                
            }
        }
        else // 没有历史轨迹，没有相册
        {
            if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )//中文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchPhone" object:self];
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                    
                }
                else if(indexPath.row == 7)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                    
                }
                
            }
            else // 英文
            {
                if(indexPath.row == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBabyList" object:self];
                    
                }
                else if(indexPath.row == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWatchSet" object:self];
                }
                else if(indexPath.row == 2)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showHealthManagement" object:self];
                }
                else if(indexPath.row == 3)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutWatch" object:self];
                }
                else if(indexPath.row == 4)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBook" object:self];
                    
                }
                else if(indexPath.row == 5)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showWeiLan" object:self];
                }
                else if(indexPath.row == 6)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSet" object:self];
                }
            }
        }
    }
}

- (void)ChangeHead
{
    _dataArray =  [manager getAllFavourie];
    NSMutableArray *array = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if([model.Photo isEqualToString:@""])
        {
            self.headView.image = [UIImage imageNamed:@"user_head_normal"];
        }
        else
        {
            [self.headView setImageWithURL:[NSURL URLWithString:model.Photo]];
        }
        
        if(model.DeviceModelID.length==0)
        {
            model.DeviceModelID=@"10000000";
        }
        
        if([[model.DeviceModelID substringWithRange:NSMakeRange(5,1)] intValue] ==1)
        {
            isPhoto = YES;
        }
        else{
            isPhoto = NO;
        }
        
        if([[model.DeviceModelID substringWithRange:NSMakeRange(0,1)] intValue] ==1)
        {
            isHistory = YES;
        }
        else{
            isHistory = NO;
        }
        
        if([model.DeviceType isEqualToString:@"2"])
        {
            self.baby_switch.text = NSLocalizedString(@"change_watch_d8", nil);
        }
        else{
            self.baby_switch.text = NSLocalizedString(@"change_watch", nil);
        }
        
        if([model.DeviceType isEqualToString:@"2"])
        {
            if(isPhoto)
            {
                if (isHistory)
                {
                    
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSMutableArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];

////                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"watch_setting",@"health_management",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
//                        //MARK: - 去除手表相册
//                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"setting_icon", nil];
                    }
                }
                else
                {
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album_d8", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                    }
                    
                }
            }
            else
            {
                if(isHistory)
                {
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_history",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"setting_icon", nil];
                    }
                    
                }
                else
                {
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare_d8", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting_d8", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch_d8", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"setting_icon", nil];
                    }
                    
                }
            }
        }
        else
        {
            if(isPhoto)
            {
                if (isHistory)
                {
                    
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"icon_picture",@"setting_icon", nil];
                    }
                }
                else
                {
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"watch_album", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_picture",@"setting_icon", nil];
                    }
                    
                }
            }
            else
            {
                if(isHistory)
                {
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"icon_history",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"history_track", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"icon_history",@"setting_icon", nil];
                    }
                    
                }
                else
                {
                    if([[defaults objectForKey:@"currentLanguage_phone"] intValue] == 2 || [[defaults objectForKey:@"currentLanguage_phone"] intValue] == 3 )
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"watch_fare", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fee",@"icon_fence",@"setting_icon", nil];
                    }
                    else
                    {
                        nameArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"babyinfo", nil),NSLocalizedString(@"watch_setting", nil),NSLocalizedString(@"health_management", nil),NSLocalizedString(@"about_watch", nil),NSLocalizedString(@"mail_list", nil),NSLocalizedString(@"fence", nil),NSLocalizedString(@"APP_setting", nil), nil];
                        iconArray = [[NSArray alloc] initWithObjects:@"icon_boy",@"icon_watch_setting",@"icon_health",@"icon_watch",@"icon_book",@"icon_fence",@"setting_icon", nil];
                    }
                    
                }
            }
        }
        
        [self.tableView reloadData];
        
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    _dataArray =[[NSMutableArray alloc] init];
    
    manager = [DataManager shareInstance];
    _dataArray =  [manager getAllFavourie];
    NSMutableArray *array = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    [defaults setObject:model.DeviceID forKey:@"loginDeviceID"];
    [self.headView.layer setCornerRadius:50];
    self.headView.layer.masksToBounds = YES;
    self.headView.layer.borderWidth = 2;
    self.headView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.headView setImageWithURL:[NSURL URLWithString:model.Photo]];
}

- (IBAction)addWatch:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddView" object:self];
}

- (IBAction)selectBaby:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectBaby" object:self];
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        
        if (!error && object) {
            // 获得状态
            [OMGToast showWithText:NSLocalizedString(NSLocalizedString([object objectForKey:@"Message"], nil), nil)  bottomOffset:50 duration:2];
        }
    }
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
