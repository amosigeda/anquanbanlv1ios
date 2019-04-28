//
//  PhotoCollectionViewCell.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image_ImageView;
@property (weak, nonatomic) IBOutlet UIView *baView;
@property (weak, nonatomic) IBOutlet UIImageView *bg_Image;

@property (weak, nonatomic) IBOutlet UIButton *isEditing;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@end
