//
//  LCUserDefaultsEngine.h
//  LightClientVK
//
//  Created by Viktor Drykin on 03.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import <Foundation/Foundation.h>


//Можно было бы и не создавать, т.к. при одном пользователе класс не нужен, в User defaults хранить нечего
@interface LCUserDefaultsEngine : NSObject

@property (nonatomic, strong) NSUserDefaults *defaults;

+ (instancetype)sharedInstance;

- (void)setCurrentUserId:(id)userId;
- (id)getCurrentUserId;

@end
