//
//  LAVLoginVC.m
//  LAVPlayer
//
//  Created by Andrew Lebedev on 19.10.15.
//  Copyright © 2015 Andrew Lebedev. All rights reserved.
//

#import "LAVLoginVC.h"

static NSString *const NEXT_SEGUE_ID = @"START_WORKING";
static NSString *const TOKEN_KEY = @"wAyTMOtozF4PdMXpUA1B";
static NSArray *SCOPE = nil;

@interface LAVLoginVC () <UIAlertViewDelegate>

@end

@implementation LAVLoginVC

- (void)viewDidLoad {
  SCOPE = @[ VK_PER_FRIENDS, VK_PER_AUDIO, VK_PER_EMAIL, VK_PER_OFFLINE ];
  [super viewDidLoad];

  [VKSdk initializeWithDelegate:self andAppId:@"5111828"];
  if ([VKSdk wakeUpSession]) {
    [self startWorking];
  }
}

- (void)startWorking {
  [self performSegueWithIdentifier:NEXT_SEGUE_ID sender:self];
}

- (IBAction)authorize:(id)sender {
  [VKSdk authorize:SCOPE revokeAccess:YES];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
  VKCaptchaViewController *vc =
      [VKCaptchaViewController captchaControllerWithError:captchaError];
  [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
  [self authorize:nil];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
  [self startWorking];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
  [self.navigationController.topViewController presentViewController:controller
                                                            animated:YES
                                                          completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
  [self startWorking];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
  /*
    [[[UIAlertView alloc] initWithTitle:nil
                              message:@"Access denied"
                             delegate:self
                    cancelButtonTitle:@"Ok"
                    otherButtonTitles:nil] show];
    */
  NSString *alertTitle =
      NSLocalizedString(@"Login Canceled", @"Login Canceled");
  NSString *defaultAlertMesssage =
      NSLocalizedString(@"Access Denied", @"Access Denied");

  UIAlertController *controller =
      [UIAlertController alertControllerWithTitle:alertTitle
                                          message:defaultAlertMesssage
                                   preferredStyle:UIAlertControllerStyleAlert];

  NSString *alertActionTitle = NSLocalizedString(@"Ok", @"Access Denied");
  UIAlertAction *action =
      [UIAlertAction actionWithTitle:alertActionTitle
                               style:UIAlertActionStyleDefault
                             handler:nil];
  [controller addAction:action];

  [self presentViewController:controller animated:YES completion:nil];
}
/*
- (void)alertView:(UIAlertView *)alertView
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
  [self.navigationController popToRootViewControllerAnimated:YES];
}
 */

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
