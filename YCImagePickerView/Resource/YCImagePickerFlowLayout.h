//
//  YCImagePickerFlowLayout.h
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/28.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCImagePickerFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) NSMutableArray *layoutAttributes;

@end

NS_ASSUME_NONNULL_END
