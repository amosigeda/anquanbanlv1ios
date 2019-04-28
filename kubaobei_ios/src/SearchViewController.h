//
//  SearchViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface SearchViewController : UIViewController
@property(nonatomic,strong)NSString* la;
@property(nonatomic,assign)BOOL isPosition;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic)CLLocationCoordinate2D myLocation;;
@property (nonatomic,strong) NSMutableArray *nameArr;
@property (weak, nonatomic) IBOutlet UILabel *watch_address_Label;
@property (weak, nonatomic) IBOutlet UILabel *phone_address_label;
@property (weak, nonatomic) IBOutlet UILabel *around_address_label;

@end
