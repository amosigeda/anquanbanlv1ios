//
//  BabyListViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "UIColor+MCNAddition.h"
#import "NSString+Tools.h"
#import "BabyListViewController.h"
#import "BabyHeartTableViewCell.h"
#import "BabyLineTableViewCell.h"
#import "ZHPickView.h"
#import "STAlertView.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "LXActionSheet.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SchoolListViewController.h"
#import "XiaoquSetViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "OMGToast.h"
#import "ContactModel.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "IQActionSheetPickerView.h"

#define kMaxLength 8
#define ORIGINAL_MAX_WIDTH 100.0f

@interface BabyListViewController ()<UITableViewDelegate,UITableViewDataSource,ZHPickViewDelegate,UIAlertViewDelegate,LXActionSheetDelegate,VPImageCropperDelegate,WebServiceProtocol,UIGestureRecognizerDelegate,UITextFieldDelegate,IQActionSheetPickerViewDelegate>
{
    NSUserDefaults *defaults;
    
    NSArray *seciton1Array;
    NSArray *seciton2Array;
    DataManager *manager;
    NSArray *seciton3Array;
    NSArray *sexArray;
    NSArray *classArray;
    NSMutableArray *array;
    DeviceModel *model;
    ContactModel *conModel;
    NSMutableAttributedString *content;
    NSIndexPath *_indexPath;
    UIButton *indexBtn;
    UIAlertView *alertViews;
@private NSString *imgHex;
    
}
@end

@implementation BabyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"1" forKey:@"showLeft"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.backgroundColor = MCN_buttonColor;
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView.hidden = YES;
    self.tableView.tableFooterView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    tapAction.delegate =self;
    [self.view addGestureRecognizer:tapAction];
    
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    
    manager = [DataManager shareInstance];
    array =   [manager isSelect:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    
    if(model.CurrentFirmware.length==0)
    {
        model.CurrentFirmware=@"00000000";
    }
    
    if([defaults integerForKey:@"deviceModelType"] == 1||[model.DeviceType isEqualToString:@"2"])
    {
        seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"watch_no_d8", nil),NSLocalizedString(@"cornet_family", nil), nil];
    }
    else
    {
        seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"watch_no", nil),NSLocalizedString(@"cornet_family", nil), nil];
    }
    seciton2Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"gender", nil),NSLocalizedString(@"birthday", nil),NSLocalizedString(@"grade", nil),nil];
    
    seciton3Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"schoolinfo", nil),NSLocalizedString(@"homeinfo", nil), nil];
    sexArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"girl", nil),NSLocalizedString(@"boy", nil), nil];
    classArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"grade_a", nil),NSLocalizedString(@"grade_b", nil),NSLocalizedString(@"grade_c", nil),NSLocalizedString(@"grade_d", nil),NSLocalizedString(@"grade_e", nil),NSLocalizedString(@"grade_f", nil),NSLocalizedString(@"grade_g", nil),NSLocalizedString(@"grade_h", nil),NSLocalizedString(@"grade_i", nil),NSLocalizedString(@"grade_j", nil),NSLocalizedString(@"grade_k", nil),NSLocalizedString(@"grade_l", nil), nil];
    [self getBabyList];
    // self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}
-(void)tapAction{
    [self.view endEditing:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 2;
    }
    else if(section == 2)
    {
        return 3;
    }
    else
    {
        return 2;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([defaults integerForKey:@"deviceModelType"] == 1||[model.DeviceType isEqualToString:@"2"])
    {
        return 2;
    }
    else
    {
        return 4;
    }
}
//每个分组上边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1;
    }
    else if(section ==  1)
    {
        return 0.1;
    }
    else if(section == 2 || section == 3)
    {
        return 5;
    }
    else
        return 0;
}
//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 90;
    }
    return 40;
}


-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    BabyLineTableViewCell * cell=[self.tableView cellForRowAtIndexPath:_indexPath];
    
    
    switch (pickerView.tag)
    {
        case 1:
        {
            cell.listLabel.text = [titles componentsJoinedByString:@" - "];
            
            if([[titles componentsJoinedByString:@" - "] isEqualToString:NSLocalizedString(@"boy", nil)])
            {
                [defaults setObject:@"1" forKey:@"sex"];
                [defaults setObject:@"1" forKey:@"sexx"];
            }
            else
            {
                [defaults setObject:@"2" forKey:@"sex"];
                [defaults setObject:@"0" forKey:@"sexx"];
                
            }
            
            
            break;
        }
        case 2:
        {
            cell.listLabel.text = [titles componentsJoinedByString:@" - "];
            
            for(int i = 0; i < classArray.count;i++)
            {
                if([[classArray objectAtIndex:i] isEqualToString:[titles componentsJoinedByString:@" - "]])
                {
                    [defaults setInteger:i forKey:@"grade"];
                    [defaults setInteger:i+1 forKey:@"grades"];
                }
            }
            break;
        }
            
        default:
            break;
    }
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    BabyLineTableViewCell * cell=[self.tableView cellForRowAtIndexPath:_indexPath];
    switch (pickerView.tag)
    {
        case 6:
        {
            NSDateFormatter *formater =[[NSDateFormatter alloc] init];
            
            [formater setDateStyle:NSDateFormatterMediumStyle];
            [formater setTimeStyle:NSDateFormatterNoStyle];
            [formater setDateFormat:@"yyyy/MM/dd"];
            
            cell.listLabel.text  = [formater stringFromDate:date];
            
            [defaults setObject:[formater stringFromDate:date] forKey:@"birthday"];
            break;
            
        }
        default:
            break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if(indexPath.section == 2)
    {
        //        [_pickview remove];
        
        if(indexPath.row == 0)
        {
            //  _pickview=[[ZHPickView alloc] initPickviewWithArray:sexArray isHaveNavControler:NO];//
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:NSLocalizedString(@"gender", nil) delegate:self];
            
            picker.toolbarTintColor = [UIColor mcn_colorWithHex:0xf9f9f9];
            picker.backgroundColor = [UIColor mcn_colorWithHex:0xf9f9f9];
            [picker setUserInteractionEnabled:YES];
            picker.titleFont = [UIFont systemFontOfSize:16];
            //            picker.tintColor
            [picker setTag:1];
            [picker setTitlesForComponents:@[@[NSLocalizedString(@"boy", nil), NSLocalizedString(@"girl", nil)]]];
            [picker show];
            CGRect rect3 = picker.pickerView.frame;
            NSArray* arr = picker.actionToolbar.items;
            UIBarButtonItem* leftButton = arr[0];
            UIBarButtonItem* rightButton = arr[2];
            //            CGRect rect3 = leftButton.
            //            CGRect rect1 = _pickview.frame;
            CGRect rect2 = picker.frame;
            
            rect2.size.width = [UIScreen mainScreen].bounds.size.width;
            //            rect2.origin.x = picker.frame.origin.x+10;
            picker.frame = rect2;
            NSLog(@"tiaoshi");
        }
        else if(indexPath.row == 1)
        {
            NSDateFormatter *formater =[[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy/MM/dd"];
            NSDate *date= [formater dateFromString:model.Birthday];
            if(date == nil){
                date = [NSDate new];
            }
            //_pickview=[[ZHPickView alloc] initDatePickWithDate:date datePickerMode:UIDatePickerModeDate isHaveNavControler:NO];
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:NSLocalizedString(@"birthday", nil) delegate:self];
            [picker setUserInteractionEnabled:YES];
            picker.toolbarTintColor = [UIColor mcn_colorWithHex:0xf9f9f9];
            picker.backgroundColor = [UIColor mcn_colorWithHex:0xf9f9f9];
            [picker setTag:6];
            [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
            [picker show];
        }
        else
        {
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:NSLocalizedString(@"grade", nil) delegate:self];
            [picker setUserInteractionEnabled:YES];
            picker.titleFont = [UIFont systemFontOfSize:16];
            picker.toolbarTintColor = [UIColor mcn_colorWithHex:0xf9f9f9];
            picker.backgroundColor = [UIColor mcn_colorWithHex:0xf9f9f9];
            [picker setTag:2];
            [picker setTitlesForComponents:@[@[NSLocalizedString(@"grade_a", nil),NSLocalizedString(@"grade_b", nil),NSLocalizedString(@"grade_c", nil),NSLocalizedString(@"grade_d", nil),NSLocalizedString(@"grade_e", nil),NSLocalizedString(@"grade_f", nil),NSLocalizedString(@"grade_g", nil),NSLocalizedString(@"grade_h", nil),NSLocalizedString(@"grade_i", nil),NSLocalizedString(@"grade_j", nil),NSLocalizedString(@"grade_k", nil),NSLocalizedString(@"grade_l", nil)]]];
            [picker show];
        }
        
        //        _pickview.delegate = self;
        //        [_pickview show];
    }
    else if(indexPath.section == 1)
    {
        BabyLineTableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
        
        if(indexPath.row == 0)
        {
            if([model.DeviceType isEqualToString:@"2"])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"watch_no_d8", nil) message:NSLocalizedString(@"input_watch_no_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = model.PhoneNumber;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 0;
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"watch_no", nil) message:NSLocalizedString(@"input_watch_no", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = model.PhoneNumber;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 0;
                [alertView show];
            }
        }
        else
        {
            if([model.DeviceType isEqualToString:@"2"])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cornet_family", nil) message:NSLocalizedString(@"input_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = model.PhoneCornet;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 1;
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cornet_family", nil) message:NSLocalizedString(@"input_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = model.PhoneCornet;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 1;
                [alertView show];
            }
        }
    }
    else if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            SchoolListViewController *vc = [[SchoolListViewController alloc] init];
            vc.title = NSLocalizedString(@"schoolinfo", nil);
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else if(indexPath.row == 1)
        {
            XiaoquSetViewController *vc = [[XiaoquSetViewController alloc] init];
            vc.title = NSLocalizedString(@"homeinfo", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 0)
    {
        alertViews = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"baby_nick", nil) message:NSLocalizedString(@"input_baby_nick", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        alertViews.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertViews textFieldAtIndex:0].text = model.BabyName;
        [alertViews textFieldAtIndex:0].delegate = self;
        [alertViews show];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:[alertViews textFieldAtIndex:0]];
    }
    
    
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(_indexPath.section == 0)
    {
        BabyHeartTableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
        
        if(buttonIndex == 1)
        {
            content = [[NSMutableAttributedString alloc] initWithString:[alertView textFieldAtIndex:0].text];
            NSRange contentRange = {0, [content length]};
            [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
            cell.nameLabel.attributedText = content;
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"babyName"];
        }
        
    }
    else if(_indexPath.section == 1)
    {
        BabyLineTableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:_indexPath];
        
        if(buttonIndex == 1)
        {
            if(_indexPath.row == 0)
            {
                
                if([[alertView textFieldAtIndex:0].text length] > 0)
                {
                    //                    if (![self isPureInt:[alertView textFieldAtIndex:0].text])
                    //                    {
                    //                        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:4];
                    //                        return;
                    //                    }
                    //
                    //                    if ([[alertView textFieldAtIndex:0].text length] != 11)
                    //                    {
                    //                        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:4];
                    //                        return;
                    //                    }
                    if (![[alertView textFieldAtIndex:0].text isValidateMobile:[alertView textFieldAtIndex:0].text])
                    {
                        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:4];
                        return;
                    }
                }
                
                [defaults setValue:[alertView textFieldAtIndex:0].text  forKey:@"phone"];
            }
            else
            {
//                if (![[alertView textFieldAtIndex:0].text isValidateMobile:[alertView textFieldAtIndex:0].text])
//                {
//                    [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:4];
//                    return;
//                }
                if([alertView textFieldAtIndex:0].text.length == 0)
                {
                    [defaults setObject:@"" forKey:@"phoneShort"];
                }
                else
                {
                    if (![self isPureInt:[alertView textFieldAtIndex:0].text])
                    {
                        [OMGToast showWithText:NSLocalizedString(@"input_right_cornet", nil) bottomOffset:50   duration:4];
                        return;
                    }
                    
                    [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"phoneShort"];
                    
                }
            }
            
            cell1.listLabel.text = [alertView textFieldAtIndex:0].text;
        }
    }
}

-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    BabyLineTableViewCell * cell=[self.tableView cellForRowAtIndexPath:_indexPath];
    if(_indexPath.row == 1)
    {
        resultString = [resultString substringToIndex:10];
        [defaults setObject:resultString forKey:@"birthday"];
        cell.listLabel.text =  resultString;
        
    }
    else if(_indexPath.row == 0)
    {
        if([resultString isEqualToString:NSLocalizedString(@"boy", nil)])
        {
            [defaults setObject:@"1" forKey:@"sex"];
            [defaults setObject:@"1" forKey:@"sexx"];
        }
        else
        {
            [defaults setObject:@"2" forKey:@"sex"];
            [defaults setObject:@"0" forKey:@"sexx"];
            
        }
        cell.listLabel.text =  resultString;
        
    }
    else if(_indexPath.row == 2)
    {
        for(int i = 0; i < classArray.count;i++)
        {
            if([[classArray objectAtIndex:i] isEqualToString:resultString])
            {
                [defaults setInteger:i forKey:@"grade"];
                [defaults setInteger:i+1 forKey:@"grades"];
            }
        }
        cell.listLabel.text =  resultString;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0)
    {    _indexPath = indexPath;
        
        static  NSString *cell1 = @"cellbabyHeart";
        
        UINib *nib = [UINib nibWithNibName:@"BabyHeartTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cell1];
        
        BabyHeartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        if (cell == nil) {
            cell = [[BabyHeartTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cell1];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.headView.layer setCornerRadius:CGRectGetHeight([cell.headView bounds]) / 2];
        cell.headView.layer.masksToBounds = YES;
        cell.headView.layer.borderWidth = 1;
        cell.headView.layer.borderColor = [navigationBarColor CGColor];
        
        if([model.Photo isEqualToString:@""])
        {
            cell.headView.image = [UIImage imageNamed:@"user_head_normal"];
        }
        else
        {
            [cell.headView setImageWithURL:[NSURL URLWithString:model.Photo]];
        }
        
        if([model.BabyName isEqualToString:@""])
        {
            content = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"baby", nil)];
        }
        else
        {
            content = [[NSMutableAttributedString alloc] initWithString:model.BabyName];
            
        }
        cell.changeHeadLabel.text = NSLocalizedString(@"edit_head", nil);
        [defaults setObject:content.string forKey:@"babyName"];
        if(conModel.Relationship==nil){
            cell.betweenLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"relationship_of_baby", nil)];
        }else{
            cell.betweenLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"relationship_of_baby", nil),conModel.Relationship];
        }
        
        NSRange contentRange = {0, [content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        cell.nameLabel.attributedText = content;
        [cell.headButton addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
        indexBtn = cell.headButton;
        return cell;
    }
    else
    {
        static  NSString *cell2 = @"babyLine";
        
        UINib *nib = [UINib nibWithNibName:@"BabyLineTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cell2];
        
        BabyLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2];
        if (cell == nil) {
            cell = [[BabyLineTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cell2];
        }
        
        if(indexPath.section == 1)
        {
            cell.title.text = [seciton1Array objectAtIndex:indexPath.row];
            
            
            if(indexPath.row == 0)
            {
                cell.listLabel.text = model.PhoneNumber;
                [defaults setObject:cell.listLabel.text forKey:@"phone"];
            }
            else
            {
                cell.listLabel.text = model.PhoneCornet;
                [defaults setObject:cell.listLabel.text forKey:@"phoneShort"];
            }
        }
        else if(indexPath.section == 2)
        {
            cell.title.text = [seciton2Array objectAtIndex:indexPath.row];
            
            if(indexPath.row == 0)
            {
                if(model.Gender.intValue == 1){
                    cell.listLabel.text = [sexArray objectAtIndex:1];
                }else{
                    cell.listLabel.text = [sexArray objectAtIndex:0];
                }
                if([cell.listLabel.text isEqualToString:NSLocalizedString(@"boy", nil)])
                {
                    [defaults setObject:@"1" forKey:@"sex"];
                    [defaults setObject:@"1" forKey:@"sexx"];
                    
                }
                else
                {
                    [defaults setObject:@"2" forKey:@"sex"];
                    [defaults setObject:@"0" forKey:@"sexx"];
                }
            }
            else if(indexPath.row == 1)
            {
                cell.listLabel.text = model.Birthday;
                [defaults setObject:cell.listLabel.text forKey:@"birthday"];
            }
            else
            {
                cell.listLabel.text = [classArray objectAtIndex:model.Grade.intValue];
                for(int i = 0; i < classArray.count;i++)
                {
                    if([[classArray objectAtIndex:i] isEqualToString:cell.listLabel.text])
                    {
                        [defaults setInteger:i forKey:@"grade"];
                        [defaults setInteger:i+1 forKey:@"grades"];
                        
                    }
                }
            }
        }
        else if(indexPath.section == 3)
        {
            cell.title.text = [seciton3Array objectAtIndex:indexPath.row];
            
            
            if(indexPath.row == 0)
            {
                if (model.SchoolLat.doubleValue > 0 && model.SchoolLng.doubleValue > 0)
                {
                    cell.listLabel.text = model.SchoolAddress;
                }else
                {
                    cell.listLabel.text = @"";
                }
                
            }
            else
            {
                if (model.HomeLat.doubleValue > 0 && model.HomeLng.doubleValue > 0)
                {
                    cell.listLabel.text = model.HomeAddress;
                }else
                {
                    cell.listLabel.text = @"";
                }
                
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)btn
{
    [defaults setObject:@"1" forKey:@"pop"];
    
    LXActionSheet *actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"select_photo", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"camera", nil),NSLocalizedString(@"album", nil)]];
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
}

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (IBAction)saveBuuton:(id)sender {
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelect:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    
    
    if([[defaults objectForKey:@"babyName"] isEqualToString:model.BabyName] && [[defaults objectForKey:@"phone"] isEqualToString:model.PhoneNumber] && imgHex == nil && [[defaults objectForKey:@"phoneShort"] isEqualToString:model.PhoneCornet] && [[defaults objectForKey:@"sexx"] isEqualToString:model.Gender] && [[defaults objectForKey:@"birthday"] isEqualToString:model.Birthday] && [[NSString stringWithFormat:@"%ld",[defaults integerForKey:@"grade"]] isEqualToString:model.Grade]){
        [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        self.saveBtn.enabled = NO;
        WebService *webService = [WebService newWithWebServiceAction:@"UpdateDevice" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchinfo/update"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"nickname" andValue:[defaults objectForKey:@"babyName"]];
        WebServiceParameter *parameter5;
        if([[defaults objectForKey:@"phone"] length]  == 0){
            parameter5 = [WebServiceParameter newWithKey:@"phone" andValue:@""];
        }else{
            parameter5 = [WebServiceParameter newWithKey:@"phone" andValue:[defaults objectForKey:@"phone"]];
        }
        WebServiceParameter *parameter6;
        if([[defaults objectForKey:@"phoneShort"] length]  == 0){
            parameter6 = [WebServiceParameter newWithKey:@"shortNumber" andValue:@""];
        }else{
            parameter6 = [WebServiceParameter newWithKey:@"shortNumber" andValue:[defaults objectForKey:@"phoneShort"]];
        }
        WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"familyNumber" andValue:@""];
        WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"sex" andValue:[defaults objectForKey:@"sex"]];
        WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"birday" andValue:[defaults objectForKey:@"birthday"]];
        WebServiceParameter *parameter10 = [WebServiceParameter newWithKey:@"schoolAge" andValue:[NSString stringWithFormat:@"%ld",[defaults integerForKey:@"grades"]]];
        NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"UpdateDeviceResult"];
    }
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
                    self.saveBtn.enabled = YES;
                    [self getBabyList];
                    [manager updataSQL:@"favourite_info" andType:@"BabyName" andValue:[defaults objectForKey:@"babyName"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"PhoneNumber" andValue:[defaults objectForKey:@"phone"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"PhoneCornet" andValue:[defaults objectForKey:@"phoneShort"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Gender" andValue:[defaults objectForKey:@"sexx"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Birthday" andValue:[defaults objectForKey:@"birthday"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Grade" andValue:[NSString stringWithFormat:@"%ld",[defaults integerForKey:@"grade"]] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Photo" andValue:[object objectForKey:@"Photo"] andDevice:model.DeviceID];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
                    
                    [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else if(ws.tag == 1){
                    [manager updataSQL:@"favourite_info" andType:@"BabyName" andValue:[object objectForKey:@"BabyName"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"PhoneNumber" andValue:[object objectForKey:@"PhoneNumber"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"PhoneCornet" andValue:[object objectForKey:@"PhoneCornet"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Gender" andValue:[object objectForKey:@"Gender"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Birthday" andValue:[object objectForKey:@"Birthday"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Grade" andValue:[object objectForKey:@"Grade"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Photo" andValue:[object objectForKey:@"Photo"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Photo" andValue:[object objectForKey:@"Photo"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"DeviceModelID" andValue:[object objectForKey:@"DeviceModelID"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"UserId" andValue:[object objectForKey:@"UserId"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"HomeAddress" andValue:[object objectForKey:@"HomeAddress"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"HomeLat" andValue:[object objectForKey:@"HomeLat"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"HomeLng" andValue:[object objectForKey:@"HomeLng"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SchoolAddress" andValue:[object objectForKey:@"SchoolAddress"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SchoolLat" andValue:[object objectForKey:@"SchoolLat"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SchoolLng" andValue:[object objectForKey:@"SchoolLng"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"LatestTime" andValue:[object objectForKey:@"LatestTime"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SetVersionNO" andValue:[object objectForKey:@"SetVersionNO"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"ContactVersionNO" andValue:[object objectForKey:@"ContactVersionNO"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"OperatorType" andValue:[object objectForKey:@"OperatorType"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SmsNumber" andValue:[object objectForKey:@"SmsNumber"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SmsBalanceKey" andValue:[object objectForKey:@"SmsBalanceKey"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SmsFlowKey" andValue:[object objectForKey:@"SmsFlowKey"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"ActiveDate" andValue:[object objectForKey:@"ActiveDate"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"CreateTime" andValue:[object objectForKey:@"CreateTime"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"BindNumber" andValue:[object objectForKey:@"BindNumber"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"CurrentFirmware" andValue:[object objectForKey:@"CurrentFirmware"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Firmware" andValue:[object objectForKey:@"Firmware"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"HireExpireDate" andValue:[object objectForKey:@"HireExpireDate"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"UpdateTime" andValue:[object objectForKey:@"UpdateTime"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"Password" andValue:[object objectForKey:@"Password"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"SerialNumber" andValue:[object objectForKey:@"SerialNumber"] andDevice:model.DeviceID];
                    [manager updataSQL:@"favourite_info" andType:@"IsGuard" andValue:[object objectForKey:@"IsGuard"] andDevice:model.DeviceID];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
                    array = [manager isSelect:[defaults objectForKey:@"binnumber"]];
                    model = [array objectAtIndex:0];
                    [self.tableView reloadData];
                }else if(ws.tag == 2){
                    [self getBabyList];
                }
            }else if(ws.tag == 0){
                self.saveBtn.enabled = YES;
                [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:1];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    self.saveBtn.enabled = YES;
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)getBabyList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceDetail" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchinfo/get/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceDetailResult"];
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    manager = [DataManager shareInstance];
    
    array =   [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    NSArray *arr = [manager isSelectContactTable:[defaults objectForKey:@"binnumber"]];
    for(int i = 0;i < arr.count;i++)
    {
        ContactModel *mo = [arr objectAtIndex:i];
        if(mo.ObjectId.intValue == [[defaults objectForKey:@"UserId"] intValue])
        {
            conModel = [arr objectAtIndex:i];
            
        }
    }
    
    if([[defaults objectForKey:@"pop"] intValue] ==  0)
    {
        [self.tableView reloadData];
    }
    
}

- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{
    if(buttonIndex == 0)
    {
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    }
    else if(buttonIndex==1)
    {
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) showAlert:(NSString *)message
{
    UIAlertView* alertDialog = [[UIAlertView alloc]initWithTitle:message
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"confirm", nil),nil];
    [alertDialog show];
}


#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    BabyHeartTableViewCell *cell111 ;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        cell111 = ((BabyHeartTableViewCell*)[[indexBtn   superview]superview]);
        
    }
    else
    {
        cell111 = [self.tableView cellForRowAtIndexPath:_indexPath];
    }
    NSLog(@"%@",cell111);
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{}];
    editedImage = [self imageByScalingToMaxSize:editedImage];
    cell111.headView.image = editedImage;
    NSData *imageData = UIImagePNGRepresentation(editedImage);
//    Byte *imageByte = (Byte *)[imageData bytes];
//    NSMutableString *hexStr = [[NSMutableString alloc] initWithString:@""];
//
//    for(int i=0;i<[imageData length];i++)
//
//    {
//        if(imageByte[i]<16)
//            [hexStr appendFormat:@"0%x",imageByte[i]&0xff];
//        else
//            [hexStr appendFormat:@"%x",imageByte[i]&0xff];
//
//    }
    imgHex = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [defaults setInteger:3 forKey:@"av"];
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateHeadImg" andDelegate:self];
    webService.tag = 2;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchinfo/updateHead"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"id" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"head" andValue:imgHex];
    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5];
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"UpdateHeadImgResult"];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 60.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@" NSStringFromClass([touch.view class]==========%@", NSStringFromClass([touch.view class]));
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
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
