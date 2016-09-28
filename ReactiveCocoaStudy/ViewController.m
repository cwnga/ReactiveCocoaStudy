//
//  ViewController.m
//  ReactiveCocoaStudy
//
//  Created by Anson Ng on 9/27/16.
//  Copyright © 2016 Yahoo! Inc. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
static const NSString *ReuseIdentifier = @"CollectionViewCell";
@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *data;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = @[
                  @{
                      @"title" : @"CH1",
                      @"className": @"Ch1ViewController"
                      },
                  @{
                      @"title" : @"CH2",
                      @"className": @"Ch2ViewController"
                      },
                  ];
    [self.collectionView registerNib:[UINib nibWithNibName:ReuseIdentifier bundle:nil] forCellWithReuseIdentifier:ReuseIdentifier];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.data.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = [self.data[indexPath.item] valueForKey:@"title"];
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = [self.data[indexPath.item] valueForKey:@"className"];
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.bounds.size.width, 50.0f);
}

@end
