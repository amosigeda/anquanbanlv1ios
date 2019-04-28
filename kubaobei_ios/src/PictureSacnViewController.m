//
//  PictureSacnViewController.m
//  Nursery
//
//  Created by chenp on 16/10/19.
//  Copyright © 2016年 chenp. All rights reserved.
//

#import "PictureSacnViewController.h"

#import "PicScrollView.h"
#import <Photos/Photos.h>
#import "OMGToast.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface PictureSacnViewController ()<UIScrollViewDelegate,UIActionSheetDelegate>
{
    UIScrollView *mainScrollView;
    int currenPage;
    UILabel *numLabel;
}

@end

@implementation PictureSacnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blackColor];
    currenPage=self.currenpage;
    
    [self initMainScrollView];
    
    [self initTopView];
    
    [self initSubScrollView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

//头部
-(void)initTopView
{
    numLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, screen_height - 31, screen_width, 21)];
    numLabel.text=[NSString stringWithFormat:@"%d/%ld",currenPage,self.picArray.count];
    numLabel.textColor=[UIColor whiteColor];
    numLabel.font=[UIFont systemFontOfSize:15];
    numLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:numLabel];
}

-(void)initMainScrollView
{
    mainScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    mainScrollView.showsVerticalScrollIndicator=NO;
    mainScrollView.showsHorizontalScrollIndicator=NO;
    mainScrollView.bounces=NO;
    mainScrollView.delegate=self;
    mainScrollView.pagingEnabled=YES;
    mainScrollView.contentSize=CGSizeMake(screen_width*self.picArray.count, screen_height-60);
    [self.view addSubview:mainScrollView];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [mainScrollView addGestureRecognizer:tap];
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [mainScrollView addGestureRecognizer:longPress];
    mainScrollView.userInteractionEnabled=YES;//使_imageView上的控件有点击事件
}


-(void)initSubScrollView
{
    for(int i=0;i<self.picArray.count;i++){
        PicScrollView *picscrollView=[[PicScrollView alloc] initWithFrame:CGRectMake(screen_width*i, 0, screen_width, mainScrollView.frame.size.height)];
        picscrollView.tag=10+i;
        picscrollView.picDic=[NSMutableDictionary dictionaryWithDictionary:self.picArray[i]];
        [mainScrollView addSubview:picscrollView];
        [picscrollView initImageView];
        
        picscrollView.tapBlock=^(){
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        //长按保存
        picscrollView.longBlock=^(){
            [self showActionSheet];
        };
        
        
        //自行添加label显示文字，这里不处理
        
    }
    
    [mainScrollView scrollRectToVisible:CGRectMake(screen_width*(currenPage-1), 60, screen_width, screen_height-60) animated:YES];
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint point=scrollView.contentOffset;
    if(currenPage==point.x/screen_width){//左滑
        PicScrollView *picscrollView =(PicScrollView *)[mainScrollView viewWithTag:currenPage-1+10];
        [picscrollView initImageView];
        [picscrollView initImageView];//暂时还不清楚为什么要执行两次才不出错
    }else if (currenPage-2==point.x/screen_width){//右滑
        PicScrollView *picscrollView =(PicScrollView *)[mainScrollView viewWithTag:currenPage-1+10];
        [picscrollView initImageView];
        [picscrollView initImageView];
    }
    
    currenPage=point.x/screen_width+1;
    numLabel.text=[NSString stringWithFormat:@"%d/%ld",currenPage,self.picArray.count];
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL){
        NSLog(@"保存失败");
    }else{
        
    }
    
}

-(void)tapAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)longPressAction:(UILongPressGestureRecognizer *)gestrue
{
    if (gestrue.state == UIGestureRecognizerStateBegan)
    {
        [self showActionSheet];
    }
}

-(void)showActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"save", nil)  otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self saveBtnClick];
    }

}

- (void)saveBtnClick{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted) {
        [OMGToast showWithText:@"因为系统原因, 无法访问相册" bottomOffset:50 duration:3];
    } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册(用户当初点击了"不允许")
        [OMGToast showWithText:@"请前往[设置-隐私-照片-安全伴侣]打开访问开关" bottomOffset:50 duration:3];
    } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册(用户当初点击了"好")
        [self saveImage];
    } else if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
        // 弹框请求用户授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) { // 用户点击了好
                [self saveImage];
            }
        }];
    }
}

- (void)saveImage
{
    // PHAsset的标识, 利用这个标识可以找到对应的PHAsset对象(图片对象)
    __block NSString *assetLocalIdentifier = nil;
    // 如果想对"相册"进行修改(增删改), 那么修改代码必须放在[PHPhotoLibrary sharedPhotoLibrary]的performChanges方法的block中
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 1.保存图片A到"相机胶卷"中
        // 创建图片的请求
        PicScrollView *picscrollView =(PicScrollView *)[mainScrollView viewWithTag:currenPage-1+10];
        assetLocalIdentifier = [PHAssetCreationRequest creationRequestForAssetFromImage:picscrollView.imageView.image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [OMGToast showWithText:@"保存图片失败!" bottomOffset:50 duration:3];
            });
            return;
        }
        // 2.获得相簿
        PHAssetCollection *createdAssetCollection = [self createdAssetCollection];
        if (createdAssetCollection == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [OMGToast showWithText:@"创建相簿失败!" bottomOffset:50 duration:3];
            });
            return;
        }
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            // 3.添加"相机胶卷"中的图片A到"相簿"D中
            // 获得图片
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalIdentifier] options:nil].lastObject;
            // 添加图片到相簿中的请求
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdAssetCollection];
            // 添加图片到相簿
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success == NO) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [OMGToast showWithText:@"保存图片失败!" bottomOffset:50 duration:3];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [OMGToast showWithText:@"保存图片成功!" bottomOffset:50 duration:3];
                });
            }
        }];
    }];
}

/**
 *  获得相簿
 */
- (PHAssetCollection *)createdAssetCollection
{
    // 从已存在相簿中查找这个应用对应的相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:NSLocalizedString(@"app_name", nil)]) {
            return assetCollection;
        }
    }
    // 没有找到对应的相簿, 得创建新的相簿
    // 错误信息
    NSError *error = nil;
    // PHAssetCollection的标识, 利用这个标识可以找到对应的PHAssetCollection对象(相簿对象)
    __block NSString *assetCollectionLocalIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 创建相簿的请求
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:NSLocalizedString(@"app_name", nil)].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    // 如果有错误信息
    if (error) return nil;
    // 获得刚才创建的相簿
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
