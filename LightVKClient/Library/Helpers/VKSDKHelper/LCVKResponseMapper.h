//
//  LCVKResponseMapper.h
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCVKResponseMapper : NSObject

- (id)getFriendsResponseMapping:(id)response;
- (id)getUserInfoResponseMapping:(id)response;
- (id)getWallRecordsResponseMapping:(id)response;
- (id)getFeedRecordsResponseMapping:(id)response;
@end
