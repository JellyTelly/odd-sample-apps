//
//  HomeCollectionViewController.m
//  tvOSSampleApp_ObjC
//
//  Created by Patrick McConnell on 2/18/16.
//  Copyright © 2016 Patrick McConnell. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "OddSDKtvOS/OddSDKtvOS.h"
#import "CollectionCell.h"
#import "CollectionInfoViewController.h"

@interface HomeCollectionViewController ()
@property NSArray* collections;
@end

@implementation HomeCollectionViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self configureSDK];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.collections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
  
  OddMediaObjectCollection* currentCollection = self.collections[indexPath.row];
  
  // call our custom cell class to confgure itself with the collection data
  [cell configureWithCollection: currentCollection];
  
  return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"Selected: %ld", (long)indexPath.row);
// you really want to be sure this is not an index out of bounds
  OddMediaObjectCollection* selectedCollection = self.collections[indexPath.row];
  [self performSegueWithIdentifier:@"showCollectionInfoSegue" sender:selectedCollection];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"showCollectionInfoSegue"]) {
    CollectionInfoViewController* vc = segue.destinationViewController;
    
    if ( [ sender isKindOfClass: [OddMediaObjectCollection class] ] ) {
      vc.collection = (OddMediaObjectCollection*)sender;
    }
  }
}

- (void)configureOnContentLoaded {
  
  NSString* contentStoreInfo = [[OddContentStore sharedStore] mediaObjectInfo];
  NSLog(@"%@", contentStoreInfo );
  
  NSArray* featuredCollections = [[OddContentStore sharedStore] featuredCollections];
  
  [self setCollections:featuredCollections];
  [[self collectionView]reloadData];
}

- (void)configureSDK {
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(configureOnContentLoaded) name:OddConstants.OddContentStoreCompletedInitialLoadNotification object:nil];
  
  [[[OddContentStore sharedStore]API] setServerMode:OddServerModeBeta];

// Setting the log level to .Info provides additional information from the OddContentStore
// The OddLogger has 3 levels: .Info, .Warning and .Error. The default is .Error

//    [OddLogger setLogLevel:OddLogLevelInfo];
  
  /* Please visit https://www.oddnetworks.com/getstarted/ to get the demo app authentication token
   this line is required to allow access to the API. Once you have entered your authToken uncomment
   to continue

  [[[OddContentStore sharedStore] API] setAuthToken: < insert your auth token here> ];
   */
  
  [[OddContentStore sharedStore] initialize];
}




@end
