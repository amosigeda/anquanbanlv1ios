//
//  CustomAnnotation.h
//  NewGps2012
//
//  Created by TR on 13-2-18.
//  Copyright (c) 2013年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MylocationAnnotationView.h"

@interface MyLocationAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    int annotationId;
    MylocationAnnotationView * annotationView;
}
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) int annotationId;
@property(retain) MylocationAnnotationView * annotationView;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
