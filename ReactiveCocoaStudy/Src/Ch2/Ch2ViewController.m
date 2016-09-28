//
//  Ch1ViewController.m
//  ReactiveCocoaStudy
//
//  Created by Anson Ng on 9/27/16.
//  Copyright © 2016 Yahoo! Inc. All rights reserved.
//

#import "Ch2ViewController.h"
#import <ReactiveCocoa.h>
#import "ListingCollectionViewCell.h"

@interface Ch2ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *data;

@end

@implementation Ch2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;



    [[[[[self.textField.rac_textSignal
         filter:^BOOL(NSString * input) {
             return input.length >= 2;
         }] throttle:0.6f
        ] flattenMap:^RACStream *(NSString *value) {
        return [self signalForQuery:value];
    }] deliverOn:[RACScheduler mainThreadScheduler]]  //update UI need on main thread
     subscribeNext:^(id input) {
        self.data = [input valueForKeyPath:@"query.results.product"];
        NSLog(@"input:%@", input); //will change to api response
        [self.collectionView reloadData];
    }];

    [[self rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:) fromProtocol:@protocol(UICollectionViewDelegate)] subscribeNext:^(RACTuple *racTuple) {
        NSLog(@"racTuple:%@", racTuple.second);

    }];
    // Do any additional setup after loading the view from its nib.
}
- (void)setupCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:ListingCollectionViewCellIdentifer bundle:nil] forCellWithReuseIdentifier:ListingCollectionViewCellIdentifer];

}
#pragma mark - reactive cocoa
- (RACSignal *)signalForQuery:(NSString *)query
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *q = [[NSString stringWithFormat:@"SELECT * FROM ecsearch.std.search (0, 10) WHERE keyword=\"%@\" and property=\"auction\" and sortBy=\"price\" and sortOrder=\"asc\"", query] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

        NSString *urlString = [NSString stringWithFormat:@"https://auction.yql.yahoo.com/v1/public/yql?q=%@&format=json", q];

        NSURL *url = [NSURL URLWithString:urlString];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"data:%@", data);
            NSLog(@"response:%@", response);
            NSLog(@"error:%@", error);

            if (error) {
                [subscriber sendError:error];
            } else {
                NSError *jsonError;
                id json= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    [subscriber sendError:jsonError];
                } else {
                    [subscriber sendNext:json];
                }
            }
            [subscriber sendCompleted];


        }];
        [dataTask resume];

        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
    return signal;

}

#pragma mark - collectionview

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.data.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListingCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:ListingCollectionViewCellIdentifer forIndexPath:indexPath];
    cell.titleLabel.text = @"hihi";
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"call");
//    NSString *className = [self.data[indexPath.item] valueForKey:@"className"];
//    UIViewController *vc = [[NSClassFromString(className) alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.bounds.size.width, 300.0f);
}

@end
