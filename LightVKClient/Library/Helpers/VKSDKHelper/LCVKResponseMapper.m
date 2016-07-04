//
//  LCVKResponseMapper.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCFriendModel.h"
#import "LCUserModel.h"
#import "LCVKResponseMapper.h"
#import "LCWallRecord.h"
@implementation LCVKResponseMapper


- (id)getFriendsResponseMapping:(id)response {
    NSMutableArray *tmpFriends = [[NSMutableArray alloc] init];
    for (NSDictionary *friendJSON in response[@"items"]) {
        LCFriendModel *friend = [[LCFriendModel alloc] init];
        friend.firstName = friendJSON[@"first_name"];
        friend.lastName = friendJSON[@"last_name"];
        friend.friendId = [friendJSON[@"id"] stringValue];
        friend.isOnline = [friendJSON[@"online"] boolValue];
        friend.photoURL = friendJSON[@"photo_100"];
        [tmpFriends addObject:friend];
    }
    return [NSArray arrayWithArray:tmpFriends];
}


- (id)getUserInfoResponseMapping:(id)response {
    LCUserModel *user;
    if (response) {
        user = [[LCUserModel alloc] init];
        user.firstName = response[@"first_name"];
        user.lastName = response[@"last_name"];
        user.photoURL = response[@"photo_100"];
        user.userId = [response[@"id"] stringValue];
    }
    return user;
}

- (id)getWallRecordsResponseMapping:(id)response {
    NSMutableArray *tmpRecords = [[NSMutableArray alloc] init];
    for (NSDictionary *recordJSON in response[@"items"]) {
        LCWallRecord *record = [self parseRecord:recordJSON];
        [tmpRecords addObject:record];
    }
    return [NSArray arrayWithArray:tmpRecords];
}

- (id)getFeedRecordsResponseMapping:(id)response {
    NSMutableArray *tmpRecords = [[NSMutableArray alloc] init];
    for (NSDictionary *recordJSON in response[@"items"]) {
        if ([recordJSON[@"type"] isEqualToString:@"post"]) {
            LCWallRecord *record = [self parseRecord:recordJSON];
            [tmpRecords addObject:record];
        }
    }
    return [NSArray arrayWithArray:tmpRecords];
}

- (LCWallRecord *)parseRecord:(id)recordJSON {
    LCWallRecord *record = [[LCWallRecord alloc] init];
    record.fromId = [recordJSON[@"from_id"] stringValue];
    record.date = [NSDate dateWithTimeIntervalSince1970:[recordJSON[@"date"] doubleValue]];
    record.text = recordJSON[@"text"];

    //вложения верхнего уровня
    if (recordJSON[@"attachments"]) {
        record.photoURLs = [self parseAttachments:recordJSON];
    }

    //вложения в репосте
    if (recordJSON[@"copy_history"]) {
        record.repostFromId = recordJSON[@"copy_history"][0][@"from_id"];
        record.repostDate = recordJSON[@"copy_history"][0][@"date"];
        record.repostText = recordJSON[@"copy_history"][0][@"text"];
        record.repostPhotoURLs = [self parseAttachments:recordJSON[@"copy_history"][0]];
    }
    return record;
}

- (NSArray *)parseAttachments:(NSDictionary *)recordJSON {
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    if (recordJSON[@"attachments"]) {
        for (NSDictionary *attachItem in recordJSON[@"attachments"]) {
            NSString *attachType = attachItem[@"type"];
            NSDictionary *attach = attachItem[attachType];

            if (attach[@"photo_604"]) {
                [attachments addObject:attach[@"photo_604"]];
            } else if (attach[@"photo_130"]) {
                [attachments addObject:attach[@"photo_130"]];
            }
        }
    }
    return [NSArray arrayWithArray:attachments];
}

@end
