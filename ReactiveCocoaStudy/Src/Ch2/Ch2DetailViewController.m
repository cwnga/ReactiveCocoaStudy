//
//  Ch2DetailViewController.m
//  ReactiveCocoaStudy
//
//  Created by Anson Ng on 9/28/16.
//  Copyright © 2016 Yahoo! Inc. All rights reserved.
//

#import "Ch2DetailViewController.h"
#import <ReactiveCocoa.h>
@interface Ch2DetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *dissmissButton;

@end

@implementation Ch2DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    self.titleLabel.text = self.title;
    self.priceLabale.text = self.price;

    [[self.dissmissButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self rac_liftSelector:@selector(dismissViewControllerAnimated:completion:) withSignals:[RACSignal return:@YES], [RACSignal return:nil], nil];
    }];
    // Do any additional setup after loading the view from its nib.
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
