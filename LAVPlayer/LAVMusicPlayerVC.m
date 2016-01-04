//
//  LAVMusicPlayerVC.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 20.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "LAVMusicPlayerVC.h"

@interface LAVMusicPlayerVC () {
  UIImage *imagePlay;
  UIImage *imagePause;
  UIImage *imageNext;
  UIImage *imagePrev;
  id<NSObject> _timeObserverToken;
}

@end

@implementation LAVMusicPlayerVC

- (void)viewDidLoad {
  [super viewDidLoad];
  self.playController = [LAVAudioPlayer sharedInstance];

  NSString *artist = [LAVAudioPlayer sharedInstance].currentTrack.artist;
  NSString *title = [LAVAudioPlayer sharedInstance].currentTrack.title;
  [self.labelTitle
      setText:[NSString stringWithFormat:@"%@ - %@", artist, title]];

  [self addObserver:self
         forKeyPath:@"asset"
            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
            context:nil];

  [self addObserver:self
         forKeyPath:@"playController.player.currentItem.duration"
            options:NSKeyValueObservingOptionNew |
                    NSKeyValueObservingOptionInitial
            context:nil];

  [self addObserver:self
         forKeyPath:@"playController.player.currentItem.status"
            options:NSKeyValueObservingOptionNew |
                    NSKeyValueObservingOptionInitial
            context:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(itemDidFinishPlaying:)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:self.playController.player.currentItem];

  LAVMusicPlayerVC __weak *weakSelf = self;
  _timeObserverToken = [self.playController.player
      addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                   queue:dispatch_get_main_queue()
                              usingBlock:^(CMTime time) {
                                weakSelf.sliderTrack.value =
                                    CMTimeGetSeconds(time);
                                weakSelf.labelElapsedTime.text = [NSString
                                    stringWithFormat:
                                        @"%@",
                                        [weakSelf.playController
                                            timeFormat:
                                                [weakSelf.playController
                                                        getCurrentAudioTime]]];
                                weakSelf.labelLeftTime.text = [NSString
                                    stringWithFormat:
                                        @"-%@",
                                        [weakSelf.playController
                                            timeFormat:
                                                [weakSelf.playController
                                                        getAudioDuration] -
                                                [weakSelf.playController
                                                        getCurrentAudioTime]]];
                              }];

  NSURL *url =
      [NSURL URLWithString:[LAVAudioPlayer sharedInstance].currentTrack.url];
  self.asset = [AVURLAsset assetWithURL:url];

  [self prepareViews];
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
  [self.playController setCurrentAudioTime:kCMTimeZero.value];
  [self.playController playAudio];
}

- (void)refreshLabels {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.labelElapsedTime.text = @"0:00";
    self.labelLeftTime.text = @"-0:00";
  });
}

- (void)prepareViews {
  [self.buttonPlay setTitle:@"" forState:UIControlStateNormal];
  [self.buttonPrev setTitle:@"" forState:UIControlStateNormal];
  [self.buttonNext setTitle:@"" forState:UIControlStateNormal];

  [self refreshLabels];

  imagePlay = [UIImage imageNamed:@"play"];
  imagePause = [UIImage imageNamed:@"pause"];
  imageNext = [UIImage imageNamed:@"end"];
  imagePrev = [UIImage imageNamed:@"skip_to_start"];

  [self.buttonPlay setImage:imagePlay forState:UIControlStateNormal];
  [self.buttonNext setImage:imageNext forState:UIControlStateNormal];
  [self.buttonPrev setImage:imagePrev forState:UIControlStateNormal];
  [self.imgView setImage:[UIImage imageNamed:@"background"]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

  if (context) {
    // KVO isn't for us.
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
    return;
  }

  if ([keyPath isEqualToString:@"asset"]) {
    if (self.asset) {
      NSLog(@"asynchronouslyLoadURLAsset");
      [self pause];
      [self refreshLabels];
      [self asynchronouslyLoadURLAsset:self.asset];
    }
  } else if ([keyPath isEqualToString:
                          @"playController.player.currentItem.duration"]) {

    NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
    CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]]
                             ? newDurationAsValue.CMTimeValue
                             : kCMTimeZero;
    BOOL hasValidDuration =
        CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
    double newDurationSeconds =
        hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;

    self.sliderTrack.maximumValue = newDurationSeconds;
    self.sliderTrack.value =
        hasValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
    self.buttonPrev.enabled = hasValidDuration;
    self.buttonPlay.enabled = hasValidDuration;
    self.buttonNext.enabled = hasValidDuration;
    self.sliderTrack.enabled = hasValidDuration;
    self.labelElapsedTime.enabled = hasValidDuration;
    self.labelLeftTime.enabled = hasValidDuration;

    self.labelElapsedTime.text = [NSString
        stringWithFormat:
            @"%@", [self.playController
                       timeFormat:[self.playController getCurrentAudioTime]]];
    self.labelLeftTime.text = [NSString
        stringWithFormat:
            @"-%@", [self.playController
                        timeFormat:[self.playController getAudioDuration] -
                                   [self.playController getCurrentAudioTime]]];

  } else if ([keyPath
                 isEqualToString:@"playController.player.currentItem.status"]) {

    NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];

    AVPlayerItemStatus newStatus =
        [newStatusAsNumber isKindOfClass:[NSNumber class]]
            ? newStatusAsNumber.integerValue
            : AVPlayerItemStatusUnknown;

    if (newStatus == AVPlayerItemStatusFailed) {
      [self
          handleErrorWithMessage:self.playController.player.currentItem.error
                                     .localizedDescription
                           error:self.playController.player.currentItem.error];
    }

  } else {
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
  }
}

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {

  [newAsset
      loadValuesAsynchronouslyForKeys:LAVMusicPlayerVC.assetKeysRequiredToPlay
                    completionHandler:^{
                      dispatch_async(dispatch_get_main_queue(), ^{
                        if (newAsset != self.asset) {
                          NSLog(@"newAsset != self.asset");
                          return;
                        }
                        for (NSString *key in self
                                 .class.assetKeysRequiredToPlay) {
                          NSError *error = nil;
                          if ([newAsset statusOfValueForKey:key error:&error] ==
                              AVKeyValueStatusFailed) {

                            NSString *message = [NSString
                                localizedStringWithFormat:
                                    NSLocalizedString(@"error.asset_key_%@_"
                                                      @"failed.description",
                                                      @"Can't use this AVAsset "
                                                      @"because one of it's "
                                                      @"keys failed to load"),
                                    key];

                            [self handleErrorWithMessage:message error:error];
                            // NSLog(@"handleErrorWithMessage");
                            return;
                          }
                        }

                        if (!newAsset.playable ||
                            newAsset.hasProtectedContent) {
                          NSString *message = NSLocalizedString(
                              @"error.asset_not_playable.description",
                              @"Can't use this AVAsset because it isn't "
                              @"playable or has protected content");

                          [self handleErrorWithMessage:message error:nil];

                          return;
                        }
                        NSLog(@"replaceCurrentItemWithPlayerItem");

                        [self.playController.player
                            replaceCurrentItemWithPlayerItem:
                                [AVPlayerItem playerItemWithAsset:newAsset]];
                      });
                      [self play];
                    }];
}

+ (NSArray *)assetKeysRequiredToPlay {
  return @[ @"playable", @"hasProtectedContent" ];
}

- (void)handleErrorWithMessage:(NSString *)message error:(NSError *)error {
  NSLog(@"Error occured with message: %@, error: %@.", message, error);

  NSString *alertTitle =
      NSLocalizedString(@"alert.error.title", @"Alert title for errors");
  NSString *defaultAlertMesssage =
      NSLocalizedString(@"error.default.description",
                        @"Default error message when no NSError provided");

  UIAlertController *controller = [UIAlertController
      alertControllerWithTitle:alertTitle
                       message:message ?: defaultAlertMesssage
                preferredStyle:UIAlertControllerStyleAlert];

  NSString *alertActionTitle =
      NSLocalizedString(@"alert.error.actions.OK", @"OK on error alert");
  UIAlertAction *action =
      [UIAlertAction actionWithTitle:alertActionTitle
                               style:UIAlertActionStyleDefault
                             handler:nil];
  [controller addAction:action];

  [self presentViewController:controller animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (IBAction)playAudioPressed:(id)sender {
  [self playPause];
}

- (void)pause {
  [self.buttonPlay setImage:imagePlay forState:UIControlStateNormal];
  [self.playController pauseAudio];
}

- (void)play {
  [self.buttonPlay setImage:imagePause forState:UIControlStateNormal];
  [self.playController playAudio];
}

- (void)playPause {
  if (![self.playController isPlaying]) {
    [self play];
  } else {
    [self pause];
  }
}

- (IBAction)buttonNextPressed:(id)sender {

  LAVAudioReqResult *nextTrack = [[LAVAudioPlayer sharedInstance] getNextTrack];
  NSURL *url = [NSURL URLWithString:nextTrack.url];

  NSString *artist = [LAVAudioPlayer sharedInstance].currentTrack.artist;
  NSString *title = [LAVAudioPlayer sharedInstance].currentTrack.title;
  [self.labelTitle
      setText:[NSString stringWithFormat:@"%@ - %@", artist, title]];
  self.asset = [AVURLAsset assetWithURL:url];
}

- (IBAction)buttonPrevPressed:(id)sender {

  LAVAudioReqResult *prevTrack = [[LAVAudioPlayer sharedInstance] getPrevTrack];

  NSURL *url = [NSURL URLWithString:prevTrack.url];
  NSString *artist = [LAVAudioPlayer sharedInstance].currentTrack.artist;
  NSString *title = [LAVAudioPlayer sharedInstance].currentTrack.title;
  [self.labelTitle
      setText:[NSString stringWithFormat:@"%@ - %@", artist, title]];
  self.asset = [AVURLAsset assetWithURL:url];
}

- (void)dealloc {

  if (_timeObserverToken) {
    [self.playController.player removeTimeObserver:_timeObserverToken];
    _timeObserverToken = nil;
  }

  [self removeObserver:self forKeyPath:@"asset" context:nil];
  [self removeObserver:self
            forKeyPath:@"playController.player.currentItem.duration"
               context:nil];
  [self removeObserver:self
            forKeyPath:@"playController.player.currentItem.status"
               context:nil];
}

- (IBAction)setVolume:(id)sender {
  [self.playController.player setVolume:self.sliderVolume.value];
}

- (IBAction)setCurrentAudioTime:(id)sender {
  [self.playController setCurrentAudioTime:self.sliderTrack.value];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
  if ([key isEqualToString:@"duration"]) {
    return [NSSet
        setWithArray:@[ @"playController.player.currentItem.duration" ]];
  } else if ([key isEqualToString:@"currentTime"]) {
    return [NSSet
        setWithArray:@[ @"playController.player.currentItem.currentTime" ]];
  } else {
    return [super keyPathsForValuesAffectingValueForKey:key];
  }
}

@end
