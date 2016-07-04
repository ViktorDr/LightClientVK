//
//  LCFriendModel.h
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCFriendModel : NSObject

@property NSString *friendId;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *photoURL;
@property BOOL isOnline;

@end
