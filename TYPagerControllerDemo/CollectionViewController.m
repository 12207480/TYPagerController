//
//  CollectionViewController.m
//  TYPagerControllerDemo
//
//  Created by tany on 16/5/17.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "CollectionViewController.h"

@interface CollectionViewController ()<UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *collectionView;
@end

static NSString *const cellId = @"collectCellId";

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addCollectionView];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear index %@",_text);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewDidAppear index %@",_text);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear index %@",_text);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewDidDisappear index %@",_text);
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _collectionView.frame = self.view.bounds;
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((CGRectGetWidth(self.view.frame)-20)/3, (CGRectGetWidth(self.view.frame)-20)/3);
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
}

#pragma mark - UIViewControllerDisplayViewDelegate

- (UIScrollView *)displayView
{
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3*3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
