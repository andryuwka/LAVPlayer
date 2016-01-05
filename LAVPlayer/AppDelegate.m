//
//  AppDelegate.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 19.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "AppDelegate.h"
#import "VKSdk.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  [VKSdk processOpenURL:url fromApplication:sourceApplication];
  return YES;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // Set AudioSession
  NSError *sessionError = nil;
  [[AVAudioSession sharedInstance] setDelegate:self];
  [[AVAudioSession sharedInstance]
      setCategory:AVAudioSessionCategoryPlayAndRecord
            error:&sessionError];

  /* Pick any one of them */
  // 1. Overriding the output audio route
  // UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
  // AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
  // sizeof(audioRouteOverride), &audioRouteOverride);

  // 2. Changing the default output audio route
  UInt32 doChangeDefaultRoute = 1;
  AudioSessionSetProperty(
      kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
      sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [VKSdk handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
