//
//  LAVLoginVC.h
//  LAVPlayer
//
//  Created by Andrew Lebedev on 19.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKSdk.h"

@interface LAVLoginVC : UIViewController <VKSdkDelegate>

@property (nonatomic, weak, readwrite) IBOutlet UIButton *buttonLogin;



- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError;
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken;
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken;
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller;
- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token;
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError;
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;



@end
