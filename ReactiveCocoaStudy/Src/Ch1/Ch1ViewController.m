//
//  Ch1ViewController.m
//  ReactiveCocoaStudy
//
//  Created by Anson Ng on 9/27/16.
//  Copyright © 2016 Yahoo! Inc. All rights reserved.
//

#import "Ch1ViewController.h"
#import <ReactiveCocoa.h>

@interface Ch1ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation Ch1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[[[self.textField.rac_textSignal
        filter:^BOOL(NSString * input) {
            return input.length >= 2;
        }] throttle:0.6f
       ] flattenMap:^RACStream *(NSString *value) {
        return [self signalForQuery:value];
    }] subscribeNext:^(id input) {
        NSLog(@"input:%@", input); //will change to api response
    }];

    // Do any additional setup after loading the view from its nib.
}

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


@end
