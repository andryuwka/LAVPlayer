//
//  LAVAudioPlayer.h
//  LAVPlayer
//
//  Created by Andrew Lebedev on 20.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LAVAudioReqResult.h"
#import "VKSdk.h"

@interface LAVAudioPlayer : NSObject

@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong, readwrite) LAVAudioReqResult *currentTrack;
@property (nonatomic, weak, readwrite) NSArray *trackList;

@property (nonatomic, assign) NSInteger currentTrackIndex;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL shuffle;



+ (LAVAudioPlayer *)sharedInstance;

- (NSArray *)getAudios;
- (LAVAudioReqResult *)getNextTrack;
- (NSString *)timeFormat:(float)value;

- (void)playWithURL:(NSURL *)url;
- (void)playAudio;
- (void)pauseAudio;
- (BOOL)isPlaying;
- (BOOL)isShuffle;

- (void)setNextTrack;


- (void)setCurrentAudioTime:(float)value;
- (float)getCurrentAudioTime;

- (float)getAudioDuration;





@end
