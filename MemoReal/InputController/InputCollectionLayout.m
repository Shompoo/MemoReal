//
//  InputCollectionLayout.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 30/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "InputCollectionLayout.h"

enum {
    nameField = 0,
    memoField,
    tagField,
    buttonField
};

static NSString * const InputCell = @"InputCell";

@interface InputCollectionLayout()


@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize name0;
@property (nonatomic) CGSize memo1;
@property (nonatomic) CGSize tag2;
@property (nonatomic) CGSize button3;




@end

@implementation InputCollectionLayout

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
   
    self.itemInsets = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    self.numberOfColumns = 1;
    self.spacingY = 20.0f;
    self.interItemSpacingY = 0.0f;
    
}

#pragma mark - Layout

- (void)prepareLayout
{
    self.name0 = CGSizeMake(310.0f, 38.0f);
    self.memo1 = CGSizeMake(310.0f, 150.0f);
    self.tag2 = CGSizeMake(310.0f, 44.0f);
    self.button3 = CGSizeMake(100.0f, 100.0f);;
    
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;  //= [NSIndexPath indexPathForItem:0 inSection:0];
    
    
    for (NSInteger section = 0; section < sectionCount; section++) { 
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) { 
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            itemAttributes.frame = [self frameForItemAtIndexPath:indexPath];  
            
            cellLayoutInfo[indexPath] = itemAttributes;
            
        }
    }
    
    newLayoutInfo[InputCell] = cellLayoutInfo;
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
            originX = 5.0f;
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
            self.itemSize = self.name0;
            //originY = floor(self.itemInsets.top + (self.itemSize.height + self.interItemSpacingY) * row);
            originY = 5.0f;
            break;
        }
        case 1:
        {
            self.itemSize = self.memo1;
            originY = floor(6.0f+ (self.name0.height + self.interItemSpacingY) * row) ;
            break;
        }
        case 2:
        {
            self.itemSize = self.tag2;
            originY = (20.0f + self.itemInsets.top + self.name0.height + self.memo1.height + (self.interItemSpacingY));
            break;
        }
        case 3:
        {
            self.itemSize = self.button3;
            originY = (self.itemInsets.top + self.name0.height + self.memo1.height + self.tag2.height + (self.interItemSpacingY*2));
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
    return self.layoutInfo[InputCell][indexPath];
}

- (CGSize)collectionViewContentSize
{
    NSInteger rowCount = [self.collectionView numberOfSections] / self.numberOfColumns;
    
    if ([self.collectionView numberOfSections] % self.numberOfColumns) rowCount++;
    
    CGFloat height = self.itemInsets.top + self.name0.height + self.memo1.height + self.tag2.height + self.button3.height
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