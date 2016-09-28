//
//  ListingCollectionViewCell.h
//  ReactiveCocoaStudy
//
//  Created by Anson Ng on 9/28/16.
//  Copyright © 2016 Yahoo! Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
static const NSString *ListingCollectionViewCellIdentifer = @"ListingCollectionViewCell";
@interface ListingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
