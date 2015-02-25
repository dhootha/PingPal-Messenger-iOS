//
//  SidebarTableViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-12.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"

@interface SidebarTableViewController (){
    NSArray *menuItems;
}

@end

@implementation SidebarTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"******* viewDidLoad in sidebar ***********");
    
    [self.view setBackgroundColor:UIColorFromRGB(0x48BB90)];
    
    menuItems = @[@"title", @"separator", @"chats", @"friends", @"groups", @"separator", @"manage", @"managePing", @"facebook"]; //@"contacts", @"settings"
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat returnValue;
    
    if (indexPath.row == 0)
    {
        returnValue = 96;
    }
    else if (indexPath.row == 1 || indexPath.row == 5)
    {
        returnValue = 2;
    }
    else
    {
        returnValue = 44;
    }
    
    return returnValue;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
}


@end