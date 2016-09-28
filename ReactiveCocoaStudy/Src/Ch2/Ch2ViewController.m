//
//  Ch1ViewController.m
//  ReactiveCocoaStudy
//
//  Created by Anson Ng on 9/27/16.
//  Copyright © 2016 Yahoo! Inc. All rights reserved.
//

#import "Ch2ViewController.h"
#import <ReactiveCocoa.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Ch2DetailViewController.h"
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


    //NOTE: NON bind value
    //    [[[[[self.textField.rac_textSignal
    //         filter:^BOOL(NSString * input) {
    //             return input.length >= 2;
    //         }] throttle:0.6f
    //        ] flattenMap:^RACStream *(NSString *value) {
    //        return [self signalForQuery:value];
    //    }] deliverOn:[RACScheduler mainThreadScheduler]]  //update UI need on main thread
    //     subscribeNext:^(id input) {
    //         self.data = [input valueForKeyPath:@"query.results.product"];
    //         NSLog(@"input:%@", input); //will change to api response
    //         [self.collectionView reloadData];
    //     }];

    ///NOTE: Bind data to update
    [[[[self.textField.rac_textSignal
        filter:^BOOL(NSString * input) {
            return input.length >= 2;
        }] throttle:0.6f
       ] flattenMap:^RACStream *(NSString *value) {
        return [self signalForQuery:value];
    }]
     subscribeNext:^(id input) {
         self.data = [input valueForKeyPath:@"query.results.product"];
         NSLog(@"input:%@", input); //will change to api response
         //[self.collectionView reloadData]; //DELETE for data as signal
     }];

    //data as signal
    RACSignal *dataSignal = [self rac_valuesForKeyPath:@"data" observer:self];
    [[dataSignal deliverOnMainThread ]subscribeNext:^(id x) {
        //update ui in main thread
        [self.collectionView reloadData];
    }];


    RACSignal *didSelectedSignal = [[self rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:) fromProtocol:@protocol(UICollectionViewDelegate)]
                                    map:^id(RACTuple *racTuple) {
                                        NSLog(@"racTuple:%@", racTuple.second);
                                        return racTuple.second;
                                    }];

    [didSelectedSignal subscribeNext:^(NSIndexPath *indexPath) {
        ListingCollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        Ch2DetailViewController *detailViewController = [[Ch2DetailViewController alloc] init];
        detailViewController.image = cell.imageView.image;
        NSDictionary *data = self.data[indexPath.row];
        detailViewController.title = data[@"title"];
        detailViewController.price = [NSString stringWithFormat:@"$%@", data[@"currentPrice"]];

        [self rac_liftSelector:@selector(presentViewController:animated:completion:) withSignalsFromArray:@[

                                                                                                   [RACSignal return:detailViewController],

                                                                                                   [RACSignal return:@YES],[RACSignal return:nil],

                                                                                                   ]
         ];
    }] ;
    // Do any additional setup after loading the view from its nib.n
}
- (void)setupCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:ListingCollectionViewCellIdentifer bundle:nil] forCellWithReuseIdentifier:ListingCollectionViewCellIdentifer];

}
#pragma mark - reactive cocoa
- (RACSignal *)signalForQuery:(NSString *)query
{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *q = [[NSString stringWithFormat:@"SELECT * FROM ecsearch.std.search (0, 10) WHERE keyword=\"%@\" and property=\"auction\" and sortBy=\"price\" and sortOrder=\"asc\"", query] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

        NSString *urlString = [NSString stringWithFormat:@"https://auction.yql.yahoo.com/v1/public/yql?q=%@&format=json", q];

        NSURL *url = [NSURL URLWithString:urlString];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

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
    }] retry:5];
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
    NSDictionary *data = self.data[indexPath.row];
    if (data[@"image"][0][@"image"][0][@"url"]) {
        NSString *imageUrl = data[@"image"][0][@"image"][0][@"url"];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Image_NO_Image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                cell.imageView.image = image;
            }
        }];
    }
    cell.titleLabel.text = data[@"title"];
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
