//
//  Ch2DetailViewController.h
//  ReactiveCocoaStudy
//
//  Created by Anson Ng on 9/28/16.
//  Copyright © 2016 Yahoo! Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ch2DetailViewController : UIViewController
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) UIImage *image;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabale;

@end
