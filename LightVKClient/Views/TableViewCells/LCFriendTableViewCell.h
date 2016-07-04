//
//  LCFriendTableViewCell.h
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendPhoto;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatus;

- (void)setCellInfoWithPhoto:(NSString *)photo name:(NSString *)name status:(BOOL)status;
- (void)setCellInfoWithPhotoGCD:(UIImage *)photo name:(NSString *)name status:(BOOL)status;

@end
