//
//  GroupsTableViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-18.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "GroupsTableViewController.h"
#import "SWRevealViewController.h"
#import "GroupWrapper.h"
#import "GroupChatViewController.h"
#import "ThreadWrapper.h"
#import "TableItem.h"
#import "MapViewController.h"
#import "MyselfObject.h"
#import "OutboxHandler.h"
#import "InboxHandler.h"
#import "TableViewTopView.h"
#import "Push.h"
#import "DoNotNotify.h"

#import "GroupOverlord.h"
#import "GroupServer.h"

#import <PPLocationManager/PPLocationManager.h>

@interface GroupsTableViewController (){
    NSMutableArray *sections;
    NSMutableArray *groups;
    NSMutableArray *deletedGroups;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation GroupsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"GroupsTableViewController viewDidLoad");
    
    sections = [[NSMutableArray alloc]initWithArray:@[NSLocalizedString(@"GroupsSection", @"Groups section title"), NSLocalizedString(@"NotMemberGroupsSection", @"Not member groups section title")]];
    
    groups = [[NSMutableArray alloc]init];
    deletedGroups = [[NSMutableArray alloc]init];
    
    // Image above tableView
    [self.tableView addSubview:[TableViewTopView createTableViewTopView]];
    
    // TableView appearance
    [self.tableView setSeparatorColor:UIColorFromRGB(0x48BB90)];
    
    // ***** Side menu *****
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Fetch groups
    [groups addObjectsFromArray:[GroupWrapper fetchAllNonDeletedGroupsWithSortKey:@"name" ascending:YES]];
    [deletedGroups addObjectsFromArray:[GroupWrapper fetchAllDeletedGroupsWithSortKey:@"name" ascending:YES]];
    
    for (Group *group in groups) {
        [[GroupServer sharedInstance]getMembersForGroup:group.tag callback:^(NSArray *members) {
            NSLog(@"Members in %@: %@", group.name, members);
        }];
    }
    
    //[[OutboxHandler sharedInstance]listMyGroups];
    //[[OutboxHandler sharedInstance]listDeletedGroups];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[ManagedObjectChangeListener sharedInstance]addChangeListener:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[ManagedObjectChangeListener sharedInstance]removeChangeListener:self];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)reloadTableView
{
    NSLog(@"*** reloadTableView ***");
    
    [groups removeAllObjects];
    [deletedGroups removeAllObjects];
    
    [groups addObjectsFromArray:[GroupWrapper fetchAllNonDeletedGroupsWithSortKey:@"name" ascending:YES]];
    [deletedGroups addObjectsFromArray:[GroupWrapper fetchAllDeletedGroupsWithSortKey:@"name" ascending:YES]];
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [groups count];
    }else{
        return [deletedGroups count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"groupCell" forIndexPath:indexPath];
        
        GroupCell __weak *weakCell = cell;
        
        [cell setAppearanceWithBlock:^{
            weakCell.leftUtilityButtons = NULL;
            weakCell.rightUtilityButtons = [self rightButtons];
            weakCell.delegate = self;
            weakCell.containingTableView = tableView;
        } force:NO];
        
        [cell setCellHeight:cell.frame.size.height];
        
        [cell.nameLabel setText:[(NSObject<TableItem>*)[groups objectAtIndex:indexPath.row] getName]];
        
        
//        NSArray *arr = [(NSObject<TableItem>*)[groups objectAtIndex:indexPath.row]getImageFilePaths];
//        NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
//        
//        for (NSString *filePath in arr)
//        {
//            [mutableArr addObject:[UIImage imageWithContentsOfFile:filePath]];
//        }
//        
//        [mutableArr addObject:[UIImage imageWithContentsOfFile:[[MyselfObject sharedInstance]getImageFilePath]]];
//        
//        if (mutableArr.count != 0)
//        {
//            [cell.avatarImageView setAnimationImages:mutableArr];
//            [cell.avatarImageView setAnimationDuration:(1.25f * mutableArr.count)];
//            [cell.avatarImageView setAnimationRepeatCount:0];
//            [cell.avatarImageView startAnimating];
//        }
//        else
//        {
//            [cell.avatarImageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
//        }
        
        
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:[(NSObject<TableItem>*)[groups objectAtIndex:indexPath.row] getImageFilePath]];
        if (image) {
            [cell.avatarImageView setImage:image];
        }else{
            [cell.avatarImageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"notMemberGroupCell" forIndexPath:indexPath];
        
        GroupCell __weak *weakCell = cell;
        
        [cell setAppearanceWithBlock:^{
            weakCell.leftUtilityButtons = NULL;
            weakCell.rightUtilityButtons = NULL;
            weakCell.delegate = self;
            weakCell.containingTableView = tableView;
        } force:NO];
        
        [cell setCellHeight:cell.frame.size.height];
        
        [cell.nameLabel setText:[(NSObject<TableItem>*)[deletedGroups objectAtIndex:indexPath.row] getName]];
        
        
        
//        NSArray *arr = [(NSObject<TableItem>*)[deletedGroups objectAtIndex:indexPath.row]getImageFilePaths];
//        NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
//        
//        for (NSString *filePath in arr)
//        {
//            [mutableArr addObject:[UIImage imageWithContentsOfFile:filePath]];
//        }
//        
//        if (mutableArr.count != 0)
//        {
//            [cell.avatarImageView setAnimationImages:mutableArr];
//            [cell.avatarImageView setAnimationDuration:mutableArr.count];
//            [cell.avatarImageView setAnimationRepeatCount:0];
//            [cell.avatarImageView startAnimating];
//        }
//        else
//        {
//            [cell.avatarImageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
//        }
        
        
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:[(NSObject<TableItem>*)[deletedGroups objectAtIndex:indexPath.row] getImageFilePath]];
        if (image) {
            [cell.avatarImageView setImage:image];
        }else{
            [cell.avatarImageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
        }
        
        [cell.joinButton addTarget:self action:@selector(joinButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [cell.avatarImageView.layer setCornerRadius:27];
    [cell.avatarImageView setClipsToBounds:YES];
    
    // selectedBackgroundView
    UIView *sbv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [sbv setBackgroundColor:UIColorFromRGB(0x48BB90)];
    [cell setSelectedBackgroundView:sbv];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    [headerView setBackgroundColor:UIColorFromRGB(0x48BB90)];
    
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 1, self.tableView.frame.size.width-10, 30)];
    [headerLabel setText:sections[section]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    
    [headerLabel sizeToFit];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.2f green:0.97f blue:0.3f alpha:1.0]
                                                title:@"Ping"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:NSLocalizedString(@"Leave",@"")];
    
    return rightUtilityButtons;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if ([[groups objectAtIndex:indexPath.row] thread])
        {
            NSLog(@"Has a thread. Open chat view");
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GroupChatViewController *groupChat = [storyboard instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
            [groupChat setTitle:[[groups objectAtIndex:indexPath.row] getName]];
            [groupChat setChatViewItem:(NSObject<ChatViewItem>*)[[groups objectAtIndex:indexPath.row] thread]];
            [self.navigationController pushViewController:groupChat animated:YES];
        }
        else
        {
            NSLog(@"Don't have a thread. Create one then open the chat view");
            
            [ThreadWrapper createThreadForGroup:[groups objectAtIndex:indexPath.row]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GroupChatViewController *groupChat = [storyboard instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
            [groupChat setTitle:[[groups objectAtIndex:indexPath.row] getName]];
            [groupChat setChatViewItem:(NSObject<ChatViewItem>*)[[groups objectAtIndex:indexPath.row] thread]];
            [self.navigationController pushViewController:groupChat animated:YES];
        }
    }
}


#pragma mark - SWTableViewDelegate

//- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
//    switch (index) {
//        case 0:
//            NSLog(@"left button 0 was pressed");
//            break;
//        case 1:
//            NSLog(@"left button 1 was pressed");
//            break;
//        case 2:
//            NSLog(@"left button 2 was pressed");
//            break;
//        case 3:
//            NSLog(@"left btton 3 was pressed");
//        default:
//            break;
//    }
//}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
//        case 0:
//        {
//            NSLog(@"More button was pressed");
//            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Destructive Button" otherButtonTitles:@"Other button 1",@"Other button 2", nil];
//            [actionSheet showInView:self.view];
//            
//            [cell hideUtilityButtonsAnimated:YES];
//            break;
//        }
        case 0:
        {
            // Ping button was pressed
            NSLog(@"PING");
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            Group *g = [groups objectAtIndex:cellIndexPath.row];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];

            // Push
            NSDictionary *push;
            
            if ([[[g doNotNotify]doNotNotifyMembers]count] == 0) {
                push = [Push createPushForPingWithName:[[MyselfObject sharedInstance]getName]];
            }else{
                push = [Push createSilentPushForPingWithName:[[MyselfObject sharedInstance]getName]];
            }
            
            [PPLocationManager getDevicePosition:g.tag withAccuracy:300 andTimeout:30 AndInbox:mapVC.pingInbox AndOptions:@{@"push": push}];
            
            [self.navigationController pushViewController:mapVC animated:YES];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Leave button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            Group *g = [groups objectAtIndex:cellIndexPath.row];
            
            [GroupOverlord leaveGroup:g.tag];
            
            [groups removeObject:g];
            
            [self.tableView beginUpdates];
            
            [groups removeObject:g];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            [deletedGroups addObject:g];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:deletedGroups.count-1 inSection:1];
            [self.tableView insertRowsAtIndexPaths:@[indexPath2] withRowAnimation:UITableViewRowAnimationRight];
            
            [self.tableView endUpdates];
                        
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

//#pragma mark - UIActionSheetDelegate
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    switch (buttonIndex) {
//        case 0:
//            NSLog(@"index 0: Destructive button");
//            break;
//        case 1:
//            NSLog(@"index 1: Other 1");
//            break;
//        case 2:
//            NSLog(@"index 2: Other 2");
//            break;
//        case 3:
//            NSLog(@"index 3: Cancel");
//            break;
//        default:
//            break;
//    }
//}

-(void)joinButtonClicked:(UIButton*)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    Group *g = [deletedGroups objectAtIndex:indexPath.row];
    
    NSLog(@"joinButtonClicked - Group: %@", g);

    [GroupOverlord joinGroup:g.tag];
    
    [deletedGroups removeObject:g];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [groups addObject:g];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:groups.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath2] withRowAnimation:UITableViewRowAnimationRight];
}

-(void)newChangeWithKey:(NSString *)key
{
    if ([key isEqualToString:kNewGroup] || [key isEqualToString:kDeletedGroup])
    {
        [self reloadTableView];
    }
}


@end