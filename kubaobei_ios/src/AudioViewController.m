//
//  AudioViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "AudioViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "SendAudioTableViewCell.h"
#import "ReplyAudioTableViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "NSString+DocumentPath.h"
#import "UIImage+StrethImage.h"
#import "VoiceConverter.h"
#import "OMGToast.h"
#import "Voice.h"
#import "DataManager.h"
#import "AudioModel.h"
#import "DeviceModel.h"
#import "ContactModel.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "WatchPhoneTableViewCell.h"
#import "UserModel.h"
#define TEXTVIEW_HEIGHT _textView.frame.size.height
@interface AudioViewController ()<AVAudioRecorderDelegate,AVAudioSessionDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate,UITextFieldDelegate,WebServiceProtocol>
@property (nonatomic,strong) AVAudioRecorder *recorder;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) AudioViewController *currentChartView;
@property (nonatomic,assign) BOOL recording;
@property (nonatomic,assign) BOOL isScrollBottom;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardViewBottomConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLayou;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardViewHeight;

@end
static int mytime = 15;
//#define weight  self.view.frame.size.width
//#define height self.view.frame.size.height

@implementation AudioViewController
{
    BOOL isNumOne;
    //坐标
    CGRect   _frame;
    //用label显示内容
    UILabel  *_label;
    //是否显示清空按钮
    BOOL     _clear;
    //设置leftView
    UIView   *_leftView;
    //设置字号
    CGFloat  _fontSize;
    NSUserDefaults *defaults;
    NSMutableArray *listVoice;
    NSString *label;
    int type;
    NSString *music;
    NSString *message;
    NSString *urlStr;
    int pageindex;
    int pageSize;
    int pageTotal;
    int lastVoiceId;
    int msg_len;
    BOOL isLoad;
    NSTimer *timer;
    NSTimer *audioTimer;
    int ic;
    NSTimer *lenTimer;
    int time;
    BOOL isShow;
    UIImageView *view;
    //  NSIndexPath *path;
    UIButton *button;
    BOOL isUpload;
    DataManager *manager;
    DeviceModel *deviceModel;
    AudioModel *audioModel;
//    AudioModel *userModel;
//    UserModel* userModel;
    NSMutableArray *deviceArray;
    NSTimer *loadTimer;
    UIButton * lastButton;
    NSTimer *refreshTimer;
    BOOL isShowTextfield;
    BOOL isdownscroll;
    
    NSString *reply_msg;
    NSString *msg_content;
    CGFloat height;
    BOOL isShowText;
    NSMutableArray* cellHeightArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self setTextField];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 设置文本框占位文字
    _textView.placeholder = @"请输入文字.....";
    _textView.placeholderColor = [UIColor grayColor];
    _textView.returnKeyType =  UIReturnKeySend;
    height = _textView.frame.size.height;
    _textView.delegate = self;
    // 监听文本框文字高度改变
    _textView.yz_textHeightChangeBlock = ^(NSString *text,CGFloat textHeight){
        // 文本框文字高度改变会自动执行这个【block】，可以在这【修改底部View的高度】
        // 设置底部条的高度 = 文字高度 + textView距离上下间距约束
        // 为什么添加10 ？（10 = 底部View距离上（5）底部View距离下（5）间距总和）
        _keyboardViewHeight.constant = textHeight + 10;
        height = textHeight + 10;
    };
    
    // 设置文本框最大行数
    _textView.maxNumberOfLines = 4;
    _isScrollBottom = NO;
    isNumOne = NO;
    self.tableView.estimatedRowHeight = 150;//估算高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    listVoice = [[NSMutableArray alloc] init];
    deviceArray = [[NSMutableArray alloc] init];
    time = 0;
    isShow = NO;
    pageindex = 1;
    mytime = 15;
    
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
    
//    self.tableView.frame=CGRectMake(0, 30, 320, 460);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    //    self.tableView.rowHeight = 90;
    [self.imageView setHidden:YES];
    [self.bgImageView setHidden:YES];
    [self.audioLabel setHidden:YES];
//    [self.textField setHidden:YES];
    [self.textView setHidden:YES];
    _keyboardViewHeight.constant = 50;
    defaults = [NSUserDefaults standardUserDefaults];
    
    manager = [DataManager shareInstance];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    NSMutableArray *audio = [manager isSelectAudioTable:deviceModel.DeviceID];
    for(int i = 0; i < audio.count;i++)
    {
        [listVoice addObject:[audio objectAtIndex:i]];
    }
    
    [defaults setInteger:0 forKey:@"voiceload"];
    [self getLoad];
    
//    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getLoad) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoadNew) name:@"refreshIIIIII" object:nil];
    
    //textField监听
    //[self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    //隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardWillShowNotification object:nil];
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.speakLabel.text = NSLocalizedString(@"hold_and_spreak", nil);
    [self.speakButton setTitle:NSLocalizedString(@"touch_speak", nil) forState:UIControlStateNormal];
//    self.textField.placeholder=@"请输入文字...";
    
    if(([deviceModel.CurrentFirmware rangeOfString:@"D9_LED_CHUANGMT"].location != NSNotFound))
    {
        isShowText = NO;
        
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateNormal];
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        isShowText = YES;
        
        isShowTextfield=YES;
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor.png"] forState:UIControlStateNormal];
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_press.png"] forState:UIControlStateHighlighted];
    }
    
}
- (void)getLoadNew
{
    [self getLoad];
}


- (IBAction)voiceBtn:(id)sender
{
    NSString *normal,*hightLight;
    if(isShowText==NO)
    {
        [self.speakButton setHidden:NO];
//        [self.textField setHidden:YES];
        [self.textView setHidden:YES];
        _keyboardViewHeight.constant = 50;
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateNormal];
        [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_press.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        if(isShowTextfield==YES){
            isShowTextfield=NO;
            [self.speakButton setHidden:YES];
//            [self.textField setHidden:NO];
            [self.textView setHidden:NO];
            [self.textView becomeFirstResponder];
            _keyboardViewHeight.constant = height;
            [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateNormal];
            [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_press.png"] forState:UIControlStateHighlighted];
            
        }else{
            isShowTextfield=YES;
            [self.speakButton setHidden:NO];
//            [self.textField setHidden:YES];
            [self.textView setHidden:YES];
             _keyboardViewHeight.constant = 50;
            [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor.png"] forState:UIControlStateNormal];
            [self.voiceBtn setBackgroundImage:[UIImage imageNamed:@"chat_bottom_keyboard_press.png"] forState:UIControlStateHighlighted];
        }
    }
}

- (IBAction)speakStar:(id)sender {
    self.speakLabel.hidden = YES;
    isUpload = YES;
    ic = 0;
    mytime = 15;
    if ([self.audioRecorder prepareToRecord]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
    }
    NSLog(@"开始录音");
    time = 0;
    audioTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(time) userInfo:nil repeats:YES];
    
    lenTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}
- (void)time
{
    time++;
    mytime--;
    if(mytime == 0)
    {
        [lenTimer invalidate];
        [self.imageView setHidden:YES];
        [self.bgImageView setHidden:YES];
        [self.audioLabel setHidden:YES];
        mytime = 15;
        [audioTimer invalidate];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"recording_time_up_to_15_seconds", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil),NSLocalizedString(@"cancel", nil), nil];
        alertView.delegate = self;
        [alertView show];
        //结束录音
        self.recording=NO;
        [self.recorder stop];
        self.recorder=nil;
        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:urlStr] options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
        if(audioDurationSeconds<1)
        {
            [OMGToast showWithText:NSLocalizedString(@"record_too_short", nil) bottomOffset:50 duration:3];
            return;
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *P = [paths objectAtIndex:0];
        
        NSString *W = [NSString stringWithFormat:@"%@/myRecord.amr",P];
        [VoiceConverter wavToAmr:urlStr amrSavePath:W];
        
        NSURL *URL = [NSURL fileURLWithPath:W];
        NSData *data = [NSData dataWithContentsOfURL:URL];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
        
//        Byte *imageByte = (Byte *)[data bytes];
//        NSMutableString *hexStr = [[NSMutableString alloc] initWithString:@""];
//
//        for(int i=0;i<[data length];i++)
//        {
//            if(imageByte[i]<16)
//                [hexStr appendFormat:@"0%x",imageByte[i]&0xff];
//            else
//                [hexStr appendFormat:@"%x",imageByte[i]&0xff];
//
//        }
       music=[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSLog(@"结束录音");
    }
    
    NSLog(@"%d",mytime);
    
}

- (void)detectionVoice
{
    [self.recorder updateMeters];//刷新音量数据
    [self.imageView setHidden:NO];
    [self.bgImageView setHidden:NO];
    [self.audioLabel setHidden:NO];
    
    self.audioLabel.text = [NSString stringWithFormat:@"%@ %@%d%@",NSLocalizedString(@"slide_cancel", nil),NSLocalizedString(@"and_then_there_were", nil), mytime,NSLocalizedString(@"second", nil)];
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    //最大50  0
    //图片 小-》大
    if (0<lowPassResults<=0.06) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}

- (IBAction)stopSendAudio:(id)sender {
    
    [self.imageView setHidden:YES];
    [self.bgImageView setHidden:YES];
    [self.audioLabel setHidden:YES];
    
    audioTimer=nil;
    lenTimer = nil;
    //结束录音
    self.recording=NO;
    [self.recorder stop];
    self.recorder=nil;
    self.speakLabel.hidden = NO;
}

- (IBAction)stopAudio:(id)sender {
    
    self.audioLabel.text =NSLocalizedString(@"release_canceled", nil);
    self.imageView.image = [UIImage imageNamed:@"record_cancel"];
    [audioTimer invalidate];
    [lenTimer invalidate];
    
    isUpload = NO;
    audioTimer=nil;
    lenTimer = nil;
    //结束录音
    self.recording=NO;
    [self.recorder stop];
    self.recorder=nil;
}

- (IBAction)speakBegin:(id)sender {
    
    [audioTimer invalidate];
    [lenTimer invalidate];
    [self.imageView setHidden:YES];
    [self.bgImageView setHidden:YES];
    [self.audioLabel setHidden:YES];
    self.speakLabel.hidden = NO;
    
    audioTimer=nil;
    lenTimer = nil;
    //结束录音
    self.recording=NO;
    [self.recorder stop];
    self.recorder=nil;
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:urlStr] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    if(audioDurationSeconds<1)
    {
        [OMGToast showWithText:NSLocalizedString(@"record_too_short", nil) bottomOffset:50 duration:3];
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *P = [paths objectAtIndex:0];
    
    NSString *W = [NSString stringWithFormat:@"%@/myRecord.amr",P];
    [VoiceConverter wavToAmr:urlStr amrSavePath:W];
    
    NSURL *URL = [NSURL fileURLWithPath:W];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    
//    Byte *imageByte = (Byte *)[data bytes];
//    NSMutableString *hexStr = [[NSMutableString alloc] initWithString:@""];
//
//    for(int i=0;i<[data length];i++)
//    {
//        if(imageByte[i]<16)
//            [hexStr appendFormat:@"0%x",imageByte[i]&0xff];
//        else
//            [hexStr appendFormat:@"%x",imageByte[i]&0xff];
//
//    }
   music=[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSLog(@"结束录音");
    [self upLoadAudio];
    // [NSThread exit];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range

 replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        _isScrollBottom = NO;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *P = [paths objectAtIndex:0];
        
        NSString *W = [NSString stringWithFormat:@"%@/myMessage.txt",P];
        [VoiceConverter wavToAmr:urlStr amrSavePath:W];
        
        NSURL *URL = [NSURL fileURLWithPath:W];
        NSData *data = [NSData dataWithContentsOfURL:URL];
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
        
//        NSMutableString *hexStr = [[NSMutableString alloc] initWithString:self.textField.text];
         NSMutableString *hexStr = [[NSMutableString alloc] initWithString:self.textView.text];
        message=hexStr;
        
        char* p = (char*)[message cStringUsingEncoding:NSUnicodeStringEncoding];
        for (int i=0 ; i<[message lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
        {
            if (*p) {
                p++;
                msg_len++;
            }
            else {
                p++;
            }
        }
        NSLog(@"结束信息");
        [self upLoadMessage];
        _textView.text = nil;
        height = 50;
        _keyboardViewHeight.constant = 50;
        [self.textView  resignFirstResponder];

        return NO;
    }
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //    if (self.textField.text.length > 30)
    //    {
    ////        UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"voice_alert_leght", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil),nil, nil];
    ////        [alerview show];
    //    }
    //    else
    //    {
    _isScrollBottom = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *P = [paths objectAtIndex:0];
    
    NSString *W = [NSString stringWithFormat:@"%@/myMessage.txt",P];
    [VoiceConverter wavToAmr:urlStr amrSavePath:W];
    
    NSURL *URL = [NSURL fileURLWithPath:W];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    
//    NSMutableString *hexStr = [[NSMutableString alloc] initWithString:self.textField.text];
     NSMutableString *hexStr = [[NSMutableString alloc] initWithString:self.textView.text];
    
    message=hexStr;
    
    char* p = (char*)[message cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[message lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
    {
        if (*p) {
            p++;
            msg_len++;
        }
        else {
            p++;
        }
    }
    NSLog(@"结束信息");
    [self upLoadMessage];
//    [self.textField setText:@""];
//    [self.textField  resignFirstResponder];
    //    }
    
    return YES;
}
//开始编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"将要编辑");
    return YES;
}
//开始编辑
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"开始编辑");
}
//将要编辑完成
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"将要编辑完成");
    return YES;
}
//编辑完成
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"编辑完成");
}
//点击键盘调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"点击键盘调用");
    return YES;
}

//-(void)setTextField
//{
//    _frame = _textField.frame;
//    _clear = YES;
//    _leftView = (UIView *)view;
//    _fontSize = 20;
//    //    self.placeholder = placeholder;
//    _textField.textColor = [UIColor clearColor];
//    _textField.font = [UIFont systemFontOfSize:_fontSize];
//    //    self.delegate = self;
//    if (_clear) {
//        _textField.clearButtonMode = UITextFieldViewModeAlways;
//    }
//    if (_leftView) {
//        _textField.leftView = view;
//        _textField.leftViewMode = UITextFieldViewModeAlways;
//    }
//    [self createLabel];
//    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//}
///**
// *  监听textField内容的改变
// *
// *  @param sender
// */
//- (void) textFieldDidChange:(id) sender {
//    UITextField *textField = (UITextField *)sender;
//
//    CGSize size = [self labelText:[NSString stringWithFormat:@"%@|",textField.text] fondSize:_fontSize width:_label.frame.size.width];
//    _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, _label.frame.size.width, size.height < _frame.size.height ? _frame.size.height : size.height);
//    _textField.frame = CGRectMake(_frame.origin.x, _frame.origin.y, _frame.size.width, size.height < _frame.size.height ? _frame.size.height : size.height);
//
//    if (textField.text.length == 0) {
//        _label.text = @"";
//        _textField.tintColor=[UIColor blueColor];
//    }else{
//        //添加一个假的光标
//        _textField.tintColor=[UIColor clearColor];
//        NSString *text = [NSString stringWithFormat:@"%@|",textField.text];
//        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:text];
//        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(text.length - 1, 1)];
//        _label.attributedText = attString;
//    }
//}
///**
// *  计算字符串长度，UILabel自适应高度
// *
// *  @param text  需要计算的字符串
// *  @param size  字号大小
// *  @param width 最大宽度
// *
// *  @return 返回大小
// */
//-(CGSize)labelText:(NSString *)text fondSize:(float)size width:(CGFloat)width
//{
//    NSDictionary *send = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
//    CGSize textSize = [text boundingRectWithSize:CGSizeMake(width, 0)
//                                         options:NSStringDrawingTruncatesLastVisibleLine |
//                       NSStringDrawingUsesLineFragmentOrigin |
//                       NSStringDrawingUsesFontLeading
//                                      attributes:send context:nil].size;
//
//    return textSize;
//}
//-(void)createLabel
//{
//    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _frame.size.width, _frame.size.height)];
//    if (_leftView) {
//        _label.frame = CGRectMake(_leftView.frame.size.width, _label.frame.origin.y, _label.frame.size.width-_leftView.frame.size.width, _label.frame.size.height);
//    }
//    if (_clear) {
//        _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, _label.frame.size.width-20, _label.frame.size.height);
//    }
//    _label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//    _label.font = [UIFont systemFontOfSize:_fontSize];
//    _label.numberOfLines = 0;
//    [_textField addSubview:_label];
//}
////点击清空按钮
//- (BOOL)textFieldShouldClear:(UITextField *)textField
//{
//    NSLog(@"清空");
//    _label.text = @"";
//    return YES;
//}
/*
 -(void)textFieldDidChange :(UITextField *)theTextField{
 NSLog( @"text changed: %@", self.textField.text);
 }
 */
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
//    [self.textField  resignFirstResponder];
    [self.textView resignFirstResponder];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    
    
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:aNotification.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
   
//    [UIView animateWithDuration:(animationTime-0.05) animations:^{
//        _keyboardViewBottomConstant.constant = keyBoardHeight;
//    }];
//
    // 定义好动作
    void (^animation)(void) = ^void(void) {
        self.keyboardView.transform = CGAffineTransformMakeTranslation(0, - keyBoardHeight);
//        _tableViewLayou.constant = keyBoardHeight;
        self.tableView.transform = CGAffineTransformMakeTranslation(0, - keyBoardHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }

    
//    float height = -285.0;
//
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
//            CGSize result = [[UIScreen mainScreen] bounds].size;
//            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
//
//            if (result.height <= 480.0f)
//                height = -250.0;
//            else if(result.height > 480.0f&&result.height <= 960.0f)
//                height = -260.0;
//            else if(result.height > 960.0f&&result.height <= 1136.0f)
//                height = -270.0;
//            else if(result.height > 1136.0f&&result.height <= 1334.0f)
//                height = -280.0;
//            else if(result.height > 1334.0f&&result.height <= 2208.0f)
//                height = -290.0;
//            else
//                height = -285.0;
//        } else
//            height = -285.0;
//    }
//
//    self.view.frame = CGRectMake(self.view.frame.origin.x, height,self.view.frame.size.width,self.view.frame.size.height);
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:aNotification.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
//    [UIView animateWithDuration:(animationTime+1) animations:^{
//        _keyboardViewBottomConstant.constant = 0;
//    }];
//     定义好动作
    void (^animation)(void) = ^void(void) {
        self.keyboardView.transform = CGAffineTransformIdentity;
//        _tableViewLayou.constant = 0;
         self.tableView.transform = CGAffineTransformIdentity;
    };

    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }

}

- (void)upLoadAudio{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceVoice" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"tk/tkToDevice"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"phone" andValue:@""];
        WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"voiceData" andValue:music];
        WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"sourceName" andValue:[NSString stringWithFormat:@"%@_%ld",[defaults objectForKey:@"binnumber"],(long)[[NSDate  date] timeIntervalSince1970]]];
        WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"voiceLength" andValue:[NSString stringWithFormat:@"%d",time]];
        NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"SendDeviceVoiceResult"];
        
    });
}

- (void)upLoadMessage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceVoice" andDelegate:self];
        webService.tag = 0;
        
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"controllerDevice/pushMessage"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"message" andValue:message];
        NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        
        [webService getWebServiceResult:@"SendDeviceVoiceResult"];
        
    });
}

float lastContentOffset;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastContentOffset = scrollView.contentOffset.y;
//    [_textField resignFirstResponder];
    [_textView resignFirstResponder];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (lastContentOffset < scrollView.contentOffset.y)
    {
        isdownscroll=YES;
        //NSLog(@"向上滚动");
    }else{
        isdownscroll=NO;
        //NSLog(@"向下滚动");
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
            if(code == 1){
                if(ws.tag == 0)//发送语音
                {
                    [defaults setInteger:1 forKey:@"voiceload"];
                    
                    //  [self getLoad];
                }
                //获取语音信息
                if(1){
                    NSArray *array = [object objectForKey:@"VoiceList"];
                    
                    for(int i = 0; i < array.count;i++)
                    {
                        [manager addAudioWithDeviceVoiceId:[[array objectAtIndex:i] objectForKey:@"DeviceVoiceId"] andDeviceID:[[array objectAtIndex:i] objectForKey:@"DeviceID"] andState:[[array objectAtIndex:i] objectForKey:@"State"] andType:[[array objectAtIndex:i] objectForKey:@"Type"] andObjectId:[[array objectAtIndex:i] objectForKey:@"ObjectId"]  andMark:[[array objectAtIndex:i] objectForKey:@"Mark"] andPath:[[array objectAtIndex:i] objectForKey:@"Path"]  andLength:[[array objectAtIndex:i] objectForKey:@"Length"]  andMsgType:[[array objectAtIndex:i] objectForKey:@"MsgType"] andCreateTime:[[array objectAtIndex:i] objectForKey:@"CreateTime"] andUpdateTime:[[array objectAtIndex:i] objectForKey:@"UpdateTime"]];
                        
                    }
                    
//                    if(listVoice.count != 0)
//                    {
//                        [listVoice removeAllObjects];
//                        
//                    }
                    NSMutableArray *audio = [manager isSelectAudioTable:deviceModel.DeviceID];
                    //                    for(int i = 0; i < audio.count;i++)
                    //                    {
                    ////                        AudioModel *model1 = listVoice[i];
                    ////                        AudioModel *model1 = listVoice[i];
                    //                        [listVoice addObject:[audio objectAtIndex:i]];
                    //
                    //                        AudioModel *modle = [listVoice objectAtIndex:i];
                    //                        NSLog(@"%@--",modle.ObjectId);
                    //
                    //                    }
                    if (listVoice.count!=audio.count)
                    {
                        
                        listVoice = audio.copy;
                        __weak typeof(self)weakSelf = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [weakSelf.tableView reloadData];
                            weakSelf.isScrollBottom=NO;
                            isNumOne = YES;
//                            if (weakSelf.tableView.contentSize.height >weakSelf.view.bounds.size.height){
//                                [weakSelf.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.bounds.size.height) animated:NO];
//                            }
                        });
                    }
                    
                    
                    if(pageindex==1)
                    {
                        NSUInteger sectionCount = [self.tableView numberOfSections];
                        if (sectionCount) {
                            
                            NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
                            if (rowCount) {
                                
                                NSUInteger ii[2] = {0, rowCount - 1};
                                NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                                if(isdownscroll==YES)
                                {
                                    [self.tableView scrollToRowAtIndexPath:indexPath
                                                          atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                                }
                            }
                        }
                    }else {
                        NSUInteger ii[2] = {0, pageSize-1};
                        NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:0 length:2];
                        [self.tableView scrollToRowAtIndexPath:indexPath
                                              atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    }
                    isLoad=YES;
                }
                //                }
//                NSLog(@"Length_Value:%@",audioModel.Length);
//                NSLog(@"MsgType_Value:%@",audioModel.MsgType);
//                NSLog(@"Path_Value:%@",audioModel.Path);
            }else if(ws.tag == 0){
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

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(loadTimer)
    {
        [loadTimer invalidate];
        loadTimer=nil;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
    if(listVoice.count>0)
    {
        CGFloat offset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        if (offset > 0)
        {
            [self.tableView setContentOffset:CGPointMake(0, offset) animated:animated];
        }
//        NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
//        NSUInteger ii[2] = {0, rowCount - 1};
//        NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
//        if(indexPath){
//        [self.tableView scrollToRowAtIndexPath:indexPath
//                              atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        }
    }
    //[self.tableView reloadData];
}

- (void)getLoad{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceVoice" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"tk/getDeviceVoice/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceVoiceResult"];
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    cellHeightArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<listVoice.count;i++)
    {
        [cellHeightArr addObject:@"74"];
    }
    return listVoice.count;
    
}

-(void)setBackGroundImageViewImage:(AudioViewController *)AudioView from:(NSString *)from to:(NSString *)to
{
    UIImage *normal=nil ;
    
    normal = [UIImage imageNamed:from];
    normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:normal.size.height * 0.7];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    audioModel = [listVoice objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    if(audioModel.Type.intValue == 3 && [audioModel.ObjectId isEqualToString:[defaults stringForKey:@"UserId"]])//发送方
    {
        if(audioModel.MsgType.intValue == 1)
        {
            static NSString *cellID = @"send";
            UINib *nib = [UINib nibWithNibName:@"SendAudioTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellID];
            SendAudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[SendAudioTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            }
            
            cell.signalImage.hidden = YES;
            cell.lengthLabel.hidden = YES;
            //cell.listButton.selected = YES;
            
            ContactModel *contantModel = [[ContactModel alloc] init];
            NSArray *array = [manager isSelectContactTable:deviceModel.BindNumber];
            for(int i = 0; i < array.count;i++)
            {
                ContactModel *model = [array objectAtIndex:i];
                if([model.ObjectId isEqualToString:@"1"])
                {
                    contantModel = model;
                }
            }
            
            NSLog(@"%@",contantModel.Relationship);
            cell.nameLabel.text = contantModel.Relationship;
            if(!contantModel.DeviceContactId.length){
                cell.headImage.image = [UIImage imageNamed:@"head_1"];
            }else if(!contantModel.HeadImg.length)
            {
                cell.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_%d",contantModel.Photo.intValue]];
                
            }
            else
            {
                [cell.headImage setImageWithURL:[NSURL URLWithString:contantModel.HeadImg]];
                
            }
            
            //cell.timeLabel.text =audioModel.CreateTime;
            if(audioModel.CreateTime.length > 16){
                cell.timeLabel.text = [audioModel.CreateTime substringWithRange:NSMakeRange(0,16)];
            }else{
                cell.timeLabel.text = @"";
            }
            
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *P = [paths objectAtIndex:0];
//
//            NSArray *url = [audioModel.Path componentsSeparatedByString:@"/"];
//            NSArray * urlArray = [[url objectAtIndex:1] componentsSeparatedByString:@"."];
//            NSString *extension = [NSString stringWithFormat:@"%@/%@-%@.txt",P,[url objectAtIndex:0],[urlArray objectAtIndex:0]];
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//
//            NSString *txt = [NSString stringWithFormat:@"%@/%@-%@",P,[url objectAtIndex:0],[url objectAtIndex:1]];
//            NSURL *url_send = [NSURL URLWithString:[NSString stringWithFormat:HTTPS,AUDIO,audioModel.Path]];
//            NSData * myData = [NSData dataWithContentsOfURL:url_send];
//            [myData writeToFile:txt atomically:YES];
            
            //cell.listButton .titleLabel.font = [UIFont systemFontOfSize:14];
            //cell.listButton .titleLabel.numberOfLines=0;
            //cell.listButton.titleLabel.lineBreakMode = 0;
            //[cell.listButton  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //[cell.listButton setTitle:[NSString stringWithContentsOfURL:url_send encoding:NSUTF8StringEncoding error:nil] forState:UIControlStateNormal];
            
            /*
             NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
             attrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
             CGSize size =  [cell.msgLabel.text boundingRectWithSize:CGSizeMake(cell.msgLabel.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
             cell.msgLabel.frame =CGRectMake(100, 100, 100, size.height);
             cell.msgLabel.font = [UIFont systemFontOfSize:14];
             
             CGRect size1 = cell.frame;
             size1.size.height = [cell heightForString1:cell.msgLabel.text fontSize:14 andWidth1:[UIScreen mainScreen].bounds.size.width];
             cell.frame = size1;
             
             cell.msgLabel.text = [NSString stringWithFormat:@"%@",[NSString stringWithContentsOfURL:url_send encoding:NSUTF8StringEncoding error:nil]];
             */
            
            cell.msgLabel.numberOfLines = 0;
            cell.msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
            CGSize size = [cell.msgLabel sizeThatFits:CGSizeMake(cell.msgLabel.frame.size.width, MAXFLOAT)];
            cell.msgLabel.frame =CGRectMake(0, 35, 200, size.height+30);
//            cell.msgLabel.font = [UIFont systemFontOfSize:15];
            
            //UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_button"]];//使用半透明图片作为label的背景色
            //cell.msgLabel.backgroundColor = color;
            //cell.msgLabel.textAlignment = UITextAlignmentCenter;
            //cell.msgLabel.backgroundColor = [UIColor orangeColor];
            //cell.msgLabel.layer.cornerRadius  = 10;
            //cell.msgLabel.layer.borderWidth = 1;
            
            cell.msgLabel.text = audioModel.Path;
            CGFloat cellHeight = cell.bounds.size.height;
            CGFloat sumHeight;
            if (cell.msgLabel.bounds.size.height > cellHeight)
            {
                sumHeight = cell.msgLabel.bounds.size.height + cellHeight;
                cellHeightArr[indexPath.row] =  [NSString stringWithFormat:@"%f",sumHeight];
            }else
            {
                cellHeightArr[indexPath.row] =  [NSString stringWithFormat:@"%f",cell.bounds.size.height];
            }
            
            cell.listButton.frame = CGRectMake(cell.listButton.frame.origin.x, cell.listButton.frame.origin.y, cell.msgLabel.bounds.size.width,cell.listButton.frame.size.height );
            //            cell.listButton.bounds = cell.msgLabel.bounds;
//            NSLog(@"-----URL------%@",url_send.description);
            NSLog(@"%@",cell.msgLabel.text);
            UIImage* image = [UIImage imageNamed:@"send_1"];
            image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
            [cell.listButton setBackgroundImage:image forState:UIControlStateNormal];
            //            if(cell.msgLabel.text.length>= 1 && cell.msgLabel.text.length <= 3)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_2"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length >=3 && cell.msgLabel.text.length <= 5)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_3"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length > 5 && cell.msgLabel.text.length <= 12)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_msg_4"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length > 12&& cell.msgLabel.text.length <= 24)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_msg_5"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length > 24)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_msg_6"] forState:UIControlStateNormal];
            //            }
            NSLog(@"cell.msgLabel.text.length:%lu",cell.msgLabel.text.length);;
            
            return cell;
        }
        else
        {
            static NSString *cellID = @"send";
            UINib *nib = [UINib nibWithNibName:@"SendAudioTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellID];
            SendAudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            
            if (cell == nil)
            {
                cell = [[SendAudioTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            }
            cell.signalImage.hidden = NO;
            cell.lengthLabel.hidden = NO;
            //            cell.msgLabel.hidden = YES;
            [cell.listButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
            UIImage* image = [UIImage imageNamed:@"send_1"];
            image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
            [cell.listButton setBackgroundImage:image forState:UIControlStateNormal];
            NSMutableString* str = [[NSMutableString alloc]initWithString:@"  "];
            for (int i=1; i<audioModel.Length.integerValue;i++)
            {
                str = [str stringByAppendingFormat:@"   "];
                //                str = [NSString stringWithFormat:@"%@",str];
            }
            cell.msgLabel.text = str;
            CGFloat cellHeight = cell.bounds.size.height;
            CGFloat sumHeight;
            if (cell.msgLabel.bounds.size.height > cellHeight)
            {
                sumHeight = cell.msgLabel.bounds.size.height + cellHeight;
                cellHeightArr[indexPath.row] =  [NSString stringWithFormat:@"%f",sumHeight];
            }else
            {
                cellHeightArr[indexPath.row] =  [NSString stringWithFormat:@"%f",cell.bounds.size.height];
            }
            if(audioModel.Length.intValue == 1 || audioModel.Length.intValue == 2)
            {
                
                cell.listButton.frame = CGRectMake(self.view.frame.size.width - 104, 25, 64, 33);
                //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_1"] forState:UIControlStateNormal];
            }
            else if(audioModel.Length.intValue == 3 || audioModel.Length.intValue == 4)
            {
                cell.listButton.frame = CGRectMake(self.view.frame.size.width - 114, 25, 104, 33);
                //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_2"] forState:UIControlStateNormal];
            }
            else if(audioModel.Length.intValue == 5 || audioModel.Length.intValue == 6 || audioModel.Length.intValue == 7)
            {
                cell.listButton.frame = CGRectMake(self.view.frame.size.width - 124, 25, 144, 33);
                //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_3"] forState:UIControlStateNormal];
            }
            else if(audioModel.Length.intValue == 8 || audioModel.Length.intValue == 9 || audioModel.Length.intValue == 10)
            {
                cell.listButton.frame = CGRectMake(self.view.frame.size.width - 144, 25, 184, 33);
                //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_4"] forState:UIControlStateNormal];
            }
            else if(audioModel.Length.intValue == 11 || audioModel.Length.intValue == 12 || audioModel.Length.intValue == 13 || audioModel.Length.intValue == 14 || audioModel.Length.intValue == 15)
            {
                cell.listButton.frame = CGRectMake(self.view.frame.size.width - 154, 25, 214, 33);
                //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"send_5"] forState:UIControlStateNormal];
            }
            //
            ContactModel *contantModel = [[ContactModel alloc] init];
            NSArray *array = [manager isSelectContactTable:deviceModel.BindNumber];
            for(int i = 0; i < array.count;i++)
            {
                ContactModel *model = [array objectAtIndex:i];
                if([model.ObjectId isEqualToString:@"1"])
                {
                    contantModel = model;
                }
            }
            
            cell.nameLabel.text = contantModel.Relationship;
            if(!contantModel.DeviceContactId.length){
                cell.headImage.image = [UIImage imageNamed:@"head_1"];
            }else if(!contantModel.HeadImg.length)
            {
                cell.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_%d",contantModel.Photo.intValue]];
                
            }
            else
            {
                [cell.headImage setImageWithURL:[NSURL URLWithString:contantModel.HeadImg]];
                
            }
            
            
            //cell.timeLabel.text =audioModel.CreateTime;
            if(audioModel.CreateTime.length > 16){
                cell.timeLabel.text = [audioModel.CreateTime substringWithRange:NSMakeRange(0,16)];
            }else{
                cell.timeLabel.text = @"";
            }
            if(audioModel.Length.intValue < 1)
            {
                cell.lengthLabel.text = [NSString stringWithFormat:@"%d″",1];
            }
            else
            {
                cell.lengthLabel.text = [NSString stringWithFormat:@"%d″",audioModel.Length.intValue];
            }
            [cell.listButton addTarget:self action:@selector(beginPlay:) forControlEvents:UIControlEventTouchUpInside];
            cell.listButton.tag = indexPath.row;
            
            NSLog(@"cell.msgLabel.text.length:%lu",cell.msgLabel.text.length);;
            return cell;
        }
        
    }
    else//回复方
    {
        if(audioModel.MsgType.intValue == 1)
        {
            static NSString *cellID = @"reply";
            
            UINib *nib = [UINib nibWithNibName:@"ReplyAudioTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellID];
            ReplyAudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            //ReplyMsgTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[ReplyAudioTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            }
            
            cell.singalImage.hidden = YES;
            cell.lengthLabel.hidden = YES;
            cell.iconImage.hidden = YES;
            //cell.listButton.selected = YES;
            
            if(audioModel.Type.intValue != 3)
            {
                if([deviceModel.Photo isEqualToString:@""])
                {
                    cell.headImage.image = [UIImage imageNamed:@"user_head_normal"];
                }
                else
                {
                    [cell.headImage setImageWithURL:[NSURL URLWithString:deviceModel.Photo]];
                }
                cell.nameLabel.text = deviceModel.BabyName;
                
            }
            else
            {
                ContactModel *contantModel = [[ContactModel alloc] init];
                NSArray *array = [manager isSelectContactTable:deviceModel.BindNumber];
                for(int i = 0; i < array.count;i++)
                {
                    ContactModel *model = [array objectAtIndex:i];
                    if([model.ObjectId isEqualToString:@"1"])
                    {
                        contantModel = model;
                    }
                }
                if(contantModel.HeadImg.length == 0)
                {
                    cell.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_%d",contantModel.Photo.intValue]];
                }
                else
                {
                    [cell.headImage setImageWithURL:[NSURL URLWithString:contantModel.HeadImg]];
                    
                }
                
                cell.nameLabel.text = contantModel.Relationship;
            }
//            if(deviceModel.Photo.length){
//            [cell.headImage setImageWithURL:[NSURL URLWithString:deviceModel.Photo]];
//            }else{
//                cell.headImage.image = [UIImage imageNamed:@"ic_device_portrait"];
//            }
            cell.headImage.image = [UIImage imageNamed:@"ic_device_portrait"];
            cell.nameLabel.text = deviceModel.BabyName;
            //cell.timeLabel.text =audioModel.CreateTime;
            if(audioModel.CreateTime.length > 16){
                cell.timeLabel.text = [audioModel.CreateTime substringWithRange:NSMakeRange(0,16)];
            }else{
                cell.timeLabel.text = @"";
            }
            
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *P = [paths objectAtIndex:0];
//
//            NSArray *url = [audioModel.Path componentsSeparatedByString:@"/"];
//            NSArray * urlArray = [[url objectAtIndex:1] componentsSeparatedByString:@"."];
//            NSString *extension = [NSString stringWithFormat:@"%@/%@-%@.txt",P,[url objectAtIndex:0],[urlArray objectAtIndex:0]];
//            NSFileManager *fileManager = [NSFileManager defaultManager];
            
//            if(![fileManager fileExistsAtPath:extension]) //如果不存在
//            {
//                cell.iconImage.hidden = NO;
//            }
//            else
//            {
//                cell.iconImage.hidden = YES;
//            }
            cell.iconImage.hidden = YES;
//            NSString *txt = [NSString stringWithFormat:@"%@/%@-%@",P,[url objectAtIndex:0],[url objectAtIndex:1]];
//            NSURL *url_reply = [NSURL URLWithString:[NSString stringWithFormat:HTTPS,AUDIO,audioModel.Path]];
//            NSData * myData = [NSData dataWithContentsOfURL:url_reply];
//            [myData writeToFile:txt atomically:YES];
            
            //[cell.listButton setTitle:[NSString stringWithContentsOfURL:url_reply encoding:NSUTF8StringEncoding error:nil] forState:UIControlStateNormal];
            
            cell.msgLabel.numberOfLines = 0;
            cell.msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
            CGSize size = [cell.msgLabel sizeThatFits:CGSizeMake(cell.msgLabel.frame.size.width, MAXFLOAT)];
            cell.msgLabel.frame =CGRectMake(0, 35, 200, size.height+30);
//            cell.msgLabel.font = [UIFont systemFontOfSize:15];
            
            cell.msgLabel.text = audioModel.Path;
            UIImage* image = [UIImage imageNamed:@"reply_1"];
            image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
            [cell.listButton setBackgroundImage:image forState:UIControlStateNormal];
            //
            //            if(cell.msgLabel.text.length>= 1 && cell.msgLabel.text.length <= 3)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_2"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length >=3 && cell.msgLabel.text.length <= 5)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_3"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length > 5 && cell.msgLabel.text.length <= 12)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_msg_4"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length > 12&& cell.msgLabel.text.length <= 24)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_msg_5"] forState:UIControlStateNormal];
            //            }
            //            else if(cell.msgLabel.text.length > 24)
            //            {
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_msg_6"] forState:UIControlStateNormal];
            //            }
            
            return cell;
        }
        else
        {
            static NSString *cellID = @"reply";
            UINib *nib = [UINib nibWithNibName:@"ReplyAudioTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellID];
            ReplyAudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[ReplyAudioTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            }
            
            cell.singalImage.hidden = NO;
            cell.lengthLabel.hidden = NO;
            cell.iconImage.hidden = NO;
            UIImage* image = [UIImage imageNamed:@"reply_1"];
            image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
            [cell.listButton setBackgroundImage:image forState:UIControlStateNormal];
            NSMutableString* str = [[NSMutableString alloc]initWithString:@"  "];
            for (int i=1; i<audioModel.Length.integerValue;i++)
            {
                str = [str stringByAppendingFormat:@"   "];
                //                str = [NSString stringWithFormat:@"%@",str];
            }
            cell.msgLabel.text = str;
            //            cell.msgLabel.hidden = YES;
            
            //            [cell.listButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
            //
            //            if(audioModel.Length.intValue == 1 || audioModel.Length.intValue == 2)
            //            {
            //                cell.listButton.frame = CGRectMake(64, 25, 64, 33);
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_1"] forState:UIControlStateNormal];
            //            }
            //            else if(audioModel.Length.intValue == 3 || audioModel.Length.intValue == 4)
            //            {
            //                cell.listButton.frame = CGRectMake(64, 25, 74, 33);
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_2"] forState:UIControlStateNormal];
            //            }
            //            else if(audioModel.Length.intValue == 5 || audioModel.Length.intValue == 6 || audioModel.Length.intValue == 7)
            //            {
            //                cell.listButton.frame = CGRectMake(64, 25, 84, 33);
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_3"] forState:UIControlStateNormal];
            //            }
            //            else if(audioModel.Length.intValue == 8 || audioModel.Length.intValue == 9 || audioModel.Length.intValue == 10)
            //            {
            //                cell.listButton.frame = CGRectMake(64, 25, 104, 33);
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_4"] forState:UIControlStateNormal];
            //            }
            //            else if(audioModel.Length.intValue == 11 || audioModel.Length.intValue == 12 || audioModel.Length.intValue == 13 || audioModel.Length.intValue == 14 || audioModel.Length.intValue == 15)
            //            {
            //                cell.listButton.frame = CGRectMake(64, 25, 114, 33);
            //                [cell.listButton setBackgroundImage:[UIImage imageNamed:@"reply_5"] forState:UIControlStateNormal];
            //            }
            
            if(audioModel.Type.intValue != 3)
            {
                if([deviceModel.Photo isEqualToString:@""])
                {
                    cell.headImage.image = [UIImage imageNamed:@"user_head_normal"];
                }
                else
                {
                    [cell.headImage setImageWithURL:[NSURL URLWithString:deviceModel.Photo]];
                }
                cell.nameLabel.text = deviceModel.BabyName;
                
            }
            else
            {
                ContactModel *contantModel = [[ContactModel alloc] init];
                NSArray *array = [manager isSelectContactTable:deviceModel.BindNumber];
                for(int i = 0; i < array.count;i++)
                {
                    ContactModel *model = [array objectAtIndex:i];
                    if([model.ObjectId isEqualToString:@"1"])
                    {
                        contantModel = model;
                    }
                }
                if(contantModel.HeadImg.length == 0)
                {
                    cell.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_%d",contantModel.Photo.intValue]];
                }
                else
                {
                    [cell.headImage setImageWithURL:[NSURL URLWithString:contantModel.HeadImg]];
                    
                }
                
                cell.nameLabel.text = contantModel.Relationship;
            }
//            if(deviceModel.Photo.length){
//                [cell.headImage setImageWithURL:[NSURL URLWithString:deviceModel.Photo]];
//            }else{
//                cell.headImage.image = [UIImage imageNamed:@"ic_device_portrait"];
//            }
            cell.headImage.image = [UIImage imageNamed:@"ic_device_portrait"];
            cell.nameLabel.text = deviceModel.BabyName;
            // cell.timeLabel.text =audioModel.CreateTime;
            if(audioModel.CreateTime.length > 16){
                cell.timeLabel.text = [audioModel.CreateTime substringWithRange:NSMakeRange(0,16)];
            }else{
                cell.timeLabel.text = @"";
            }
            if(audioModel.Length.intValue < 1)
            {
                cell.lengthLabel.text = [NSString stringWithFormat:@"%d″",1];
            }
            else
            {
                cell.lengthLabel.text = [NSString stringWithFormat:@"%d″",audioModel.Length.intValue];
            }
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *P = [paths objectAtIndex:0];
            
            NSArray *url = [audioModel.Path componentsSeparatedByString:@"/"];
            NSArray * urlArray = [[url objectAtIndex:url.count-1] componentsSeparatedByString:@"."];
            NSString *extension = [NSString stringWithFormat:@"%@/%@.wav",P,[urlArray objectAtIndex:0]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:extension]) //如果不存在
            {
                cell.iconImage.hidden = NO;
            }
            else
            {
                cell.iconImage.hidden = YES;
            }
            
            [cell.listButton addTarget:self action:@selector(beginPlay:) forControlEvents:UIControlEventTouchUpInside];
            cell.listButton.tag = indexPath.row;
            return cell;
        }
    }
}

/*
 - (void)ReplyMsg:(UIButton *)btn
 {
 button = btn;
 [defaults setInteger:btn.tag forKey:@"btn"];
 AudioModel *model = [listVoice objectAtIndex:btn.tag];
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *P = [paths objectAtIndex:0];
 NSArray *url = [model.Path componentsSeparatedByString:@"/"];
 NSArray * urlArray = [[url objectAtIndex:1] componentsSeparatedByString:@"."];
 
 NSString *txt = [NSString stringWithFormat:@"%@/%@-%@",P,[url objectAtIndex:0],[url objectAtIndex:1]];
 
 NSFileManager *fileManager = [NSFileManager defaultManager];
 //if(![fileManager fileExistsAtPath:txt]) //如果不存在
 {
 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@?path=%@",AUDIO,model.Path]];
 NSData * myData = [NSData dataWithContentsOfURL:url];
 
 [myData writeToFile:txt atomically:YES];
 
 reply_msg = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
 }
 
 }
 */

- (void)beginPlay:(UIButton *)btn
{
    button = btn;
    [defaults setInteger:btn.tag forKey:@"btn"];
    AudioModel *model = [listVoice objectAtIndex:btn.tag];
    [self.audioPlayer stop];
    if(lastButton!=nil)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            AudioModel *lastModel = [listVoice objectAtIndex:lastButton.tag];
            if(lastModel.Type.intValue == 3 &&[lastModel.ObjectId isEqualToString:[defaults stringForKey:@"UserId"]])
            {
                SendAudioTableViewCell *cell = ((SendAudioTableViewCell*)[[lastButton   superview]superview]);
                [cell.signalImage stopAnimating];
            }
            else
            {
                ReplyAudioTableViewCell *cell = ((ReplyAudioTableViewCell*)[[lastButton   superview]superview]);
                [cell.singalImage stopAnimating];
            }
        }
    }
    
    if (lastButton==btn) {
        lastButton=nil;
    }
    else{
        lastButton=btn;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *P = [paths objectAtIndex:0];
        NSArray *url = [model.Path componentsSeparatedByString:@"/"];
        NSArray * urlArray = [[url objectAtIndex:url.count-1] componentsSeparatedByString:@"."];
        NSString *amr = [NSString stringWithFormat:@"%@/%@",P,[url objectAtIndex:url.count-1]];
        
        NSString *wav = [NSString stringWithFormat:@"%@/%@.wav",P,[urlArray objectAtIndex:0]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:amr]) //如果不存在
        {
            NSURL *url = [NSURL URLWithString:model.Path];
            NSData * myData = [NSData dataWithContentsOfURL:url];
            
            [myData writeToFile:amr atomically:YES];
            [VoiceConverter amrToWav:amr wavSavePath:wav];
            
        }
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
        NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(audioPlay:)
                                                       object:wav];
        [myThread start];
        
        isShow = YES;
        
        if(model.Type.intValue == 3 &&[model.ObjectId isEqualToString:[defaults stringForKey:@"UserId"]])
        {
            SendAudioTableViewCell *cell = ((SendAudioTableViewCell*)[[btn   superview]superview]);
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                UIImage *image1 = [UIImage imageNamed:@"send_signal_1"];
                UIImage *image2 = [UIImage imageNamed:@"send_signal_2"];
                UIImage *image3 = [UIImage imageNamed:@"send_signal_3"];
                
                cell.signalImage.animationDuration = 2;
                cell.signalImage.animationImages = @[image1,image2,image3];
                
                [cell.signalImage startAnimating];
            }
        }
        else
        {
            ReplyAudioTableViewCell *cell = ((ReplyAudioTableViewCell*)[[btn   superview]superview]);
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                cell.iconImage.hidden = YES;
                UIImage *image1 = [UIImage imageNamed:@"reply_signal_1"];
                UIImage *image2 = [UIImage imageNamed:@"reply_signal_2"];
                UIImage *image3 = [UIImage imageNamed:@"reply_signal_3"];
                
                cell.singalImage.animationDuration = 2;
                cell.singalImage.animationImages = @[image1,image2,image3];
                
                [cell.singalImage startAnimating];
            }
        }
    }
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//
//    [tableView cellForRowAtIndexPath:indexPath];
////    NSLog(@"ddddddd%d",hight);
////    self.sende.contentLabel.text=self.dataArray[indexPath.row%2];
////    [self.adaptionCell layoutIfNeeded];
////    CGFloat height = [self.adaptionCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    NSString* height = cellHeightArr[indexPath.row];
//
//    return height.doubleValue;
//}

-(void)audioPlay:(NSString *) path
{
    NSError  *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    
    NSLog(@"%@",error);
    NSLog(@"%@",self.audioPlayer);
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
}

-(NSURL *)getSavePath{
    urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:@"myRecord.wav"];
    NSLog(@"file path:%@",urlStr);
    
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    
    return url;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    AudioModel *model = [listVoice objectAtIndex:[defaults integerForKey:@"btn"]];
    
    if(model.Type.intValue == 3 &&[model.ObjectId isEqualToString:[defaults stringForKey:@"UserId"]])
    {
        lastButton=nil;
        
        SendAudioTableViewCell *cell = ((SendAudioTableViewCell*)[[button   superview]superview]);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            
            [cell.signalImage stopAnimating];
            
        }    }
    else
    {
        lastButton=nil;
        
        ReplyAudioTableViewCell *cell = ((ReplyAudioTableViewCell*)[[button   superview]superview]);
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            
            [cell.singalImage stopAnimating];
            
        }
    }
    isShow = NO;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (listVoice.count > 0&&isLoad) {
        if (indexPath.row == 0&&pageindex<pageTotal) {
            pageindex++;
            [self getLoad];
        }
    }
    if(_isScrollBottom == NO)
    {
//        cell.i
           [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:listVoice.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    if (indexPath.row == listVoice.count-1)
    {
        
        AudioModel* model1 = listVoice[indexPath.row];
        if(audioModel.MsgType.intValue == 1 && ![audioModel.ObjectId isEqualToString:[defaults stringForKey:@"UserId"]]&&isNumOne == YES)
        {
            [self playSoundEffect:@"水滴.wav"];
        }
        self.isScrollBottom = YES;
    }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    _isScrollBottom = YES;
    
//    _oldOffset = scrollView.contentOffset.y;//将当前位移变成缓存位移
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    
}
-(AVAudioRecorder *)audioRecorder{
    if (!self.recorder) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        self.recorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        self.recorder.delegate=self;
        self.recorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    
    [_recorder setDelegate:self];
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
    
    return self.recorder;
}

-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self upLoadAudio];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [refreshTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)playSoundEffect:(NSString *)name{
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    //1.获得系统声音ID
    SystemSoundID soundID=0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
//    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, NULL, NULL);
    //2.播放音频
    AudioServicesPlaySystemSound(soundID);//播放音效
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}
//void soundCompleteCallback(SystemSoundID soundID,void * clientData){
//    NSLog(@"播放完成...");
//}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
