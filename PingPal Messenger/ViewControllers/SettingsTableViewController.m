//
//  SettingsTableViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 07/05/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SWRevealViewController.h"

@interface SettingsTableViewController (){
    NSArray *settingItems;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // ***** Side menu *****
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    [self.view setBackgroundColor:UIColorFromRGB(0x48BB90)];

    // TableView appearance
    [self.tableView setSeparatorColor:UIColorFromRGB(0x48BB90)];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    settingItems = @[@"empty", @"aktivatePassword", @"changePassword", @"empty", @"simplePassword", @"simplePasswordExplained", @"moreSettings", @"moreSettings", @"moreSettings", @"doesNotWork"];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return settingItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [settingItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) return 35;
    
    if (indexPath.row == 3) return 35;
    
    return tableView.rowHeight;
}


@end