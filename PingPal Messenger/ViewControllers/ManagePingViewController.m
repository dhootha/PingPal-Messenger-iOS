//
//  ManagePingViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 15/09/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "ManagePingViewController.h"
#import "SWRevealViewController.h"
#import "ManagePingCell.h"
#import "FriendWrapper.h"
#import "TableViewTopView.h"

@interface ManagePingViewController (){
    NSMutableArray *yes;
    NSMutableArray *no;
    NSMutableArray *ask;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;

@end

@implementation ManagePingViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // ***** Side menu *****
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Image above tableView
    [self.friendsTableView addSubview:[TableViewTopView createTableViewTopView]];

    // Load friends
    yes = [[NSMutableArray alloc]init];
    no = [[NSMutableArray alloc]init];
    ask = [[NSMutableArray alloc]init];
    
    for (Friend *friend in [FriendWrapper fetchAllFriendsWithSortKey:@"getName" ascending:YES])
    {
        if (friend.pingAccess == accessYes)
        {
            [yes addObject:friend];
        }
        else if (friend.pingAccess == accessNo)
        {
            [no addObject:friend];
        }
        else
        {
            [ask addObject:friend];
        }
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if ([self.segmentedControl selectedSegmentIndex] == 0) {
        return yes.count;
    }else if ([self.segmentedControl selectedSegmentIndex] == 1){
        return ask.count;
    }else{
        return no.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManagePingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"managePingCell" forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSMutableArray *array;
    
    for (UIGestureRecognizer *gr in cell.gestureRecognizers) {
        [cell removeGestureRecognizer:gr];
    }
    
    if ([self.segmentedControl selectedSegmentIndex] == 0)
    {
        [cell addGestureRecognizer:[self rightSwipeGestureRecognizer]];
        array = yes;
    }
    else if ([self.segmentedControl selectedSegmentIndex] == 2)
    {
        [cell addGestureRecognizer:[self leftSwipeGestureRecognizer]];
        array = no;
    }
    else
    {
        [cell addGestureRecognizer:[self rightSwipeGestureRecognizer]];
        [cell addGestureRecognizer:[self leftSwipeGestureRecognizer]];
        array = ask;
    }
    
    [cell.avatarImageView setImage:[[UIImage alloc]initWithContentsOfFile:[(NSObject<TableItem>*)[array objectAtIndex:indexPath.row] getImageFilePath]]];
    [cell.avatarImageView.layer setCornerRadius:27];
    [cell.avatarImageView setClipsToBounds:YES];
    
    [cell.nameLabel setText:[(NSObject<TableItem>*)[array objectAtIndex:indexPath.row] getName]];
    
    return cell;
}


#pragma mark - GestureRecognizers

-(UISwipeGestureRecognizer*)leftSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    return left;
}

-(void)leftSwipe:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    ManagePingCell *cell = (ManagePingCell*)swipeGestureRecognizer.view;
    
    NSIndexPath *indexPath = [self.friendsTableView indexPathForCell:cell];
    
    if ([self.segmentedControl selectedSegmentIndex] == 1)
    {
        Friend *friend = [ask objectAtIndex:indexPath.row];
        [ask removeObject:friend];
        [yes addObject:friend];
        [friend setPingAccess:accessYes];
    }
    else if ([self.segmentedControl selectedSegmentIndex] == 2)
    {
        Friend *friend = [no objectAtIndex:indexPath.row];
        [no removeObject:friend];
        [ask addObject:friend];
        [friend setPingAccess:accessAsk];
    }
    
    [self.friendsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(UISwipeGestureRecognizer*)rightSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    [right setDirection:UISwipeGestureRecognizerDirectionRight];
    
    return right;
}

-(void)rightSwipe:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    ManagePingCell *cell = (ManagePingCell*)swipeGestureRecognizer.view;
    
    NSIndexPath *indexPath = [self.friendsTableView indexPathForCell:cell];
    
    if ([self.segmentedControl selectedSegmentIndex] == 0)
    {
        Friend *friend = [yes objectAtIndex:indexPath.row];
        [yes removeObject:friend];
        [ask addObject:friend];
        [friend setPingAccess:accessAsk];
    }
    else if ([self.segmentedControl selectedSegmentIndex] == 1)
    {
        Friend *friend = [ask objectAtIndex:indexPath.row];
        [ask removeObject:friend];
        [no addObject:friend];
        [friend setPingAccess:accessNo];
    }
    
    [self.friendsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}


#pragma mark - SegmentedControl

- (IBAction)segmentedControlChanged:(UISegmentedControl *)sender
{
    [self.friendsTableView reloadData];
}

@end