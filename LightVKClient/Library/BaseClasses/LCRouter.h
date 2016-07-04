//
//  LCRouter.h
//  LightVKClient
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ECSlidingViewController/ECSlidingViewController.h>

@interface LCRouter : NSObject

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) ECSlidingViewController *slidingViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, assign) CGSize topControllerSize;

+ (instancetype)sharedInstance;

- (void)showWallViewController;
- (void)showFeedViewController;
- (void)showFriendsViewController;

- (UIViewController *)rootSlideWallViewController;
- (UIViewController *)rootSignInViewController;
- (UIViewController *)rootFriendsDBViewController;
@end
