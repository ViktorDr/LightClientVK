//
//  NSObject+LCAlertView.m
//  LightClientVK
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.

#import "NSObject+LCAlertView.h"

@implementation NSObject (LCAlertView)

- (void)showAlertView:(NSString *)title description:(NSString *)description {
    dispatch_async (dispatch_get_main_queue (), ^{

      __strong UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:description preferredStyle:UIAlertControllerStyleAlert];
      [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action){
                                                        }]];
      UIApplication *application = [UIApplication sharedApplication];
      UIWindow *window = application.keyWindow;
      UIViewController *vc;
      if (window.rootViewController.presentedViewController != nil) {
          vc = window.rootViewController.presentedViewController;
      } else {
          vc = window.rootViewController;
      }
      [vc presentViewController:alertController animated:YES completion:nil];
    });
}


@end
