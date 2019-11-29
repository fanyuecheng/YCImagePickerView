//
//  YCAsset.m
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/29.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import "YCAsset.h"

@implementation YCAsset

- (UIImage *)thumbnailImage {
    if (!_thumbnailImage) {
        _thumbnailImage = [self previewImage];
    }
    return _thumbnailImage;
}

@end
