//
//  CustomAnnotation.m
//  NewGps2012
//
//  Created by TR on 13-2-18.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import "MyLocationAnnotation.h"

@implementation MyLocationAnnotation
@synthesize annotationView;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init]) {
        self.coordinate = aCoordinate;
    }
    return self;
}

@end
