//
//  LCWallRecord.h
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCWallRecord : NSObject

@property NSString *fromId;
@property NSString *fromIdName;
@property NSDate *date;
@property NSString *text;
@property NSArray *photoURLs;

@property NSString *repostFromId;
@property NSString *repostFromIdName;
@property NSDate *repostDate;
@property NSString *repostText;
@property NSArray *repostPhotoURLs;

//@property NSString *videoURL;

@property BOOL wasReloadCell;

@end
