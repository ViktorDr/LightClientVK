//
//  LCFriendTableViewCell.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCFriendTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation LCFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfoWithPhoto:(NSString *)photo name:(NSString *)name status:(BOOL)status {
    if (photo) {
        [_friendPhoto sd_setImageWithURL:[NSURL URLWithString:photo] placeholderImage:nil];
    } else {
        _friendPhoto.image = nil;
    }
    _friendName.text = name;
    if (status) {
        _onlineStatus.text = @"online";
    } else {
        _onlineStatus.text = @"offline";
    }
}


- (void)setCellInfoWithPhotoGCD:(UIImage *)photo name:(NSString *)name status:(BOOL)status {
    if (photo) {
        _friendPhoto.image = photo;
    } else {
        _friendPhoto.image = nil;
    }
    _friendName.text = name;
    if (status) {
        _onlineStatus.text = @"online";
    } else {
        _onlineStatus.text = @"offline";
    }
}

@end
