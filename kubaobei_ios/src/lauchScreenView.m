//
//  lauchScreenView.m
//  KuBaoBei
//
//  Created by 李晓博 on 2017/11/24.
//  Copyright © 2017年 HH. All rights reserved.
//

#import "lauchScreenView.h"

@implementation lauchScreenView

-(id)init
{
    if(self = [super init]){
        //    [self createDataBaseAndTable];
        //  [self createDeviceSetTable];
        //  [self createContactTable];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    lauchScreenView* la = [[lauchScreenView alloc]initWithFrame:frame];
    NSLog(@"dddd");
    return la;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSLog(@"dddd");
    }
    return self;
}
@end
