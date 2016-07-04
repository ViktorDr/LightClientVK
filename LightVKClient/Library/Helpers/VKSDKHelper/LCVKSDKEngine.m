//
//  LCVKSDKEngine.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCDatabaseEngine.h"
#import "LCFriendModel.h"

#import "LCUserDefaultsEngine.h"
#import "LCUserModel.h"
#import "LCVKSDKEngine.h"
#import "NSObject+LCAlertView.h"

static NSString *const VK_APP_ID = @"5530677";
static NSInteger const ATTEMPTS_COUNT = 10;

@implementation LCVKSDKEngine

#pragma mark - Singleton pattern

+ (instancetype)sharedInstance {
    static LCVKSDKEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
      sharedInstance = [[self alloc] init];
      sharedInstance.responseMapper = [[LCVKResponseMapper alloc] init];
    });
    return sharedInstance;
}

- (void)vkOuth {    
    VKSdk *sdkInstance = [VKSdk initializeWithAppId:VK_APP_ID];
    [sdkInstance registerDelegate:self];
    [sdkInstance setUiDelegate:self];
    NSArray *SCOPE = @[ VK_PER_FRIENDS, VK_PER_WALL, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES ];
    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
      if (error) {
          [self showAlertView:error.localizedDescription description:nil];
      }
      if (state == VKAuthorizationAuthorized) {
          NSLog (@"wakeUpSession VKAuthorizationAuthorized");
          [_vkOAuthdelegate getUserInfo];
      } else {
          [VKSdk authorize:SCOPE];
      }
    }];
}

- (void)logout {
    [VKSdk forceLogout];
}


- (void)getUserAndFriendsInfo:(CompletionBlock)completion {
    VKRequest *userReq = [[VKApi users] get:@{ VK_API_FIELDS : @"first_name, last_name, uid, photo_100" }];
    userReq.attempts = ATTEMPTS_COUNT;
    userReq.completeBlock = ^(VKResponse *response) {
      //NSLog (@"Json result: %@", response.json);
      NSArray *responseArray = response.json;
      if (responseArray && responseArray.count > 0) {
          LCUserModel *user = [self.responseMapper getUserInfoResponseMapping:responseArray.firstObject];
          [[LCDatabaseEngine sharedInstance] setCurrentUserWithId:user.userId firstName:user.firstName lastName:user.lastName photoURL:user.photoURL];
          // с расчетом, что будет несколько пользователей
          [[LCUserDefaultsEngine sharedInstance] setCurrentUserId:user.userId];
      }
    };
    VKRequest *friendsReq = [[VKApi friends] get:@{ VK_API_FIELDS : @"user_id, first_name, last_name, uid, photo_100" }];
    friendsReq.attempts = ATTEMPTS_COUNT;
    friendsReq.completeBlock = ^(VKResponse *response) {
     // NSLog (@"Json result: %@", response.json);
      NSArray *friends = [self.responseMapper getFriendsResponseMapping:response.json];
      [self saveFriendsToStorage:friends];
    };
    VKBatchRequest *batch = [[VKBatchRequest alloc] initWithRequests:userReq, friendsReq, nil];

    [batch executeWithResultBlock:^(NSArray *responses) {
      completion (YES, @"");
    }
        errorBlock:^(NSError *error) {
          completion (NO, error.localizedDescription);
        }];
}


- (void)getUserInfo:(CompletionBlock)completion {
    VKRequest *userReq = [[VKApi users] get:@{ VK_API_FIELDS : @"first_name, last_name, uid, photo_100" }];
    userReq.attempts = ATTEMPTS_COUNT;
    [userReq executeWithResultBlock:^(VKResponse *response) {
      //NSLog (@"Json result: %@", response.json);
      NSArray *responseArray = response.json;
      if (responseArray && responseArray.count > 0) {
          LCUserModel *user = [self.responseMapper getUserInfoResponseMapping:responseArray.firstObject];
          [[LCDatabaseEngine sharedInstance] setCurrentUserWithId:user.userId firstName:user.firstName lastName:user.lastName photoURL:user.photoURL];
          // с расчетом, что будет несколько пользователей
          [[LCUserDefaultsEngine sharedInstance] setCurrentUserId:user.userId];
          completion (YES, user);
      }
    }
        errorBlock:^(NSError *error) {
          if (error.code != VK_API_ERROR) {
              [error.vkError.request repeat];
          } else {
              NSLog (@"VK error: %@", error.localizedDescription);
              completion (NO, error.localizedDescription);
          }
        }];
}

- (void)getFriends:(CompletionBlock)completion {
    VKRequest *friendReq = [[VKApi friends] get:@{ VK_API_FIELDS : @"user_id, first_name, last_name, uid, photo_100" }];
    friendReq.attempts = ATTEMPTS_COUNT;
    [friendReq executeWithResultBlock:^(VKResponse *response) {
      //NSLog (@"Json result: %@", response.json);
      NSArray *friends = [self.responseMapper getFriendsResponseMapping:response.json];
      [self saveFriendsToStorage:friends];

      completion (YES, friends);
    }
        errorBlock:^(NSError *error) {
          if (error.code != VK_API_ERROR) {
              [error.vkError.request repeat];
          } else {
              completion (NO, error.localizedDescription);
          }
        }];
}

- (void)saveFriendsToStorage:(id)friends {
    [[LCDatabaseEngine sharedInstance] saveFriendsToStorage:friends];
}

- (void)getFeedRecordsWithStartTime:(NSInteger)startTime finishTime:(NSInteger)finishTime completion:(CompletionBlock)completion;
{
    VKRequest *getFeedReq = [VKRequest requestWithMethod:@"newsfeed.get" parameters:
                                                                      @{VK_API_OWNER_ID : [[LCUserDefaultsEngine sharedInstance] getCurrentUserId],
                                                                        @"start_time" : @(startTime),
                                                                        @"end_time" : @(finishTime)}];
    getFeedReq.attempts = ATTEMPTS_COUNT;
    [getFeedReq executeWithResultBlock:^(VKResponse *response) {
      NSArray *feedRecords = [self.responseMapper getFeedRecordsResponseMapping:response.json];
      completion (YES, feedRecords);

    }
        errorBlock:^(NSError *error) {
          if (error.code != VK_API_ERROR) {
              [error.vkError.request repeat];
          } else {
              completion (NO, error.localizedDescription);
          }
        }];
}


- (void)getWallRecordsWithOffset:(NSInteger)offset completion:(CompletionBlock)completion {
    VKRequest *getWallReq = [VKRequest requestWithMethod:@"wall.get" parameters:
                                                                             @{VK_API_OWNER_ID : [[LCUserDefaultsEngine sharedInstance] getCurrentUserId] ,
                                                                                VK_API_OFFSET : @(offset)}];
    getWallReq.attempts = ATTEMPTS_COUNT;
    [getWallReq executeWithResultBlock:^(VKResponse *response) {
      NSArray *wallRecords = [self.responseMapper getWallRecordsResponseMapping:response.json];
      completion (YES, wallRecords);

    }
        errorBlock:^(NSError *error) {
          if (error.code != VK_API_ERROR) {
              [error.vkError.request repeat];
          } else {
              completion (NO, error.localizedDescription);
          }
        }];
}

#pragma mark - VK Delegates

//метод протокола VKSdkUIDelegate
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [_vkOAuthdelegate presentDialogIfNoVKApp:controller]; //[self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
}


- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    NSLog (@"vkSdkAccessAuthorizationFinishedWithResult");
    //[self performSegueWithIdentifier:@"toTestFunctionalitySegue" sender:self];
    [_vkOAuthdelegate getUserInfo];
}

- (void)vkSdkUserAuthorizationFailed {
    NSLog (@"vkSdkUserAuthorizationFailed");
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    NSLog (@"vkSdkReceivedNewToken %@", newToken);
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    NSLog (@"vkSdkUserDeniedAccess");
}


@end
