//
//  ViewController.m
//  iOSSampleAppObjC
//
//  Created by Patrick McConnell on 2/9/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//


// A simple iOS Application that demonstrates connecting to the Odd Networks API via an Objective-C iOS App

#import "ViewController.h"
#import "OddSDK/OddSDK.h"

@interface ViewController ()
  @property NSArray* collections;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self configureSDK];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

// MARK: - Helpers

- (void)configureOnContentLoaded {
  
  NSString* contentStoreInfo = [[OddContentStore sharedStore] mediaObjectInfo];
  NSLog(@"%@", contentStoreInfo );
  
  NSArray* featuredCollections = [[OddContentStore sharedStore] featuredCollections];
  
  [self setCollections:featuredCollections];
//  dispatch_async(dispatch_get_main_queue(), ^{
  //      self.collectionView?.reloadData()
//    [self ]
//  })
  
}

- (void)configureSDK {
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(configureOnContentLoaded) name:OddConstants.OddContentStoreCompletedInitialLoadNotification object:nil];
  
  [[[OddContentStore sharedStore]API] setServerMode:OddServerModeBeta];
//  [OddLogger setLogLevel:OddLogLevelInfo];
  
  [[[OddContentStore sharedStore] API] setAuthToken:@"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2ZXJzaW9uIjoxLCJkZXZpY2VJRCI6IjQ1NDc5MjYwLWM1NDItMTFlNS1hN2QzLWI5YzYxY2MyZDU1MiIsInNjb3BlIjpbImRldmljZSJdLCJpYXQiOjE0NTM5MzI0MTJ9.DWh9Y6baI6I2ThAxX5zgnHsiV7kQmWJhZXgkw42RKtU"];
  
  [[OddContentStore sharedStore] setOrganizationId:@"nasa.gov"];
  [[OddContentStore sharedStore] initialize];
}

@end
