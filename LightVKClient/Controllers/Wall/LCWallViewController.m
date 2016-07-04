//
//  LCFeedViewController.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCDatabaseEngine.h"
#import "LCVKSDKEngine.h"
#import "LCWallRecord.h"
#import "LCWallRecordTableViewCell.h"
#import "LCWallViewController.h"
#import "NSDate+LCExtension.h"
#import <MBProgressHUD.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIScrollView+InfiniteScroll.h>

static NSInteger const IMAGE_PROPORTION = 3;

@interface LCWallViewController () < MWPhotoBrowserDelegate > {
    NSArray *wallRecords;
    NSArray *photos;
}
@property (weak, nonatomic) IBOutlet UITableView *wallTableView;

@end

@implementation LCWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Моя стена"];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LCVKSDKEngine sharedInstance] getWallRecordsWithOffset:wallRecords.count completion:^(bool success, id object) {
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      if (success) {
          wallRecords = object;
          [_wallTableView reloadData];
      } else {
          NSString *alert = object;
          [self showAlertView:alert description:nil];
      }
    }];

    [self setScrollDownHandler];
}

- (void)setScrollDownHandler {
    _wallTableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleGray;
    // setup infinite scroll
    [_wallTableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
      [[LCVKSDKEngine sharedInstance] getWallRecordsWithOffset:wallRecords.count completion:^(bool success, id object) {
        if (success) {
            [self updateWithDownScroll:object];
        }
      }];


    }];
}

- (void)updateWithDownScroll:(id)records {
    NSInteger indexCount = wallRecords.count;
    NSArray *someRecords = records;
    NSMutableArray *allRecords = [[NSMutableArray alloc] init];
    [allRecords addObjectsFromArray:wallRecords];
    [allRecords addObjectsFromArray:someRecords];
    wallRecords = [NSArray arrayWithArray:allRecords];


    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    for (int i = 0; i < someRecords.count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:indexCount inSection:0];
        [indexes addObject:index];
        indexCount++;
    }
    NSArray< NSIndexPath * > *indexPaths = [NSArray arrayWithArray:indexes]; // index paths of updated rows

    [_wallTableView beginUpdates];
    [_wallTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [_wallTableView endUpdates];

    // finish infinite scroll animation
    [_wallTableView finishInfiniteScroll];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged:(NSNotification *)notification {
    [_wallTableView reloadData];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LCWallRecord *wallRecord = wallRecords[indexPath.row];
    return [LCWallRecordTableViewCell calcCellHeight:wallRecord viewWidth:self.view.frame.size.width];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return wallRecords.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LCWallRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LCWallRecordTableViewCell"];
    LCWallRecord *record = wallRecords[indexPath.row];
    cell.userName.text = [[LCDatabaseEngine sharedInstance] getFriendOrUserName:record.fromId];
    cell.recordDate.text = [record.date lc_stringWithFormat:@"dd.MM.yyyy HH:mm"];

    for (UIView *view in cell.contentView.subviews) {
        if (![view isEqual:cell.userName] && ![view isEqual:cell.recordDate]) {
            [view removeFromSuperview];
        }
    }

    NSInteger startImageYPosition = cell.userName.frame.origin.y + cell.userName.frame.size.height + 5;

    // Добавили текст
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
        [imageView.layer setBorderColor: [[UIColor darkGrayColor] CGColor]];
        [imageView.layer setBorderWidth: 2.0];
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewAutomaticDimension;
//}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
//        return UITableViewAutomaticDimension;
//    } else {
//        return 160;
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


    LCWallRecord *record = wallRecords[indexPath.row];
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    [urls addObjectsFromArray:record.photoURLs];
    [urls addObjectsFromArray:record.repostPhotoURLs];

    if (urls.count) {
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];

        NSMutableArray *tmpPhotos = [[NSMutableArray alloc] init];
        for (NSString *photoUrls in urls) {
            [tmpPhotos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:photoUrls]]];
        }
        photos = [NSArray arrayWithArray:tmpPhotos];
        browser.displayActionButton = NO; // Show action button to allow sharing, copying, etc (defaults to YES)
        browser.zoomPhotosToFill = YES;   // Images that almost fill the screen will be initially zoomed to fill
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (id< MWPhoto >)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [photos objectAtIndex:index];
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
