//
//  LCDatabaseEngine.h
//  LightClientVK
//
//  Created by Viktor Drykin on 03.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCDatabaseEngine : NSObject

+ (instancetype)sharedInstance;

- (void)setCurrentUserWithId:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName photoURL:(NSString *)photoURL;
- (id)getCurrentUser:(id)userId;

- (void)saveFriendsToStorage:(id)friends;
- (void)saveFriendWithId:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName photoURL:(NSString *)photoURL;
- (id)getFriendsOfUser:(id)userId;
- (NSString *)getFriendOrUserName:(id)friendId;


@end
