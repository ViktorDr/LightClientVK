//
//  LCWallTableViewCell.h
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCWallRecord.h"
#import <UIKit/UIKit.h>
@interface LCWallRecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *recordDate;
@property (weak, nonatomic) IBOutlet UILabel *recordText;
//@property (weak, nonatomic) IBOutlet UIImageView *recordImage;
@property (weak, nonatomic) IBOutlet UILabel *repostUserName;
@property (weak, nonatomic) IBOutlet UILabel *repostRecordDate;


+ (NSInteger)calcCellHeight:(LCWallRecord *)wallRecord viewWidth:(NSInteger)screenViewWidth;
- (CGSize)calcTextSize:(NSString *)text viewWidth:(NSInteger)screenViewWidth;

@end
