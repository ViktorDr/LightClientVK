//
//  LCWithSidebarViewController.m
//  LightClientVK
//
//  Created by Viktor Drykin on 02.07.16.
//  Copyright © 2016 ViktorDrykin. All rights reserved.
//

#import "LCWithSidebarViewController.h"
#import "UIViewController+Sidebar.h"

@interface LCWithSidebarViewController ()

@end

@implementation LCWithSidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *navMenuBtn = [[UIBarButtonItem alloc] initWithTitle:@"Меню" style:UIBarButtonItemStylePlain target:self action:@selector (sidebar:)];
    [self.navigationItem setLeftBarButtonItem:navMenuBtn];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
