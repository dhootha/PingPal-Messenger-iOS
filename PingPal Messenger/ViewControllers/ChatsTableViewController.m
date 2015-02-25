//
//  FriendsViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-12.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "ChatsTableViewController.h"
#import "SWRevealViewController.h"
#import "ChatViewController.h"
#import "ChatsTableViewCell.h"
#import "ChatThread.h"
#import "ThreadWrapper.h"
#import "TableViewTopView.h"
#import "MapViewController.h"
#import "MyselfObject.h"
#import "openFromNotification.h"
#import "Push.h"
#import "UIImage+ImageEffects.h"
#import "DoNotNotify.h"

#import <PPLocationManager/PPLocationManager.h>

@interface ChatsTableViewController (){
    NSMutableArray *threads;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation ChatsTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Image above tableView
    [self.tableView addSubview:[TableViewTopView createTableViewTopView]];
    
    // TableView appearance
    [self.tableView setSeparatorColor:UIColorFromRGB(0x48BB90)];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
    
    // NavigationBar appearance
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x48BB90)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // ***** Side menu *****
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    threads = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"did become active notification");
    
    if ([openFromNotification shouldOpen])
    {
        NSLog(@"appDidBecomeActive in chatsVC - should open");
        [self goToThreadWithTag:[openFromNotification TagToOpen]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self reloadThreads];
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
    // Dispose of any resources that can be recreated.
}

-(void)reloadThreads{
    [threads removeAllObjects];
    [threads addObjectsFromArray:[ThreadWrapper fetchAllThreadsWithSortKey:@"getLastDate" ascending:NO]];
    
    [self.tableView reloadData];
}

  
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return threads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[(NSObject<ChatThread>*)[threads objectAtIndex:indexPath.row] getCellIdentifier] forIndexPath:indexPath];
    
    ChatsTableViewCell __weak *weakCell = cell;
    
    [cell setAppearanceWithBlock:^{
        weakCell.leftUtilityButtons = NULL;
        weakCell.rightUtilityButtons = [self rightButtons];
        weakCell.delegate = self;
        weakCell.containingTableView = tableView;
    } force:NO];
    
    [cell setCellHeight:cell.frame.size.height];
    
    // Name
    [cell.nameLabel setText: [(NSObject<ChatThread>*)[threads objectAtIndex:indexPath.row] getName]];
    
    // Image
    [cell.avatarImageView.layer setCornerRadius:30];
    [cell.avatarImageView.layer setMasksToBounds:YES];
    
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:[(NSObject<ChatThread>*)[threads objectAtIndex:indexPath.row] getImageFilePath]];
    if (image) {
        [cell.avatarImageView setImage:image];
    }else{
        [cell.avatarImageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
    }
    
    // LastActive
    NSDate *lastActive = [(NSObject<ChatThread>*)[threads objectAtIndex:indexPath.row] getLastDate];
    if (lastActive) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        
        if ([self isSameDayWithDate1:lastActive date2:[NSDate date]]) {
            [formatter setDateFormat:@"HH:mm"];
        }else{
            [formatter setDateFormat:@"yyyy-MM-dd"];
        }
        
        [cell.lastTimeLabel setText:[formatter stringFromDate:lastActive]];
    }else{
        [cell.lastTimeLabel setText:@""];
    }
    
    // LastMessage
    [cell.lastMessageLabel setText:[(NSObject<ChatThread>*)[threads objectAtIndex:indexPath.row] getLastMessage]];
    
    // Unread
    [cell.unreadView.layer setCornerRadius:32];
    //[cell.unreadView setBackgroundColor:UIColorFromRGB(0x48BB90)];
    if ([(NSObject<ChatThread>*)[threads objectAtIndex:indexPath.row] getUnread] != 0) {
        [cell.unreadView setHidden:NO];
        [cell.unreadLabel setHidden:NO];
        [cell.unreadLabel setText:[NSString stringWithFormat:@"%d",[(NSObject<ChatThread>*)[threads objectAtIndex:indexPath.row] getUnread]]];
    }else{
        [cell.unreadView setHidden:YES];
        [cell.unreadLabel setHidden:YES];
    }
    
    // selectedBackgroundView
    UIView *sbv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [sbv setBackgroundColor:UIColorFromRGB(0x48BB90)];
    [cell setSelectedBackgroundView:sbv];
    
    return cell;
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

//- (NSArray *)leftButtons
//{
//    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
//    
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"check.png"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"clock.png"]];
////    [leftUtilityButtons sw_addUtilityButtonWithColor:
////     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
////                                                icon:[UIImage imageNamed:@"cross.png"]];
////    [leftUtilityButtons sw_addUtilityButtonWithColor:
////     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
////                                                icon:[UIImage imageNamed:@"list.png"]];
//    
//    return leftUtilityButtons;
//}

// To calculate if day1 is on same day as day2
- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:[[threads objectAtIndex:indexPath.row]getSegueIdentifier] sender:self];
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
            NSLog(@"Ping button was pressed");
            
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            Thread *t = [threads objectAtIndex:cellIndexPath.row];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            
            // Push
            NSDictionary *push;
            Group *g = (Group*)[t getGroup];
            
            if (g) {
                if ([[[g doNotNotify]doNotNotifyMembers]count] == 0) {
                    push = [Push createPushForPingWithName:[[MyselfObject sharedInstance]getName]];
                }else{
                    push = [Push createSilentPushForPingWithName:[[MyselfObject sharedInstance]getName]];
                }
            }else{
                push = [Push createPushForPingWithName:[[MyselfObject sharedInstance]getName]];
            }

            [PPLocationManager getDevicePosition:[t getTag] withAccuracy:300 andTimeout:30 AndInbox:mapVC.pingInbox AndOptions:@{@"push": push}];
            
            [self.navigationController pushViewController:mapVC animated:YES];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            [ThreadWrapper deleteThread:[threads objectAtIndex:cellIndexPath.row]];
            [threads removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}


#pragma mark - UIActionSheetDelegate

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


#pragma mark - Navigation

-(void)goToThreadWithTag:(NSString*)tag
{
    NSLog(@"goToThreadWithTag: %@", tag);
    
    Thread *threadToOpen;
    
    for (Thread *t in threads)
    {
        if ([[t getTag] isEqualToString:tag])
        {
            threadToOpen = t;
            break;
        }
    }
    
    if (!threadToOpen) {
        NSLog(@"goToThreadWithTag failed");
        return;
    }
    
    if (![[self.navigationController topViewController] isKindOfClass:[self class]]) {
        //It's in the chatView or notificationView after the chat
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    // Select row. Needed in prepareForSegue
    NSUInteger row = [threads indexOfObject:threadToOpen];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // Selecting the row programatically won't trigger prepareForSegue
    [self performSegueWithIdentifier:[threadToOpen getSegueIdentifier] sender:self];
    
    // Set to NULL or it will keep open the chatView every time
    [openFromNotification openWithTag:NULL];
}
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     [[segue destinationViewController]setTitle:[(NSObject<ChatThread>*)[threads objectAtIndex:[self.tableView indexPathForSelectedRow].row]getName]];
     
     [[segue destinationViewController]setChatViewItem:(NSObject<ChatViewItem>*)[threads objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
 }


#pragma mark - ManagedObjectChangeListener

-(void)newChangeWithKey:(NSString *)key
{
    if ([key isEqualToString:kNewThread]) {
        NSLog(@"new thread in chatsTVC");
        [self reloadThreads];
    }else if ([key isEqualToString:kDeletedThread]){
        NSLog(@"deleted thread in chatsTVC");
    }else if ([key isEqualToString:kUpdatedThread]){
        NSLog(@"updated thread in chatsTVC");
    }else if ([key isEqualToString:kNewMessage]){
         NSLog(@"new message in chatsTVC");
        [self reloadThreads];
    }
}


@end