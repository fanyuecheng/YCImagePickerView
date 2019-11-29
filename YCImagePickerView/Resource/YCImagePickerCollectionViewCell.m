//
//  YCImagePickerCollectionViewCell.m
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/29.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import "YCImagePickerCollectionViewCell.h"

@interface YCImagePickerCollectionViewCell ()
 
@end

@implementation YCImagePickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentImageView addSubview:self.sendLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.sendLabel.frame = CGRectMake((self.qmui_width - 70) * 0.5, 10, 70, 20);
}
 
- (void)renderWithAsset:(QMUIAsset *)asset referenceSize:(CGSize)referenceSize {
    [super renderWithAsset:asset referenceSize:referenceSize];
    
    _asset = asset;
}

#pragma mark - Get
- (UILabel *)sendLabel {
    if (!_sendLabel) {
        _sendLabel = [[UILabel alloc] init];
        _sendLabel.backgroundColor = UIColorGrayLighten;
        _sendLabel.font = [UIFont systemFontOfSize:12];
        _sendLabel.textColor = [UIColor whiteColor];
        _sendLabel.textAlignment = NSTextAlignmentCenter;
        _sendLabel.text = @"松手发送";
        _sendLabel.alpha = 0;
        _sendLabel.layer.cornerRadius = 10;
        _sendLabel.layer.masksToBounds = YES;
        [_sendLabel sizeToFit];
    }
    return _sendLabel;
}

@end
