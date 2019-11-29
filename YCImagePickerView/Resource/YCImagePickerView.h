//
//  YCImagePickerView.h
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/28.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIAsset;
@interface YCImagePickerView : UIView

@property (nonatomic, copy) void (^albumBlock)(void);
@property (nonatomic, copy) void (^editBlock)(QMUIAsset *asset);
@property (nonatomic, copy) void (^pickedBlock)(NSArray <QMUIAsset *> *images, BOOL original);

- (void)loadDataSourceIfAuthorized;
- (void)clearSelectedImage;

@end

NS_ASSUME_NONNULL_END
