//
//  LCSidebarViewController.m
//  LightClientVK
//
//  Created by Viktor Drykin on 01.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCDatabaseEngine.h"
#import "LCRouter.h"
#import "LCSidebarViewController.h"
#import "LCTextTableViewCell.h"
#import "LCUser.h"
#import "LCUserDefaultsEngine.h"
#import "LCUserModel.h"
#import "LCVKSDKEngine.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface LCSidebarViewController () {
    NSArray *menuItems;
    NSString *firstName;
    NSString *lastName;
}
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UILabel *userFirstName;
@property (weak, nonatomic) IBOutlet UILabel *userLastName;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@end

@implementation LCSidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    menuItems = @[ @"Список друзей", @"Моя стена", @"Новости", @"Выход" ];
    [self setUserInfo];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LCTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LCTextTableViewCell"];
    cell.customTextLabel.text = menuItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    case 0: {
        [[LCRouter sharedInstance] showFriendsViewController];
        break;
    }
    case 1: {
        [[LCRouter sharedInstance] showWallViewController];
        break;
    }
    case 2: {
        [[LCRouter sharedInstance] showFeedViewController];
        break;
    }
    case 3: {
        [[LCVKSDKEngine sharedInstance] logout];
        [[LCRouter sharedInstance] rootSignInViewController];
        break;
    }
    default:
        break;
    }
}

#pragma mark - Utils

- (void)setUserInfo {
    NSString *currentUserId = [[LCUserDefaultsEngine sharedInstance] getCurrentUserId];
    LCUser *user = [[LCDatabaseEngine sharedInstance] getCurrentUser:currentUserId];
    _userFirstName.text = user.firstName;
    _userLastName.text = user.lastName;
    [_userImage sd_setImageWithURL:[NSURL URLWithString:user.photoURL] placeholderImage:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
