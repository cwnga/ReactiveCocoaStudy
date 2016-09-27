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
    //http://auction.yql.yahoo.com:4080/v1/public/yql?q=SELECT%20*%20FROM%20ecsearch.std.search%20(0%2C%2010)%20WHERE%20keyword%3D%22ipad%22%20and%20property%3D%22auction%22%20and%20sortBy%3D%22price%22%20and%20sortOrder%3D%22asc%22%20&diagnostics=true&format=json
    //    [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    //        NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    //    }];
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
                //                else {
                //                    do {
                //                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                //                        subscriber.sendNext(json)
                //
                //                    }catch let raisedError as NSError {
                //                        subscriber.sendError(raisedError)
                //                    }
                //                }
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
