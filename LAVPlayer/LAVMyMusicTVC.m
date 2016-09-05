//
//  LAVMyMusicTVC.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 19.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "LAVAudioReqResult.h"
#import "LAVMusicPlayerVC.h"
#import "LAVMyMusicTVC.h"
#import "LAVTrackCell.h"
#import "VKSdk.h"

@interface LAVMyMusicTVC ()

@property(nonatomic) NSUInteger selectedTrack;

@end

@implementation LAVMyMusicTVC

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBar.barTintColor = [UIColor redColor];
  self.navigationController.navigationBar.translucent = NO;
  [self.tableView setRowHeight:UITableViewAutomaticDimension];
  [self.tableView registerNib:[UINib nibWithNibName:@"LAVTrackCell" bundle:nil]
       forCellReuseIdentifier:@"Cell"];

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

  }
      errorBlock:^(NSError *error) {
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
  LAVTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                       forIndexPath:indexPath];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  if (!cell) {
    cell = [[LAVTrackCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:identifier];
  }

  NSArray *list = self.trackList;
  LAVAudioReqResult *current = list[indexPath.row];

  [cell setArtist:current.artist title:current.title andUrl:current.url];

  return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  self.selectedTrack = indexPath.row;
  UIViewController *playerVC = [self.storyboard
      instantiateViewControllerWithIdentifier:@"LAVMusicPlayerVC"];
  [self.navigationController pushViewController:playerVC animated:YES];

  [LAVAudioPlayer sharedInstance].currentTrack =
      self.trackList[self.selectedTrack];
  [LAVAudioPlayer sharedInstance].currentTrackIndex = indexPath.row;
  NSLog(@"%ld", (long)[LAVAudioPlayer sharedInstance].currentTrackIndex);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"TO_PLAYER"]) {
    // LAVMusicPlayerVC *vc = [segue destinationViewController];
  }
}

#pragma mark - IBActions
- (IBAction)backButtonClicked:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

@end
