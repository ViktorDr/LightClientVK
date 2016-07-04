//
//  NSObject+LCAlertView.h
//  LightClientVK
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (LCAlertView)

- (void)showAlertView:(NSString *)title description:(NSString *)description;

@end
