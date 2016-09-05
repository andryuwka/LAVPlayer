//
//  LAVMusicPlayerVC.h
//  LAVPlayer
//
//  Created by Andrew Lebedev on 20.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "LAVAudioPlayer.h"
#import "LAVAudioReqResult.h"
#import "LAVButtonsView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

@interface LAVMusicPlayerVC : UIViewController

@property(nonatomic, weak, readwrite) IBOutlet UIImageView *imgView;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonPrev;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonPlay;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonNext;
@property(nonatomic, weak, readwrite) IBOutlet UISlider *sliderTrack;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelElapsedTime;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelLeftTime;
@property(nonatomic, weak, readwrite) IBOutlet UISlider *sliderVolume;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelArtist;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelTitleMusic;

@property(nonatomic, strong, readwrite) MPMusicPlayerController *musicPlayer;

@property(nonatomic, strong, readwrite) LAVAudioReqResult *track;
@property(nonatomic, strong, readwrite) LAVAudioPlayer *playController;

@property CMTime currentTime;
@property CMTime duration;
@property AVURLAsset *asset;

@end
