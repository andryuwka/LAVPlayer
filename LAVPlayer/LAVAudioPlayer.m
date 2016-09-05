//
//  LAVAudioPlayer.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 20.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "LAVAudioPlayer.h"

enum LAVAudioPlayerState {
  LAVAudioPlayerStateDefault,
  LAVAudioPlayerStateRepeatAll,
  LAVAudioPlayerStateRepeatOne
};

typedef enum LAVAudioPlayerState LAVAudioPlayerState;

@implementation LAVAudioPlayer

- (id)init {
  self = [super init];
  if (self) {
    self.playing = false;
    self.shuffle = false;
  }

  return self;
}

+ (LAVAudioPlayer *)sharedInstance {
  static LAVAudioPlayer *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[LAVAudioPlayer alloc] init];
    instance.player = [[AVPlayer alloc] init];
  });

  return instance;
}

- (LAVAudioReqResult *)getNextTrack {
  NSInteger index;
  if (!self.isShuffle) {
    if (self.currentTrackIndex == ([self.trackList count] - 1)) {
      self.currentTrackIndex = 0;
      index = self.currentTrackIndex;
    } else {
      index = ++self.currentTrackIndex;
    }
  } else {
    index = arc4random() % [self.trackList count];
  }
  // NSLog(@"currentIndex = %ld", (long)self.currentTrackIndex);
  self.currentTrack = self.trackList[index];
  return self.trackList[index];
}

- (LAVAudioReqResult *)getPrevTrack {
  NSInteger index;
  if (!self.isShuffle) {
    if (self.currentTrackIndex != 0) {
      index = --self.currentTrackIndex;
    } else {
      self.currentTrackIndex = [self.trackList count];
      index = --self.currentTrackIndex;
    }
  } else {
    index = arc4random() % [self.trackList count];
  }
  NSLog(@"currentIndex = %ld", (long)self.currentTrackIndex);
  self.currentTrack = self.trackList[index];
  return self.trackList[index];
}

- (BOOL)isShuffle {
  return self.shuffle;
}

- (NSArray *)getAudios {
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
  return self.trackList;
}

- (void)playWithURL:(NSURL *)url {
  self.player = [[AVPlayer alloc] initWithURL:url];
}

- (void)playAudio {
  [self.player play];
  self.playing = YES;
}

- (void)pauseAudio {
  [self.player pause];
  self.playing = NO;
}

- (void)setNextTrack {
}

- (BOOL)isPlaying {
  return self.playing;
}

- (NSString *)timeFormat:(float)value {

  float minutes = floor(lroundf(value) / 60);
  float seconds = lroundf(value) - (minutes * 60);

  NSInteger roundedSeconds = lroundf(seconds);
  NSInteger roundedMinutes = lroundf(minutes);

  NSString *time = [[NSString alloc]
      initWithFormat:@"%ld:%02ld", roundedMinutes, roundedSeconds];
  return time;
}

- (void)setCurrentAudioTime:(float)value {
  CMTime newTime = CMTimeMakeWithSeconds(value, 1000);
  [self.player seekToTime:newTime
          toleranceBefore:kCMTimeZero
           toleranceAfter:kCMTimeZero];
}

- (float)getCurrentAudioTime {
  return CMTimeGetSeconds(self.player.currentItem.currentTime);
}

- (float)getAudioDuration {
  return CMTimeGetSeconds(self.player.currentItem.asset.duration);
}

@end
