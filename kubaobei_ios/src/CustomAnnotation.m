//
//  CustomAnnotation.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize annotationView;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init]) {
        self.coordinate = aCoordinate;
    }
    return self;
}

@end
