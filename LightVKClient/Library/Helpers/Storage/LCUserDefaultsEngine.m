//
//  LCUserDefaultsEngine.m
//  LightClientVK
//
//  Created by Viktor Drykin on 03.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCUserDefaultsEngine.h"

static NSString *const currentUserId = @"currentUserId";

@implementation LCUserDefaultsEngine

+ (instancetype)sharedInstance {
    static LCUserDefaultsEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
      sharedInstance = [[self alloc] init];
      sharedInstance.defaults = [NSUserDefaults standardUserDefaults];
    });
    return sharedInstance;
}


- (void)setCurrentUserId:(id)userId {
    [self.defaults setObject:userId forKey:currentUserId];
    [self.defaults synchronize];
}
- (id)getCurrentUserId {
    return [self.defaults objectForKey:currentUserId];
}


@end
