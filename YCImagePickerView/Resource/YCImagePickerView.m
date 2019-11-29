//
//  YCImagePickerView.m
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/28.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import "YCImagePickerView.h"
#import "YCAsset.h"
#import "YCImageReusableView.h"
#import "YCImagePickerFlowLayout.h"
#import "YCImagePickerCollectionViewCell.h"

@interface YCImagePickerView () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton         *albumButton;
@property (nonatomic, strong) UIButton         *editButton;
@property (nonatomic, strong) UIButton         *originalButton;
@property (nonatomic, strong) UIButton         *confirmButton;
@property (nonatomic, strong) UILabel          *tipLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint          gestureBeganLocation;
@property (nonatomic, strong) NSIndexPath      *gestureIndexPath;

@property (nonatomic, copy)   NSArray          *dataSource;
@property (nonatomic, strong) NSMutableArray <QMUIAsset *>* selectedImageArray;

@end

@implementation YCImagePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialized];
    }
    return self;
}

- (void)initialized {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.albumButton];
    [self addSubview:self.editButton];
    [self addSubview:self.originalButton];
    [self addSubview:self.confirmButton];
    [self addSubview:self.collectionView];
    [self addSubview:self.loadingView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 180);
    self.albumButton.frame = CGRectMake(20, 180, self.albumButton.qmui_width, 40);
    self.editButton.frame = CGRectMake(self.albumButton.qmui_right + 20, 180, self.editButton.qmui_width, 40);
    self.originalButton.frame = CGRectMake(self.editButton.qmui_right + 20, 180, 120, 40);
    self.confirmButton.frame = CGRectMake(self.qmui_width - 100, 185, 80, 30);
    self.tipLabel.frame = CGRectMake(20, 0, SCREEN_WIDTH - 40, 180);
    self.loadingView.frame = CGRectMake((SCREEN_WIDTH - 20) * 0.5, 80, 20, 20);
}

#pragma mark - Action
- (void)buttonAction:(UIButton *)sender {
    switch (sender.tag) {
        case 1000:
            !self.albumBlock ? : self.albumBlock();
            [self clearSelectedImage];
            break;
            
        case 1001:
            !self.editBlock ? : self.editBlock(self.selectedImageArray.firstObject );
            break;
            
        case 1002:
            sender.selected = !sender.selected;
            [self calculateSize];
            break;
            
        case 1003:
            !self.pickedBlock ? : self.pickedBlock(self.selectedImageArray.copy, self.originalButton.isSelected);
            [self clearSelectedImage];
            break;
        default:
            break;
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.gestureBeganLocation = [sender locationInView:self.collectionView];
            self.gestureIndexPath = [self.collectionView indexPathForItemAtPoint:self.gestureBeganLocation];
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [sender locationInView:self.collectionView];
            CGFloat vDistance = location.y - self.gestureBeganLocation.y;
            
            YCImagePickerCollectionViewCell *cell = (YCImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.gestureIndexPath];
            
            cell.contentImageView.frame = CGRectSetY(cell.contentImageView.frame, vDistance);
            
            cell.sendLabel.alpha = vDistance < -100 ? 1 : 0;
            
            [self setCollectionReusableViewHidden:YES indexPath:self.gestureIndexPath];
            
            self.collectionView.scrollEnabled = NO;
            
            break;}
            
        case UIGestureRecognizerStateEnded: {
            CGPoint location = [sender locationInView:self.collectionView];
            CGFloat vDistance = location.y - self.gestureBeganLocation.y;
            
            YCImagePickerCollectionViewCell *cell = (YCImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.gestureIndexPath];
            
            if (vDistance < -100 && cell.asset) {
                !self.pickedBlock ? : self.pickedBlock(@[cell.asset], self.originalButton.isSelected);
            }
            
            [UIView animateWithDuration:.25 animations:^{
                cell.contentImageView.frame = CGRectSetY(cell.contentImageView.frame, 0);
                cell.sendLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [self setCollectionReusableViewHidden:NO indexPath:self.gestureIndexPath];
            }];

            self.collectionView.scrollEnabled = YES;
            break;}
        default:
            
            break;
    }
}

#pragma mark - Method
- (void)clearSelectedImage {
    if (self.selectedImageArray.count) {
        [self.selectedImageArray removeAllObjects];
        self.confirmButton.enabled = NO;
        self.editButton.enabled = NO;
        self.originalButton.selected = NO;
        [self calculateSize];
        [self.collectionView reloadData];
    }
}

- (void)loadDataSourceIfAuthorized {
    [self.loadingView startAnimating];
    self.tipLabel.hidden = YES;
 
    if ([QMUIAssetsManager authorizationStatus] == QMUIAssetAuthorizationStatusNotAuthorized) {
        self.tipLabel.text = @"请在设备的\"设置-隐私-照片\"选项中，允许米画师访问您的手机相册";
        self.tipLabel.hidden = NO;
        [self.loadingView stopAnimating];
    } else if ([QMUIAssetsManager authorizationStatus] == QMUIAssetAuthorizationStatusNotDetermined) {
        [QMUIAssetsManager requestAuthorization:^(QMUIAssetAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadDataSourceIfAuthorized];
            });
        }];
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __weak __typeof(self)weakSelf = self;
            [self fetchCameraRollAssets:^(NSArray *assetArray) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                NSMutableArray *assetItemArray = [NSMutableArray array];
                
                [assetArray enumerateObjectsUsingBlock:^(QMUIAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    YCAsset *asset = [[YCAsset alloc] initWithPHAsset:obj.phAsset];
                    [assetItemArray addObject:asset];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.loadingView stopAnimating];
                    strongSelf.dataSource = assetItemArray.copy;
                });
            }];
        });
    }
}

- (void)fetchCameraRollAssets:(void (^)(NSArray *assetArray))finished {
    NSMutableArray *assetsArray = [[NSMutableArray alloc] init];
    NSMutableArray *albumsArray = [[NSMutableArray alloc] init];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    // 循环遍历相册列表
    for (NSInteger i = 0; i < fetchResult.count; i++) {
        PHCollection *collection = fetchResult[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            PHFetchResult *currentFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
            if (currentFetchResult.count > 0) {
                [albumsArray addObject:assetCollection];
            }
        } else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
    for (NSUInteger i = 0; i < albumsArray.count; i++) {
        PHAssetCollection *phAssetCollection = albumsArray[i];
        QMUIAssetsGroup *assetsGroup = [[QMUIAssetsGroup alloc] initWithPHCollection:phAssetCollection fetchAssetsOptions:fetchOptions];
        //最多只取30张
        for (NSInteger i = assetsGroup.phFetchResult.count - 1; i >= 0; i--) {
            
            if (assetsArray.count >= 30) {
                break;
            }
            
            PHAsset *pHAsset = assetsGroup.phFetchResult[i];
            QMUIAsset *asset = [[QMUIAsset alloc] initWithPHAsset:pHAsset];
            [assetsArray addObject:asset];
        }
    }
    
    !finished ? : finished(assetsArray.copy);
}

- (void)calculateSize {
    if (self.originalButton.isSelected && self.selectedImageArray.count) {
        __block long long totalSize = 0;
        __block NSUInteger num = 0;
        for (QMUIAsset *asset in self.selectedImageArray) {
            [asset assetSize:^(long long size) {
                totalSize += size;
                num ++;
                if (num == self.selectedImageArray.count) {
                    NSString *fileSize =  [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
                    
                    [self.originalButton setTitle:[NSString stringWithFormat:@"原图 %@", fileSize] forState:UIControlStateNormal];
                }
            }];
        }
    } else {
        [self.originalButton setTitle:@"原图" forState:UIControlStateNormal];
    }
}

- (void)setCollectionReusableViewHidden:(BOOL)hidden
                              indexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = [self.collectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    reusableView.hidden = hidden;
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        YCImageReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YCImageReusableView" forIndexPath:indexPath];
        
        YCAsset *asset = [self.dataSource objectAtIndex:indexPath.section];
        supplementaryView.selectedButton.selected = [self.selectedImageArray containsObject:asset];
        
        __weak __typeof(self)weakSelf = self;
        supplementaryView.selectedButton.qmui_tapBlock = ^(QMUIButton *sender) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (sender.selected) {
                sender.selected = NO;
                [strongSelf.selectedImageArray removeObject:asset];
            } else {
//                if ([strongSelf.selectedImageArray count] >= 3) {
//                    //"最多只能选择三张图片"
//                    return;
//                }
                sender.selected = YES;
                [self.selectedImageArray addObject:asset];
            }
        
            [self calculateSize];
            self.editButton.enabled = self.selectedImageArray.count == 1;
            self.confirmButton.enabled = self.selectedImageArray.count;
            [self.confirmButton setTitle:[NSString stringWithFormat:@"发送 (%zd)", self.selectedImageArray.count] forState:UIControlStateNormal];
        };
        
        return supplementaryView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YCImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YCImagePickerCollectionViewCell" forIndexPath:indexPath];
    
    YCAsset *asset = [self.dataSource objectAtIndex:indexPath.section];
    
    CGSize imageSize = asset.thumbnailImage.size;

    cell.selectable = NO;
    
    [cell renderWithAsset:asset referenceSize:CGSizeIsEmpty(imageSize) ? CGSizeMake(180, 180) : CGSizeMake(180 / imageSize.height * imageSize.width, 180)];
 
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    YCAsset *asset = [self.dataSource objectAtIndex:indexPath.section];
    
    CGSize imageSize = asset.thumbnailImage.size;
    
    if (CGSizeIsEmpty(imageSize)) {
        return CGSizeMake(180, 180);
    } else {
        return CGSizeMake(180 / imageSize.height * imageSize.width, 180);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(30, 180);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.panGesture.enabled = NO;
}

 
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.panGesture.enabled = YES;
}

#pragma mark - UIGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
 
#pragma mark - Get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        YCImagePickerFlowLayout *layout = [[YCImagePickerFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 3);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 172) collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColorGrayLighten;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.clipsToBounds = NO;
        [_collectionView registerClass:[YCImagePickerCollectionViewCell class] forCellWithReuseIdentifier:@"YCImagePickerCollectionViewCell"];
        [_collectionView registerClass:[YCImageReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YCImageReusableView"];
        
        [_collectionView addSubview:self.tipLabel];
        [_collectionView addGestureRecognizer:self.panGesture];
        
        if (@available(iOS 11, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (UIButton *)buttonWithTag:(NSInteger)tag {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [self buttonWithTag:1000];
        [_albumButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_albumButton setTitle:@"相册" forState:UIControlStateNormal];
        [_albumButton sizeToFit];
    }
    return _albumButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [self buttonWithTag:1001];
        _editButton.enabled = NO;
        [_editButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton sizeToFit];
    }
    return _editButton;
}

- (UIButton *)originalButton {
    if (!_originalButton) {
        _originalButton = [self buttonWithTag:1002];
        _originalButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_originalButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
        [_originalButton setImage:[UIImage imageNamed:@"round_unselect"] forState:UIControlStateNormal];
        [_originalButton setImage:[UIImage imageNamed:@"round_selected"] forState:UIControlStateSelected];
    }
    return _originalButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [self buttonWithTag:1003];
        _confirmButton.enabled = NO;
        _confirmButton.layer.cornerRadius = 15;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton setBackgroundImage:[UIImage qmui_imageWithColor:UIColorBlue] forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[UIImage qmui_imageWithColor:UIColorDisabled] forState:UIControlStateDisabled];
        [_confirmButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_confirmButton setTitle:@"发送" forState:UIControlStateDisabled];
    }
    return _confirmButton;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor darkTextColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
    }
    return _tipLabel;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray size:CGSizeMake(20, 20)];
        _loadingView.hidesWhenStopped = YES;
    }
    return _loadingView;
}

- (NSMutableArray *)selectedImageArray {
    if (!_selectedImageArray) {
        _selectedImageArray = [NSMutableArray array];
    }
    return _selectedImageArray;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    if (!dataSource.count) {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = @"空相册";
    } else {
        self.tipLabel.hidden = YES;
    }
    [self.collectionView reloadData];
}

@end

 
