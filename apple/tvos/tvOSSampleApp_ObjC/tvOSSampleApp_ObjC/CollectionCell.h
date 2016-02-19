//
//  CollectionCell.h
//  tvOSSampleApp_ObjC
//
//  Created by Patrick McConnell on 2/18/16.
//  Copyright © 2016 Patrick McConnell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OddSDKtvOS/OddSDKtvOS.h"

@interface CollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


- (void) configureWithCollection: (OddMediaObjectCollection*) collection;
@end
