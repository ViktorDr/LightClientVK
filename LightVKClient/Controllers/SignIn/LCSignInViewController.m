//
//  LCSignInViewController.m
//  LightClientVK
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCRouter.h"
#import "LCSignInViewController.h"
#import "LCVKSDKEngine.h"

@interface LCSignInViewController () < VKOAuthDelegate >
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation LCSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [LCVKSDKEngine sharedInstance].vkOAuthdelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signInTapped:(id)sender {
    [[LCVKSDKEngine sharedInstance] vkOuth];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getUserInfo {
    [[LCVKSDKEngine sharedInstance] getUserAndFriendsInfo:^(bool success, id object) {
        if (success) {
            [[LCRouter sharedInstance] rootSlideWallViewController];
        } else {
            if ([object isKindOfClass:[NSString class]]) {
                [self showAlertView:object description:nil];
            }
            
        }
    }];
//    [[LCVKSDKEngine sharedInstance] getUserInfo:^(bool success, id object) {
//      if (success) {
//          [[LCRouter sharedInstance] rootSlideWallViewController];
//      } else {
//      }
//    }];
}
- (IBAction)loadFriendsFromDBTapped:(id)sender {
    [[LCRouter sharedInstance] rootFriendsDBViewController];
}

- (void)presentDialogIfNoVKApp:(id)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

@end
