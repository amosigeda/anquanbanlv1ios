//
//  CustomAnnotation.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "HistoryAnntaionView.h"

@interface CustomAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    int annotationId;
    HistoryAnntaionView * annotationView;
}
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) int annotationId;
@property(retain) HistoryAnntaionView * annotationView;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
