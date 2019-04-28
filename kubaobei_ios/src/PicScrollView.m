//
//  PicScrollView.m
//  Nursery
//
//  Created by chenp on 16/10/19.
//  Copyright © 2016年 chenp. All rights reserved.
//

#import "PicScrollView.h"
#import "UIImageView+WebCache.h"

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@implementation PicScrollView



-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]){
        self.showsHorizontalScrollIndicator=NO;
        self.showsVerticalScrollIndicator=NO;
        self.delegate=self;
        self.backgroundColor=[UIColor blackColor];
        self.minimumZoomScale=1.0;
        self.maximumZoomScale=3.0;
    }
    
    return self;
}

-(void)initImageView
{
    for(UIView *view in self.subviews){
        if([view isKindOfClass:[UIImageView class]]){
            [view removeFromSuperview];
        }
    }
    
    _imageView = [[UIImageView alloc]init];
    [self addSubview:_imageView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_imageView addGestureRecognizer:tap];
    
    _imageView.userInteractionEnabled=YES;//使_imageView上的控件有点击事件
    [_imageView setImageWithURL:[NSURL URLWithString:self.picDic[@"content"]]];
//    if([self.picDic[@"islocal"] isEqualToString:@"1"]){
//        _imageView.image = [UIImage imageWithContentsOfFile:self.picDic[@"picString"]];
//    }else{
//        __weak typeof(self) weakSelf = self;
//        [_imageView setImageWithUrlPath:self.picDic[@"content"]  mId:self.picDic[@"id"]  sex:@"-1" isHeadPhoto:NO imgTag:[NSString stringWithFormat:@"%zd",self.tag] completed:^(BOOL isSuccess, UIImage *img) {
//            [weakSelf getRectfixMinImageView:weakSelf.imageView];
//        } downSuccessBlock:nil];
//    }
    
    [self getRectfixMinImageView:_imageView];
    
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [_imageView addGestureRecognizer:longPress];
    
}

-(void)tapAction
{
    self.tapBlock();
}

-(void)longPressAction:(UILongPressGestureRecognizer *)gestrue
{
    if (gestrue.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    self.longBlock();
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    [self reloadFrame];
    return _imageView;
}

-(void)reloadFrame{
    CGRect frame = _imageView.frame;
    self.contentSize = frame.size;
    if(_imageView.frame.size.width >=screen_width){
        frame.origin.x = 0;
    }else{
        frame.origin.x = screen_width/2-_imageView.frame.size.width/2;
    }
    if(_imageView.frame.size.height>=screen_height){
        frame.origin.y = 0;
    }else{
        frame.origin.y = screen_height/2 - _imageView.frame.size.height/2;
    }
    [UIView animateWithDuration:0.2 animations:^{
        _imageView.frame = frame;
    } completion:nil];
    
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [self reloadFrame];
}


-(void)getRectfixMinImageView:(UIImageView*)imgview
{
    UIImage *img = imgview.image;
    if(!img){
        CGRect frame = CGRectMake(0, (screen_height - 200)/2, screen_width, 200);
        _imageView.frame=frame;
        self.contentSize = _imageView.frame.size;
        return;
    }
    CGFloat imgWidth = img.size.width;
    CGFloat imgHeight = img.size.height;
    CGFloat kScale = img.size.height / img.size.width;
    CGFloat screebScale = screen_height / screen_width;
    if(kScale > screebScale){
        if(imgHeight > screen_height){
            imgHeight = screen_height;
            imgWidth = img.size.width/img.size.height*imgHeight;
        }
    }else{
        if(imgWidth > screen_width){
            imgWidth = screen_width;
            imgHeight = imgWidth * kScale;
        }
    }
    CGFloat marginY = (screen_height - imgHeight)/2;
    CGFloat marginX=(screen_width-imgWidth)/2;
    
    CGRect frame = CGRectMake(marginX, marginY, imgWidth, imgHeight);
    
    _imageView.frame=frame;
    self.contentSize = _imageView.frame.size;
}




@end
