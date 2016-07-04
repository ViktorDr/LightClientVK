//
//  LCSlidingAnimationController.m
//  LightClientVK
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCSlidingAnimationController.h"
#import <ECSlidingViewController.h>

@interface LCSlidingAnimationController ()
@property (nonatomic, copy) void (^coordinatorAnimations) (id< UIViewControllerTransitionCoordinatorContext > context);
@property (nonatomic, copy) void (^coordinatorCompletion) (id< UIViewControllerTransitionCoordinatorContext > context);
@end

@implementation LCSlidingAnimationController

- (NSTimeInterval)transitionDuration:(id< UIViewControllerContextTransitioning >)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id< UIViewControllerContextTransitioning >)transitionContext {

    UIViewController *topViewController = [transitionContext viewControllerForKey:ECTransitionContextTopViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect topViewInitialFrame = [transitionContext initialFrameForViewController:topViewController];
    CGRect topViewFinalFrame = [transitionContext finalFrameForViewController:topViewController];

    topViewController.view.frame = topViewInitialFrame;

    if (topViewController != toViewController) {
        CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
        toViewController.view.frame = toViewFinalFrame;
        [containerView insertSubview:toViewController.view belowSubview:topViewController.view];

        UIView *blackOverlay = [[UIView alloc] initWithFrame:topViewController.view.frame];
        blackOverlay.layer.backgroundColor = [[UIColor blackColor] CGColor];
        blackOverlay.layer.opacity = 0.65f;
        blackOverlay.tag = 1000;
        [topViewController.view addSubview:blackOverlay];
    }

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
        animations:^{
          [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
          if (self.coordinatorAnimations)
              self.coordinatorAnimations ((id< UIViewControllerTransitionCoordinatorContext >)transitionContext);

          topViewController.view.frame = topViewFinalFrame;
        }
        completion:^(BOOL finished) {
          if ([transitionContext transitionWasCancelled]) {
              if (topViewController != toViewController) {
                  UIView *blackOverlay = [topViewController.view viewWithTag:1000];
                  [blackOverlay removeFromSuperview];
              }

              topViewController.view.frame = [transitionContext initialFrameForViewController:topViewController];
          } else if (topViewController == toViewController) {
              UIView *blackOverlay = [topViewController.view viewWithTag:1000];
              [blackOverlay removeFromSuperview];
          }


          if (self.coordinatorCompletion)
              self.coordinatorCompletion ((id< UIViewControllerTransitionCoordinatorContext >)transitionContext);
          [transitionContext completeTransition:finished];
        }];
}

@end
