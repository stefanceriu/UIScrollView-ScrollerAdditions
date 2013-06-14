//
//  SCViewController.m
//  UIScrollView+ScrollerAdditions
//
//  Created by Stefan Ceriu on 14/06/2013.
//  Copyright (c) 2013 Stefan Ceriu. All rights reserved.
//

#import "SCViewController.h"
#import "UIScrollView+ScrollerAdditions.h"

@interface SCViewController () <UICollectionViewDataSource>

@property (nonatomic, strong) IBOutletCollection(UICollectionView) NSArray *collectionViews;

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for(UICollectionView *collectionView in self.collectionViews) {
        [collectionView registerNib:[UINib nibWithNibName:@"SCCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SCCollectionViewCell"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for(UICollectionView *collectionView in self.collectionViews) {
        [collectionView setVerticalScrollerTintColor:[UIColor redColor]];
        [collectionView setHorizontalScrollerTintColor:[UIColor blueColor]];
        [collectionView setAlwaysShowScrollIndicators:YES];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"SCCollectionViewCell" forIndexPath:indexPath];
}

@end
