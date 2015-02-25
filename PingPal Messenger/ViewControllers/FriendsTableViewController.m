//
//  FriendsTableViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-18.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "SWRevealViewController.h"
#import "FriendWrapper.h"
#import "Friend.h"
#import "CFacebook.h"
#import "ChatViewController.h"
#import "ThreadWrapper.h"
#import "TableItem.h"
#import "MapViewController.h"
#import "TableViewTopView.h"
#import "MyselfObject.h"
#import "Push.h"
#import "OutboxHandler.h"

#import <PPLocationManager/PPLocationManager.h>

@interface FriendsTableViewController (){
    NSMutableArray *sections;
    NSMutableArray *friends;
    NSMutableArray *deletedFriends;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation FriendsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[OutboxHandler sharedInstance]checkFriends];
    
    sections = [[NSMutableArray alloc]initWithArray:@[NSLocalizedString(@"FriendsSection", @"FriendsSection"), NSLocalizedString(@"DeletedFriendsSection", @"DeletedFriendsSection")]];
    
    friends = [[NSMutableArray alloc]init];
    deletedFriends = [[NSMutableArray alloc]init];
    
    // Image above tableView
    [self.tableView addSubview:[TableViewTopView createTableViewTopView]];
    
    // TableView appearance
    [self.tableView setSeparatorColor:UIColorFromRGB(0x48BB90)];
    
    // ***** Side menu *****
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Fetch friends
    [friends addObjectsFromArray:[FriendWrapper fetchAllNonDeletedFriendsWithSortKey:@"getName" ascending:YES]];
    [deletedFriends addObjectsFromArray:[FriendWrapper fetchAllDeletedFriendsWithSortKey:@"getName" ascending:YES]];
    
    //NSLog(@"Friends: %@", friends);
    //NSLog(@"deleted friends:  %@", deletedFriends);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [friends count];
    }else{
        return [deletedFriends count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
        
        FriendCell __weak *weakCell = cell;
        
        [cell setAppearanceWithBlock:^{
            weakCell.leftUtilityButtons = NULL;
            weakCell.rightUtilityButtons = [self rightButtons];
            weakCell.delegate = self;
            weakCell.containingTableView = tableView;
        } force:NO];
        
        [cell setCellHeight:cell.frame.size.height];
        
        NSLog(@"ImageFilePath: %@",[[friends objectAtIndex:indexPath.row] getImageFilePath]);
        
        [cell.nameLabel setText:[(NSObject<TableItem>*)[friends objectAtIndex:indexPath.row] getName]];
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:[(NSObject<TableItem>*)[friends objectAtIndex:indexPath.row] getImageFilePath]];
        if (image) {
            [cell.avatarImageView setImage:image];
        }else{
            [cell.avatarImageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"deletedFriendCell" forIndexPath:indexPath];
        
        FriendCell __weak *weakCell = cell;
        
        [cell setAppearanceWithBlock:^{
            weakCell.leftUtilityButtons = NULL;
            weakCell.rightUtilityButtons = NULL;
            weakCell.delegate = self;
            weakCell.containingTableView = tableView;
        } force:NO];
        
        [cell setCellHeight:cell.frame.size.height];
        
        [cell.nameLabel setText:[(NSObject<TableItem>*)[deletedFriends objectAtIndex:indexPath.row] getName]];
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:[(NSObject<TableItem>*)[deletedFriends objectAtIndex:indexPath.row] getImageFilePath]];
        if (image) {
            [cell.avatarImageView setImage:image];
        }else{
            [cell.avatarImageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
        }
        [cell.restoreButton addTarget:self action:@selector(restoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [cell.avatarImageView.layer setCornerRadius:27];
    [cell.avatarImageView setClipsToBounds:YES];
    
    // selectedBackgroundView
    UIView *sbv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [sbv setBackgroundColor:UIColorFromRGB(0x48BB90)];
    [cell setSelectedBackgroundView:sbv];
    
    return cell;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 0;
//    }
//    
//    return [tableView sectionHeaderHeight];
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        return nil;
//    }
    
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
                                                title:NSLocalizedString(@"Delete",@"")];
    
    return rightUtilityButtons;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if ([[friends objectAtIndex:indexPath.row] thread])
        {
            NSLog(@"Has a thread. Open chat view");
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatViewController *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            [chatVC setTitle:[[friends objectAtIndex:indexPath.row] getName]];
            [chatVC setChatViewItem:(NSObject<ChatViewItem>*)[[friends objectAtIndex:indexPath.row] thread]];
            [self.navigationController pushViewController:chatVC animated:YES];
        }
        else
        {
            NSLog(@"Don't have a thread. Create one then open the chat view");
            
            [ThreadWrapper createThreadForFriend:[friends objectAtIndex:indexPath.row]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatViewController *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            [chatVC setTitle:[[friends objectAtIndex:indexPath.row] getName]];
            [chatVC setChatViewItem:(NSObject<ChatViewItem>*)[[friends objectAtIndex:indexPath.row] thread]];
            [self.navigationController pushViewController:chatVC animated:YES];
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

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
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
            Friend *f = [friends objectAtIndex:cellIndexPath.row];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            
            // Push
            NSDictionary *push = [Push createPushForPingWithName:[[MyselfObject sharedInstance]getName]];

            [PPLocationManager getDevicePosition:f.tag withAccuracy:300 andTimeout:30 AndInbox:mapVC.pingInbox AndOptions:@{@"push": push}];
            
            [self.navigationController pushViewController:mapVC animated:YES];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            Friend *f = [friends objectAtIndex:cellIndexPath.row];
            
            [FriendWrapper deleteFriend:f];
            
            [friends removeObject:f];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            [deletedFriends addObject:f];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:deletedFriends.count-1 inSection:1];
            [self.tableView insertRowsAtIndexPaths:@[indexPath2] withRowAnimation:UITableViewRowAnimationRight];
            
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


-(void)restoreButtonClicked:(UIButton*)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    Friend *f = [deletedFriends objectAtIndex:indexPath.row];
    
    [FriendWrapper restoreDeletedFriend:f];
    
    [deletedFriends removeObject:f];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [friends addObject:f];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:friends.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath2] withRowAnimation:UITableViewRowAnimationRight];
}


@end