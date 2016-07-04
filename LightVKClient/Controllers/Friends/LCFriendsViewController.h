//
//  LCFriendsViewController.h
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCWithSidebarViewController.h"

@interface LCFriendsViewController : LCWithSidebarViewController < UITableViewDelegate, UITableViewDataSource >

@property BOOL loadFromDB;

@end
