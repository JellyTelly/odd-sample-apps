//
//  CollectionCell.m
//  tvOSSampleApp_ObjC
//
//  Created by Patrick McConnell on 2/18/16.
//  Copyright © 2016 Patrick McConnell. All rights reserved.
//

#import "CollectionCell.h"
#import "tvOSSampleApp_ObjC-Swift.h"

@implementation CollectionCell

- (void) configureWithCollection: (OddMediaObjectCollection*) collection {
  [self.titleLabel setText:collection.title];
  
  [collection thumbnail:^(UIImage* image) {
    if (image != nil) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.thumbnailImageView setImage:image];
      });
    }
  }];
}

- (void) becomeFocusedUsingAnimationCoordinator: (UIFocusAnimationCoordinator*) coordinator {
  [coordinator addCoordinatedAnimations:^{
    [self setTransform: CGAffineTransformMakeScale(1.1, 1.1) ];
    [self.layer setShadowColor: [[UIColor blackColor] CGColor] ];
    [self.layer setShadowOffset: CGSizeMake(10, 10) ];
    [self.layer setShadowOpacity: 0.2 ];
    [self.layer setShadowRadius: 5 ];
  } completion:^{
    
  }];
}

- (void) resignFocusedUsingAnimationCoordinator: (UIFocusAnimationCoordinator*) coordinator {
  [coordinator addCoordinatedAnimations:^{
    [self setTransform: CGAffineTransformIdentity ];
    [self.layer setShadowColor: nil ];
    [self.layer setShadowOffset: CGSizeZero ];
  } completion:^{
    
  }];
}


-(void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
  [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
  
  if ([context nextFocusedView] == nil) { return; }
  
  CollectionCell* nextFocusedView = (CollectionCell*)[context nextFocusedView];
  
  if (nextFocusedView == self) {
    [self becomeFocusedUsingAnimationCoordinator:coordinator];
    [(UIView*)self addParallaxMotionEffects:0.5 panValue:5 ];
  } else {
    [self resignFocusedUsingAnimationCoordinator:coordinator];
    [self setMotionEffects: @[] ];
  }
}




@end
