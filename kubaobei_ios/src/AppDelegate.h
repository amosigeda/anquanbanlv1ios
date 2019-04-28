//
//  AppDelegate.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import <UIKit/UIKit.h>
@import RDVTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (RDVTabBarController *)setupViewControllers;

@property UIApplication *application;
@property NSDictionary *launchOptions;
-(void)rootWindows;

@end

