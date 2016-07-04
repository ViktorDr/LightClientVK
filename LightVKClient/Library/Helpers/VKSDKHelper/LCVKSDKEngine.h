//
//  LCVKSDKEngine.h
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCVKResponseMapper.h"
#import <Foundation/Foundation.h>
#import <VKSdk.h>

@protocol VKOAuthDelegate;
typedef void (^CompletionBlock) (bool success, id object);

@interface LCVKSDKEngine : NSObject < VKSdkDelegate, VKSdkUIDelegate >

@property LCVKResponseMapper *responseMapper;
@property (nonatomic, strong) id< VKOAuthDelegate > vkOAuthdelegate;

+ (instancetype)sharedInstance;

- (void)vkOuth;

- (void)logout;

- (void)getUserInfo:(CompletionBlock)completion;

- (void)getFriends:(CompletionBlock)completion;
- (void)getWallRecordsWithOffset:(NSInteger)offset completion:(CompletionBlock)completion;
- (void)getFeedRecordsWithStartTime:(NSInteger)startTime finishTime:(NSInteger)finishTime completion:(CompletionBlock)completion;

- (void)getUserAndFriendsInfo:(CompletionBlock)completion;

@end


@protocol VKOAuthDelegate < NSObject >

@required

- (void)getUserInfo;
- (void)presentDialogIfNoVKApp:(id)controller;

@end