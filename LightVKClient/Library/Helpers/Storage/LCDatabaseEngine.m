//
//  LCDatabaseEngine.m
//  LightClientVK
//
//  Created by Viktor Drykin on 03.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCDatabaseEngine.h"
#import "LCFriend.h"
#import "LCFriendModel.h"
#import "LCUser.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation LCDatabaseEngine

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void)setCurrentUserWithId:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName photoURL:(NSString *)photoURL {
    [LCUser MR_truncateAll]; // пока один пользователь, так быстрее
    LCUser *user = [LCUser MR_createEntity];
    user.userId = userId;
    user.firstName = firstName;
    user.lastName = lastName;
    user.photoURL = photoURL;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}
- (id)getCurrentUser:(id)userId {
    LCUser *user = [LCUser MR_findFirstByAttribute:@"userId"
                                         withValue:userId];
    return user;
}


- (void)saveFriendWithId:(NSString *)userId firstName:(NSString *)firstName lastName:(NSString *)lastName photoURL:(NSString *)photoURL {
    LCFriend *friend;
    NSPredicate *friendFilter = [NSPredicate predicateWithFormat:@"friendId == %@", userId];
    NSArray *friends = [LCFriend MR_findAllWithPredicate:friendFilter];
    friend = friends.firstObject;
    if (!friend) {
        friend = [LCFriend MR_createEntity];
        friend.friendId = userId;
        friend.firstName = firstName;
        friend.lastName = lastName;
        friend.photoURL = photoURL;
    }
}

- (id)getFriendsOfUser:(id)userId {
    //пока только один юзер возможный сделаем так
    return [LCFriend MR_findAll];
}

- (NSString *)getFriendOrUserName:(id)friendId {
    LCFriend *friend;
    NSPredicate *friendFilter = [NSPredicate predicateWithFormat:@"friendId == %@", friendId];
    NSArray *friends = [LCFriend MR_findAllWithPredicate:friendFilter];
    friend = friends.firstObject;
    if (!friend) {
        LCUser *user = [LCUser MR_findFirstByAttribute:@"userId" withValue:friendId];
        if (!user) {
            return friendId;
        } else {
            return [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        }
        return friendId;

    } else {
        return [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
    }
}

- (void)saveFriendsToStorage:(id)friends {
    for (LCFriendModel *friendModel in friends) {
        [self saveFriendWithId:friendModel.friendId firstName:friendModel.firstName lastName:friendModel.lastName photoURL:friendModel.photoURL];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
