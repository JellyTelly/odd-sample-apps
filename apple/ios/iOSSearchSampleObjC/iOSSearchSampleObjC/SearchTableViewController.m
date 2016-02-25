//
//  SearchTableViewController.m
//  iOSSearchSampleObjC
//
//  Created by Patrick McConnell on 2/25/16.
//  Copyright © 2016 Oddnetworks. All rights reserved.
//

/***
 
 A simple application to show how to use the Oddnetworks SDK to search through
 your catalog of media objects.
 
 ***/

#import "SearchTableViewController.h"
#import "OddSDK/OddSDK.h"

@interface SearchTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property NSArray* videoResults;
@property NSArray* collectionResults;
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.videoResults = [[NSArray alloc]init];
  self.collectionResults = [[NSArray alloc]init];
  
  [self configureSDK];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // one section for videos and one for collections
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // we will show "no results" if the results array is empty
  // so we always want at least one cell
  if (section == 0) {
    return self.videoResults.count == 0 ? 1 : self.videoResults.count;
  } else {
    return self.collectionResults.count == 0 ? 1 : self.collectionResults.count;
  }
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"resultCell" forIndexPath:indexPath];
 
   OddMediaObject* currentMediaObject;
   NSString* mediaObjectType = @"OddVideo";
   
   if ( indexPath.section == 0 && self.videoResults.count > 0 ) {
     // videos
     currentMediaObject = self.videoResults[indexPath.row];
   } else if (self.collectionResults.count > 0) {
     // collections
     currentMediaObject = self.collectionResults[indexPath.row];
     mediaObjectType = @"OddMediaObjectCollection";
   }
   
   if (currentMediaObject != nil) {
     // there are results for this object type...
     [cell.textLabel setText:  currentMediaObject.title];
     [cell.detailTextLabel setText: mediaObjectType];
   } else {
     /// no results...
     [cell.textLabel setText: @"No Search Results"];
     [cell.detailTextLabel setText: @""];
   }

 return cell;
 }

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return section == 0 ? @"Videos" : @"Collections";
}

#pragma mark - Helpers

// Setup the SDK to commuicate with our Oddworks account
  - (void)configureSDK {
  // Setting the log level to .Info provides additional information from the OddContentStore
  // The OddLogger has 3 levels: .Info, .Warning and .Error. The default is .Error
  //    OddLogger.logLevel = .Info
  
  /* Please visit https://www.oddnetworks.com/getstarted/ to get the demo app authentication token
   this line is required to allow access to the API. Once you have entered your authToken uncomment
   to continue
   OddContentStore.sharedStore.API.authToken = <insert your authToken here>
   */
  
  // if your app is doing more than just searching you will want to initialize
  // the content store. In this sample we do not need to do so. Since all searches
  // are performed on the server we will not require a local copy of any of our
  // media objects. Any objects returned by a search will be added to the local store
  // for future use
//    [[OddContentStore sharedStore]initialize];
}

#pragma mark - Search


- (void)fetchSearchResults:(NSString*) term {
  [[OddContentStore sharedStore]searchForTerm: term onResults:^(NSArray<OddVideo *> * videos, NSArray<OddMediaObjectCollection *> * collections) {
    NSLog(@"Search found %ld videos and %ld collections for the term: '%@'", videos.count, collections.count, term);
    [self displaySearchResultsWithVideos:videos andCollections:collections];
  }];
}

// if no results are found clear any old data and redraw the tableview
// to indicate "no results"
- (void) resetSearchTable {
  self.videoResults = [[NSArray alloc]init];
  self.collectionResults = [[NSArray alloc]init];
  [self.tableView reloadData];
}

//func displaySearchResults(var videos: Array<OddVideo>?, var collections: Array<OddMediaObjectCollection>?) {
- (void) displaySearchResultsWithVideos:(NSArray *) videos andCollections:(NSArray*) collections {

  self.videoResults = videos != nil ? videos : [[NSArray alloc]init];
  self.collectionResults = collections != nil ? collections : [[NSArray alloc]init];

  dispatch_async(dispatch_get_main_queue(), ^{
    [[self tableView] reloadData];
  });
}


// MARK: - UITextFieldDelegate

// we are the delegate for the text field in the navigation bar
// this method will be called when the 'search' key is pressed on the keyboard
// initiating a search
//func textFieldShouldReturn(textField: UITextField) -> Bool {
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if ([textField.text length] != 0  ) {
    NSString* query = [textField.text stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"Searching for: %@", query);
    [self fetchSearchResults: query];
  } else {
    [self resetSearchTable];
  }
  
  [textField resignFirstResponder];
  
  return true;
}



@end
