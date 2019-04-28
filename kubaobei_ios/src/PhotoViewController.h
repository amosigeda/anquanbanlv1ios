//
//  PhotoViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *photo_ImageView;
@property (weak, nonatomic) IBOutlet UILabel *photo_person_Label;
@property (weak, nonatomic) IBOutlet UILabel *photo_address_Label;
@property (weak, nonatomic) IBOutlet UILabel *photo_time_Label;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *list_View;

- (IBAction)cameraButton:(id)sender;
@end
