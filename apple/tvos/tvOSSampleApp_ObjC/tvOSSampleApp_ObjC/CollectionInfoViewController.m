//
//  CollectionInfoViewController.m
//  tvOSSampleApp_ObjC
//
//  Created by Patrick McConnell on 2/18/16.
//  Copyright © 2016 Patrick McConnell. All rights reserved.
//

#import "CollectionInfoViewController.h"
#import "CollectionInfoVideoTableViewController.h"


@interface CollectionInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@end

@implementation CollectionInfoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configureForCollection];
}

//func configureForCollection() {
- (void) configureForCollection {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.titleLabel setText:self.collection.title];
    [self.notesTextView setText: self.collection.notes];
    
    [self.collection thumbnail:^(UIImage* image) {
      if (image != nil) {
        [self.thumbnailImageView setImage:image];
      }
    }];
  });
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"videoTableEmbed"]) {
    CollectionInfoVideoTableViewController* vc = segue.destinationViewController;
    
    [[OddContentStore sharedStore]objectsOfType:OddMediaObjectTypeVideo ids:self.collection.objectIds callback:^(NSArray* objects) {
      if ( objects  != nil ) {
        vc.videos = objects;
      }
    }];
    
  }
}
@end
