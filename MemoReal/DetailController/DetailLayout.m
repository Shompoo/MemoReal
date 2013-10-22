//
//  DetailLayout.m
//  MemorealT2
//
//  Created by Treechot Shompoonut on 10/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "DetailLayout.h"


static NSString * const AboutCellKind = @"DETAILCELL";

@interface DetailLayout ()


@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize block0;
@property (nonatomic) CGSize block1;
@property (nonatomic) CGSize block2;
@property (nonatomic) CGSize block3;

@end


@implementation DetailLayout

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.itemInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.numberOfColumns = 1;
    
}

#pragma mark - Layout

- (void)prepareLayout
{
    self.block0 = CGSizeMake(self.collectionView.bounds.size.width, 191.0f);
    self.block1 = CGSizeMake(self.collectionView.bounds.size.width, 202.0f);
    self.block2 = CGSizeMake(self.collectionView.bounds.size.width, 44.0f);
    self.block3 = CGSizeMake(floorf(self.collectionView.bounds.size.width/3), 66.0f);
    self.interItemSpacingY = 0.5f;
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath ;//= [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) { //iterate sectionCount
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) { //iterate item(s) in section
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            itemAttributes.frame = [self frameForItemAtIndexPath:indexPath];  //FrameSet for item /insection at indexPath
            
            cellLayoutInfo[indexPath] = itemAttributes;
            
        }
    }
    
    newLayoutInfo[AboutCellKind] = cellLayoutInfo;
    self.layoutInfo = newLayoutInfo;
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


#pragma mark - Private

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.section / self.numberOfColumns;
    NSInteger item = indexPath.item;
    
    CGFloat originX = 0.0f; ;
    switch (item) {
        case 0:{
            originX = 0.0f;
            break;
        }
        case 1:
        {
            originX = (self.itemInsets.left + self.itemSize.width + 1.0f);
            break;
        }
        case 2:
        {
            originX = (self.itemInsets.left + (self.itemSize.width *2) + 2.0f);
            break;
        }
            
    }
    
    CGFloat originY = 0.0f;
    
    switch (indexPath.section) {
        case 0:
        {
            self.itemSize = self.block0;
            //originY = floor(self.itemInsets.top + (self.itemSize.height + self.interItemSpacingY) * row);
            originY = 0.0f;
            break;
        }
        case 1:
        {
            self.itemSize = self.block1;
            originY = floor(1.0f+ self.itemInsets.top + (self.block0.height + self.interItemSpacingY) * row) ;
            break;
        }
        case 2:
        {
            self.itemSize = self.block2;
            originY = (self.itemInsets.top + self.block0.height + self.block1.height + (self.interItemSpacingY));
            break;
        }
        case 3:
        {
            self.itemSize = self.block3;
            originY = (1.0f + self.itemInsets.top + self.block0.height + self.block1.height + self.block2.height + (self.interItemSpacingY*2));
            break;
        }
            
    }
    
    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[AboutCellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    NSInteger rowCount = [self.collectionView numberOfSections] / self.numberOfColumns;
    
    if ([self.collectionView numberOfSections] % self.numberOfColumns) rowCount++;
    
    CGFloat height = self.itemInsets.top + self.block0.height + self.block1.height + self.block2.height + self.block3.height
    + (self.interItemSpacingY *3)+ self.itemInsets.bottom;
    
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}


#pragma mark - Properties

- (void)setItemInsets:(UIEdgeInsets)itemInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(_itemInsets, itemInsets)) return;
    
    _itemInsets = itemInsets;
    
    [self invalidateLayout];
}

- (void)setItemSize:(CGSize)itemSize
{
    if (CGSizeEqualToSize(_itemSize, itemSize)) return;
    
    _itemSize = itemSize;
    
    [self invalidateLayout];
}

- (void)setInterItemSpacingY:(CGFloat)interItemSpacingY
{
    if (_interItemSpacingY == interItemSpacingY) return;
    
    _interItemSpacingY = interItemSpacingY;
    
    [self invalidateLayout];
}

- (void)setNumberOfColumns:(NSInteger)numberOfColumns
{
    if (_numberOfColumns == numberOfColumns) return;
    
    _numberOfColumns = numberOfColumns;
    
    [self invalidateLayout];
    
}


@end
