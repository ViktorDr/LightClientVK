//
//  LCFeedViewController.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCDatabaseEngine.h"
#import "LCFeedViewController.h"
#import "LCVKSDKEngine.h"
#import "LCWallRecord.h"
#import "LCWallRecordTableViewCell.h"
#import "NSDate+LCExtension.h"
#import <MBProgressHUD.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIScrollView+InfiniteScroll.h>

static NSInteger const TIME_OFFSET = 3000;
static NSInteger const IMAGE_PROPORTION = 3;

@interface LCFeedViewController () {
    NSArray *feedRecords;
    NSInteger startTime, endTime;
}
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;

@end

@implementation LCFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Новости"];
    startTime = [[NSDate date] timeIntervalSince1970] - TIME_OFFSET;
    endTime = [[NSDate date] timeIntervalSince1970];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LCVKSDKEngine sharedInstance] getFeedRecordsWithStartTime:startTime finishTime:endTime completion:^(bool success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      if (success) {
          feedRecords = object;
          [_feedTableView reloadData];
      } else {
          NSString *alert = object;
          [self showAlertView:alert description:nil];
      }
    }];
    [self setPullToRefreshUp];
    [self setPullToRefreshDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    [_feedTableView reloadData];
}

- (void)setPullToRefreshUp {
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector (upPullToRefresh:) forControlEvents:UIControlEventValueChanged];
    [_feedTableView addSubview:refreshControl];
    [_feedTableView sendSubviewToBack:refreshControl];
}

- (void)setPullToRefreshDown {
    _feedTableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    // setup infinite scroll
    [_feedTableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
      [[LCVKSDKEngine sharedInstance] getFeedRecordsWithStartTime:startTime - TIME_OFFSET finishTime:startTime completion:^(bool success, id object) {
        if (success) {
            startTime -= TIME_OFFSET;
            [self updateWithDownScroll:object];
        }
      }];
    }];
}


- (void)upPullToRefresh:(UIRefreshControl *)refreshControl {

    [[LCVKSDKEngine sharedInstance] getFeedRecordsWithStartTime:endTime finishTime:[[NSDate date] timeIntervalSince1970] completion:^(bool success, id object) {
      if (success) {
          endTime = [[NSDate date] timeIntervalSince1970];
          [self updateWithUpScrollWithRefreshControl:refreshControl records:object];
      }
    }];
}


- (void)updateWithUpScrollWithRefreshControl:refreshControl records:(id)records {
    NSArray *someRecords = records;
    NSMutableArray *allRecords = [[NSMutableArray alloc] init];
    [allRecords addObjectsFromArray:someRecords];
    [allRecords addObjectsFromArray:feedRecords];
    feedRecords = [NSArray arrayWithArray:allRecords];


    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    for (int i = 0; i < someRecords.count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        [indexes addObject:index];
    }
    NSArray< NSIndexPath * > *indexPaths = [NSArray arrayWithArray:indexes]; // index paths of updated rows

    // make sure to update tableView before calling -finishInfiniteScroll
    [_feedTableView beginUpdates];
    [_feedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [_feedTableView endUpdates];

    [refreshControl endRefreshing];
}

- (void)updateWithDownScroll:(id)records {
    NSInteger indexCount = feedRecords.count;
    NSArray *someRecords = records;
    NSMutableArray *allRecords = [[NSMutableArray alloc] init];
    [allRecords addObjectsFromArray:feedRecords];
    [allRecords addObjectsFromArray:someRecords];
    feedRecords = [NSArray arrayWithArray:allRecords];


    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    for (int i = 0; i < someRecords.count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:indexCount inSection:0];
        [indexes addObject:index];
        indexCount++;
    }
    NSArray< NSIndexPath * > *indexPaths = [NSArray arrayWithArray:indexes]; // index paths of updated rows

    // make sure to update tableView before calling -finishInfiniteScroll
    [_feedTableView beginUpdates];
    [_feedTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [_feedTableView endUpdates];

    [_feedTableView finishInfiniteScroll];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LCWallRecord *wallRecord = feedRecords[indexPath.row];
    return [LCWallRecordTableViewCell calcCellHeight:wallRecord viewWidth:self.view.frame.size.width];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feedRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LCWallRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LCWallRecordTableViewCell"];
    LCWallRecord *record = feedRecords[indexPath.row];
    //cell.userName.text = [[LCDatabaseEngine sharedInstance] getFriendOrUserName:record.fromId];
    cell.recordDate.text = [record.date lc_stringWithFormat:@"dd.MM.yyyy HH:mm"];

    for (UIView *view in cell.contentView.subviews) {
        if (![view isEqual:cell.userName] && ![view isEqual:cell.recordDate]) {
            [view removeFromSuperview];
        }
    }

    NSInteger startImageYPosition = cell.userName.frame.origin.y + cell.userName.frame.size.height + 5;

    CGSize textSize = [cell calcTextSize:record.text viewWidth:self.view.frame.size.width];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake (15, startImageYPosition, textSize.width, textSize.height)];
    text.font = [UIFont systemFontOfSize:14];
    text.numberOfLines = 0;
    text.text = record.text;
    [cell.contentView addSubview:text];
    startImageYPosition += text.frame.size.height;

    NSMutableArray *urls = [[NSMutableArray alloc] init];
    [urls addObjectsFromArray:record.photoURLs];
    [urls addObjectsFromArray:record.repostPhotoURLs];

    for (NSString *url in urls) {
        startImageYPosition += 5;
        CGRect imageFrame = CGRectMake (15, startImageYPosition, self.view.frame.size.width / IMAGE_PROPORTION, self.view.frame.size.width / IMAGE_PROPORTION);

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
        [imageView.layer setBorderWidth:2.0];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (url) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                         placeholderImage:[UIImage imageNamed:@"placeholder"]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                }];
        } else {
            imageView.image = nil;
        }
        startImageYPosition += self.view.frame.size.width / IMAGE_PROPORTION;
        [cell.contentView addSubview:imageView];
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
