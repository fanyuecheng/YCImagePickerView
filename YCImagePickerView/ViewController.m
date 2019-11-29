//
//  ViewController.m
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/28.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import "ViewController.h"
#import "YCImagePickerView.h"
#import <QMUIKit/QMUIKit.h>

@interface ViewController () <QMUIAlbumViewControllerDelegate, QMUIImagePickerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"YCImagePickerView";
    
    
    YCImagePickerView *imagePickerView = [[YCImagePickerView alloc] initWithFrame:CGRectMake(0, 300, SCREEN_WIDTH, 220)];
    [imagePickerView loadDataSourceIfAuthorized];
    
    
    __weak __typeof(self)weakSelf = self;
    imagePickerView.albumBlock = ^{
        NSLog(@"从相册中选择");
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf presentAlbumViewController];
    };
    
    imagePickerView.editBlock = ^(QMUIAsset * _Nonnull asset) {
        NSLog(@"编辑图片 %@", asset);
    };
    
    imagePickerView.pickedBlock = ^(NSArray<QMUIAsset *> * _Nonnull images, BOOL original) {
        NSLog(@"选择图片 %@ %@", images, original ? @"原图" : @"非原图");
    };
    
    [self.view addSubview:imagePickerView];
    
}


- (void)presentAlbumViewController {
    QMUIAlbumViewController *albumViewController = [[QMUIAlbumViewController alloc] init];
    albumViewController.albumViewControllerDelegate = self;
    albumViewController.contentType = QMUIAlbumContentTypeOnlyPhoto;
 
    QMUINavigationController *navigationController = [[QMUINavigationController alloc] initWithRootViewController:albumViewController];
 
    [albumViewController pickLastAlbumGroupDirectlyIfCan];
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - QMUIAlbumViewControllerDelegate
- (QMUIImagePickerViewController *)imagePickerViewControllerForAlbumViewController:(QMUIAlbumViewController *)albumViewController {
    QMUIImagePickerViewController *imagePickerViewController = [[QMUIImagePickerViewController alloc] init];
    imagePickerViewController.imagePickerViewControllerDelegate = self;
    imagePickerViewController.allowsMultipleSelection = YES;
    imagePickerViewController.maximumSelectImageCount = 4;
    
    return imagePickerViewController;
}

#pragma mark - <QMUIImagePickerViewControllerDelegate>
- (void)imagePickerViewController:(QMUIImagePickerViewController *)imagePickerViewController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<QMUIAsset *> *)imagesAssetArray {
    // 储存最近选择了图片的相册，方便下次直接进入该相册
    [QMUIImagePickerHelper updateLastestAlbumWithAssetsGroup:imagePickerViewController.assetsGroup ablumContentType:QMUIAlbumContentTypeOnlyPhoto userIdentify:nil];
    
    NSLog(@"didFinishPicking %@", imagesAssetArray);
}

- (QMUIImagePickerPreviewViewController *)imagePickerPreviewViewControllerForImagePickerViewController:(QMUIImagePickerViewController *)imagePickerViewController {
     
    QMUIImagePickerPreviewViewController *imagePickerPreviewViewController = [[QMUIImagePickerPreviewViewController alloc] init];
    
    return imagePickerPreviewViewController;
}

@end
