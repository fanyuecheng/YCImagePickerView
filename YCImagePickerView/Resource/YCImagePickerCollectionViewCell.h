//
//  YCImagePickerCollectionViewCell.h
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/29.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIAsset;
@interface YCImagePickerCollectionViewCell : QMUIImagePickerCollectionViewCell

@property (nonatomic, strong, readonly) QMUIAsset *asset;
@property (nonatomic, strong) UILabel *sendLabel;

@end

NS_ASSUME_NONNULL_END
