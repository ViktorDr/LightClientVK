//
//  LCRouter.m
//  LightVKClient
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//


#import "LCRouter.h"

#import "UIStoryboard+LC.h"
//#import "UIViewController+Xib.h"

#import "LCFriendsViewController.h"
#import "LCSidebarViewController.h"
#import "LCSlidingAnimationController.h"
CGFloat const slidingMenuWidth = 280;

@interface LCRouter () < ECSlidingViewControllerLayout, ECSlidingViewControllerDelegate >

- (void)setWindowRootViewController:(UIViewController *)viewController completion:(void (^) (BOOL finished))completion;
- (void)setRootViewController:(UIViewController *)viewController;

@end

@implementation LCRouter

#pragma mark - Singleton pattern

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - SDRouter lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.rootViewController = [self rootSignInViewController];
        [self.window makeKeyAndVisible];
    }
    return self;
}

#pragma mark - Accessors

- (CGSize)topControllerSize {
    return [UIScreen mainScreen].bounds.size;
}

#pragma mark - ViewControllers management

- (UIViewController *)rootSignInViewController {
    id rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignInViewController"];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return rootViewController;
}


- (UIViewController *)rootSlideWallViewController {
    UIViewController *rootViewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"ECSlidingViewController"];
    self.slidingViewController = (ECSlidingViewController *)rootViewController;
    self.slidingViewController.topViewController.view.clipsToBounds = YES;
    self.slidingViewController.delegate = self;
    id wallViewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"WallNavigationController"];
    self.slidingViewController.topViewController = wallViewController;
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
    //Если закомменчено, то при загрузке контроллера меню будет сразу спрятано
    //[self.slidingViewController anchorTopViewToRightAnimated:NO];
    self.navigationController = (UINavigationController *)self.slidingViewController.topViewController;

    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    return rootViewController;
}


- (UIViewController *)rootFriendsDBViewController {
    UINavigationController *friendViewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"FriendsNavigationController"];
    LCFriendsViewController *vc = friendViewController.viewControllers.firstObject;
    vc.loadFromDB = YES;
    self.window.rootViewController = friendViewController;
    [self.window makeKeyAndVisible];
    return friendViewController;
}


- (void)showWallViewController {
    [self showControllerWithName:@"WallNavigationController"];
}

- (void)showFeedViewController {
    [self showControllerWithName:@"FeedNavigationController"];
}
- (void)showFriendsViewController {
    [self showControllerWithName:@"FriendsNavigationController"];
}

- (void)showControllerWithName:(NSString *)viewControllerName {
    id viewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:viewControllerName];
    self.slidingViewController.topViewController = viewController;
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.slidingViewController resetTopViewAnimated:YES];
}

#pragma mark - ECSlidingViewController delegate

- (id< UIViewControllerAnimatedTransitioning >)slidingViewController:(ECSlidingViewController *)slidingViewController animationControllerForOperation:(ECSlidingViewControllerOperation)operation topViewController:(UIViewController *)topViewController {
    return [[LCSlidingAnimationController alloc] init];
}

#pragma mark - ECSlidingViewControllerLayout delegate

- (CGRect)slidingViewController:(ECSlidingViewController *)slidingViewController
         frameForViewController:(UIViewController *)viewController
                topViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition {
    if (viewController == self.slidingViewController.topViewController) {
        CGRect containerViewFrame = self.slidingViewController.view.bounds;

        if (!(self.slidingViewController.topViewController.edgesForExtendedLayout & UIRectEdgeTop)) {
            CGFloat topLayoutGuideLength = [self.slidingViewController.topLayoutGuide length];
            containerViewFrame.origin.y = topLayoutGuideLength;
            containerViewFrame.size.height -= topLayoutGuideLength;
        }

        if (!(self.slidingViewController.topViewController.edgesForExtendedLayout & UIRectEdgeBottom)) {
            CGFloat bottomLayoutGuideLength = [self.slidingViewController.bottomLayoutGuide length];
            containerViewFrame.size.height -= bottomLayoutGuideLength;
        }

        containerViewFrame.size.width = [UIScreen mainScreen].bounds.size.width - self.slidingViewController.anchorRightRevealAmount;

        switch (topViewPosition) {
        case ECSlidingViewControllerTopViewPositionCentered:
            containerViewFrame.origin.x = self.slidingViewController.anchorRightRevealAmount;
            return containerViewFrame;
        case ECSlidingViewControllerTopViewPositionAnchoredLeft:
            containerViewFrame.origin.x = -self.slidingViewController.anchorLeftRevealAmount;
            return containerViewFrame;
        case ECSlidingViewControllerTopViewPositionAnchoredRight:
            containerViewFrame.origin.x = self.slidingViewController.anchorRightRevealAmount;
            return containerViewFrame;
        default:
            return CGRectZero;
        }
    } else if ([viewController isKindOfClass:[LCSidebarViewController class]]) {
        CGRect containerViewFrame = self.slidingViewController.view.bounds;
        containerViewFrame.size.width = self.slidingViewController.anchorRightRevealAmount;
        return containerViewFrame;
    }
    return CGRectInfinite;
}


#pragma mark - Utils

- (void)setRootViewController:(UIViewController *)viewController {
    [self.navigationController setViewControllers:@[ viewController ] animated:NO];
}
- (void)setWindowRootViewController:(UIViewController *)viewController completion:(void (^) (BOOL finished))completion {
    viewController.view.frame = self.window.frame;
    [viewController.view updateConstraints];
    BOOL oldState = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    [UIView transitionFromView:self.window.rootViewController.view
                        toView:viewController.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
                      [UIView setAnimationsEnabled:oldState];
                      self.window.rootViewController = viewController;
                      if (completion != nil) {
                          completion (finished);
                      }
                    }];
}

@end
