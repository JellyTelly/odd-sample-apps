//
//  CollectionInfoVideoTableViewController.m
//  tvOSSampleApp_ObjC
//
//  Created by Patrick McConnell on 2/18/16.
//  Copyright © 2016 Patrick McConnell. All rights reserved.
//

#import "CollectionInfoVideoTableViewController.h"
#import "OddSDKtvOS/OddSDKtvOS.h"
#import <AVKit/AVKit.h>

@interface CollectionInfoVideoTableViewController ()

@end

@implementation CollectionInfoVideoTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.videos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
  
  OddVideo* currentVideo = self.videos[indexPath.row];
  
  cell.textLabel.text = currentVideo.title;
  
  return cell;
}


//override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  OddVideo* currentVideo = self.videos[indexPath.row];
  
  AVPlayerViewController* playerVC = [[AVPlayerViewController alloc]init];
  
  if (currentVideo.urlString != nil) {
    NSURL* videoURL = [[NSURL alloc]initWithString:currentVideo.urlString];
    AVPlayerItem* mediaItem = [[AVPlayerItem alloc]initWithURL:videoURL];
    AVPlayer* player = [[AVPlayer alloc]initWithPlayerItem:mediaItem];
    [playerVC setPlayer:player];
    [playerVC.player play];
    [self presentViewController:playerVC animated:YES completion:^{
    }];
  }
  
  
}

@end
