//
//  UIViewController+Sidebar.m
//  LightClientVK
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "UIViewController+Sidebar.h"

#import <ECSlidingViewController/UIViewController+ECSlidingViewController.h>

@implementation UIViewController (Sidebar)

#pragma mark - User interaction

- (IBAction)sidebar:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
