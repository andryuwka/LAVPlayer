//
//  LAVMyMusicTVC.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 19.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "LAVMyMusicTVC.h"
#import "VKSdk.h"
#import "LAVAudioReqResult.h"
#import "LAVMusicPlayerVC.h"

@interface LAVMyMusicTVC ()

@property(nonatomic) NSUInteger selectedTrack;

@end

@implementation LAVMyMusicTVC

- (void)viewDidLoad {
  [super viewDidLoad];

  [self getAudios];
    
}

- (void)getAudios {
  VKRequest *audioReq = [VKRequest requestWithMethod:@"audio.get"
                                       andParameters:@{
                                         VK_API_OWNER_ID : @"8080618"
                                       }
                                       andHttpMethod:@"GET"];

  [audioReq executeWithResultBlock:^(VKResponse *response) {
    // NSLog(@"Json result: %@", response.json);

    NSArray *items = response.json[@"items"];
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < [items count]; ++i) {
      NSDictionary *current = items[i];

      LAVAudioReqResult *temp =
          [[LAVAudioReqResult alloc] initWithArtist:current[@"artist"]
                                               date:current[@"date"]
                                           duration:current[@"duration"]
                                           genre_id:current[@"genre_id"]
                                           audio_id:current[@"id"]
                                          lyrics_id:current[@"lyrics_id"]
                                           owner_id:current[@"owner_id"]
                                              title:current[@"title"]
                                                url:current[@"url"]];
      [list addObject:temp];
    }
    self.trackList = list;

  } errorBlock:^(NSError *error) {
    if (error.code != VK_API_ERROR) {
      [error.vkError.request repeat];
    } else {
      NSLog(@"VK error: %@", error);
    }
  }];
}

- (void)setTrackList:(NSArray *)trackList {
  _trackList = trackList;
    [LAVAudioPlayer sharedInstance].trackList = self.trackList;
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

  return [self.trackList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *identifier = @"Cell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:identifier];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:identifier];
  }

  NSArray *list = self.trackList;
  LAVAudioReqResult *current = list[indexPath.row];
  cell.textLabel.text =
      [NSString stringWithFormat:@"%@ - %@", current.artist, current.title];

  return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  self.selectedTrack = indexPath.row;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:@"TO_PLAYER" sender:self];
  });
  [LAVAudioPlayer sharedInstance].currentTrack =
      self.trackList[self.selectedTrack];
  [LAVAudioPlayer sharedInstance].currentTrackIndex = indexPath.row;
    NSLog(@"%ld", [LAVAudioPlayer sharedInstance].currentTrackIndex);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"TO_PLAYER"]) {
    //LAVMusicPlayerVC *vc = [segue destinationViewController];
      
  }
}

@end
