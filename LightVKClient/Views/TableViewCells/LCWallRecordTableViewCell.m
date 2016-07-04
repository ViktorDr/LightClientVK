//
//  LCWallTableViewCell.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCWallRecordTableViewCell.h"

@implementation LCWallRecordTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (NSInteger)calcCellHeight:(LCWallRecord *)wallRecord viewWidth:(NSInteger)screenViewWidth {
    NSInteger staticHeight = 36;
    NSInteger recomendedHeight = staticHeight;

    UITextView *titleView = [[UITextView alloc] initWithFrame:CGRectZero];
    titleView.font = [UIFont systemFontOfSize:14];
    titleView.text = wallRecord.text;
    CGSize titleSize = [titleView sizeThatFits:CGSizeMake (screenViewWidth - 45, CGFLOAT_MAX)];

    recomendedHeight += titleSize.height;

    recomendedHeight += (screenViewWidth / 3 + 5) * (wallRecord.photoURLs.count + wallRecord.repostPhotoURLs.count);

    return recomendedHeight;
}

- (CGSize)calcTextSize:(NSString *)text viewWidth:(NSInteger)screenViewWidth {
    UITextView *titleView = [[UITextView alloc] initWithFrame:CGRectZero];
    titleView.font = [UIFont systemFontOfSize:14];
    titleView.text = text;
    CGSize titleSize = [titleView sizeThatFits:CGSizeMake (screenViewWidth - 45, CGFLOAT_MAX)];
    return titleSize;
}


@end
