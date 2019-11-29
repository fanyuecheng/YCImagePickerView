//
//  YCImageReusableView.m
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/29.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import "YCImageReusableView.h"

@implementation YCImageReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialized];
    }
    return self;
}

- (void)initialized {
    [self addSubview:self.selectedButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.selectedButton.frame = CGRectMake(4, 4, 22, 22);
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [[UIButton alloc] init];
        [_selectedButton setImage:[UIImage imageNamed:@"round_unselect"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"round_selected"] forState:UIControlStateSelected];
    }
    return _selectedButton;
}

@end
