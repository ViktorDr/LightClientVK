//
//  NSDate+LCExtension.m
//  LightClientVK
//
//  Created by Viktor Drykin on 03.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "NSDate+LCExtension.h"

@implementation NSDate (LCExtension)

- (NSString *)lc_stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}


@end
