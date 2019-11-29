//
//  YCImagePickerFlowLayout.m
//  YCImagePickerView
//
//  Created by 月成 on 2019/11/28.
//  Copyright © 2019 Fancy. All rights reserved.
//

#import "YCImagePickerFlowLayout.h"

@implementation YCImagePickerFlowLayout

- (instancetype)init {
    if (self = [super init]) {
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
    [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.layoutAttributes = [[NSMutableArray alloc] init];
    self.contentSize = CGSizeZero;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.layoutAttributes removeAllObjects];
    self.contentSize = CGSizeZero;
    
    id <UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
    id <UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    
    CGPoint origin = CGPointMake(self.sectionInset.left, self.sectionInset.top);
    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:self.collectionView];
    
    for (NSInteger s = 0; s < numberOfSections; s++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:s];
        CGSize size = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){origin, size};
        attributes.zIndex = 0;
        
        [self.layoutAttributes addObject:attributes];
        
        origin.x = CGRectGetMaxX(attributes.frame) + (s == numberOfSections - 1 ? 0 : self.sectionInset.right);
    }
    
    self.contentSize = CGSizeMake(origin.x, CGRectGetHeight(self.collectionView.frame));
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}
 
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutAttributes[indexPath.section];
}
 
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;

    UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];

    UIEdgeInsets inset = self.collectionView.contentInset;
    CGRect bounds = self.collectionView.bounds;
    CGPoint contentOffset = self.collectionView.contentOffset;
    contentOffset.x += inset.left;
    contentOffset.y += inset.top;

    CGSize visibleSize = bounds.size;
    visibleSize.width -= (inset.left + inset.right);

    CGRect visibleFrame = (CGRect){contentOffset, visibleSize};

    CGSize size = [delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
    //核心代码
    CGFloat originX = MAX(CGRectGetMinX(itemAttributes.frame), MIN(CGRectGetMaxX(itemAttributes.frame) - size.width, CGRectGetMaxX(visibleFrame) - size.width));

    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];

    attributes.zIndex = 1;
    attributes.frame = (CGRect){{originX, CGRectGetMinY(itemAttributes.frame)}, size};

    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *arrays = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attributes in self.layoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [arrays addObject:attributes];
        }
    }

    NSMutableArray *answer = [NSMutableArray array];

    for (UICollectionViewLayoutAttributes *attributes in arrays) {
        [answer addObject:attributes];
        UICollectionViewLayoutAttributes *supplementaryAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:attributes.indexPath];
        [answer addObject:supplementaryAttributes];
    }

    return answer;
}

@end
