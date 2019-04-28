//
//  StreetViewViewController.h
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/3/11.
//  Copyright © 2019年 HH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreetViewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property(nonatomic,copy) NSString *lat;
@property(nonatomic,copy) NSString *lng;

@end
