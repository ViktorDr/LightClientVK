//
//  LCFriendsViewController.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCDatabaseEngine.h"
#import "LCFriendModel.h"
#import "LCFriendTableViewCell.h"
#import "LCFriendsViewController.h"
#import "LCRouter.h"
#import "LCUserDefaultsEngine.h"
#import "LCVKSDKEngine.h"
#import <MBProgressHUD.h>
@interface LCFriendsViewController () {
    NSArray *friends;
    NSMutableArray *images;
}
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UILabel *friendsCountLabel;

@end

@implementation LCFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    images = [[NSMutableArray alloc] init];
    [self.navigationItem setTitle:@"Мои друзья"];


    if (_loadFromDB) {
        NSArray *friendsDB = [[LCDatabaseEngine sharedInstance] getFriendsOfUser:[[LCUserDefaultsEngine sharedInstance] getCurrentUserId]];
        UIBarButtonItem *navMenuBtn = [[UIBarButtonItem alloc] initWithTitle:@"К главной" style:UIBarButtonItemStylePlain target:self action:@selector (toMainTapped:)];
        [self.navigationItem setLeftBarButtonItem:navMenuBtn];
        [self fillContent:friendsDB];
        [_friendsTableView reloadData];

    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[LCVKSDKEngine sharedInstance] getFriends:^(bool success, id object) {
          if (success) {
              [self fillContent:object];
              [self gcdPictureRequest];
          } else {
              NSString *error = object;
              [self showAlertView:error description:nil];
          }
        }];
    }
    // Do any additional setup after loading the view.
}


- (void)gcdPictureRequest {
    dispatch_async (
        dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          dispatch_queue_t q =
              dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
          dispatch_apply (friends.count, q, ^(size_t index) {
            [self loadFriendImage:index];
          });
          dispatch_async (dispatch_get_main_queue (), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_friendsTableView reloadData];

          });
        });
}

- (void)loadFriendImage:(NSInteger)index {
    LCFriendModel *friend = friends[index];
    NSURL *url = [NSURL URLWithString:friend.photoURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    [images addObject:img];
}

- (void)toMainTapped:(id)sender {
    [[LCRouter sharedInstance] rootSignInViewController];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fillContent:(id)allFriends {
    friends = allFriends;
    _friendsCountLabel.text = [NSString stringWithFormat:@"Количество друзей: %lu", (unsigned long)friends.count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LCFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LCFriendTableViewCell"];
    LCFriendModel *friend = friends[indexPath.row];
    NSString *friendName = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
    BOOL isOnlineValue = NO;
    if ([friend respondsToSelector:@selector (isOnline)]) {
        isOnlineValue = friend.isOnline;
    }
    if (_loadFromDB) {
        [cell setCellInfoWithPhoto:friend.photoURL name:friendName status:isOnlineValue];
    } else {
        [cell setCellInfoWithPhotoGCD:images[indexPath.row] name:friendName status:isOnlineValue];
    }
    return cell;
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
