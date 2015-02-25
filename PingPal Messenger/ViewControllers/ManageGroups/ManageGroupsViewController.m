//
//  ManageGroupsViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-12.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "ManageGroupsViewController.h"
#import "SWRevealViewController.h"
#import "CollectionViewController.h"
#import "GroupCollectionViewController.h"
#import "FriendsCollectionViewController.h"
#import "NewGroupViewController.h"
#import "DropViewController.h"

#import "FriendWrapper.h"
#import "GroupWrapper.h"
#import "MyselfObject.h"

#import "GroupOverlord.h"

#import "OutboxHandler.h"

#define iphoneWidth ((int) 320)

@interface ManageGroupsViewController (){
    FriendsCollectionViewController *FCVC;
    NewGroupViewController *NGVC;
    int height;
    
    // topViews
    NSMutableArray *topViewControllers;
    
    // groupsNavigationBar titleView
    UIView *groupNavigationBarTitleView;
    UIPageControl *groupNavigationBarPageControl;
    UIScrollView *groupNavigationBarScrollView;
    NSMutableArray *topTitles;
    
    // Drag&Drop
    CGRect topLocation;
    CGRect bottomLocation;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet UIScrollView *groupsScrollView;

@property (weak, nonatomic) IBOutlet UINavigationBar *friendsNavigationBar;

@property (weak, nonatomic) IBOutlet UINavigationBar *groupsNavigationBar;

@property (weak, nonatomic) IBOutlet UIView *friendsView;

@end

@implementation ManageGroupsViewController

@synthesize itemsToMove;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"ManageGroupsViewController viewDidLoad");
    
    // ***** Side menu *****
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // _groupsNavigationBar appearance
    [_groupsNavigationBar setBarTintColor:UIColorFromRGB(0x48BB90)];
    [_groupsNavigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // _friendsNavigationBar appearance
    [_friendsNavigationBar setBarTintColor:UIColorFromRGB(0x48BB90)];
    [_friendsNavigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    // DropDelegate
    itemsToMove = [[NSMutableArray alloc]init];
    
    if(IS_IPHONE_5){
        topLocation = CGRectMake(0, 64, 320, 252);
        bottomLocation = CGRectMake(0, 317, 320, 252);
    }else{
        topLocation = CGRectMake(0, 64, 320, 208);
        bottomLocation = CGRectMake(0, 273, 320, 208);
    }
    
    // TESTING for topLoacation and bottomLocation
//    UIView *top = [[UIView alloc]initWithFrame:topLocation];
//    [top setBackgroundColor:[[UIColor greenColor]colorWithAlphaComponent:.3]];
//    [top setUserInteractionEnabled:NO];
//    
//    UIView *bottom = [[UIView alloc]initWithFrame:bottomLocation];
//    [bottom setBackgroundColor:[[UIColor redColor]colorWithAlphaComponent:.3]];
//    [bottom setUserInteractionEnabled:NO];
//    
//    [self.view addSubview:top];
//    [self.view addSubview:bottom];
    
    topViewControllers = [[NSMutableArray alloc]init];
    topTitles = [[NSMutableArray alloc]init];
    
    // Height for different screen sizes
    height = 208;
    if (!IS_IPHONE_5) height = 164;
    
    // Create needed viewControllers
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FCVC = [storyboard instantiateViewControllerWithIdentifier:@"FriendsCollectionViewController"];
    NGVC = [storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
    
    [FCVC setDropDelegate:self];
    
    [FCVC addToArray:[MyselfObject sharedInstance]];
    [FCVC addToArrayFromArray:[FriendWrapper fetchAllNonDeletedFriends]];

    [_friendsView addSubview:FCVC.view];
    [self addChildViewController:FCVC];
    
    [_groupsScrollView addSubview:NGVC.view];
    [self addChildViewController:NGVC];
    
    [topViewControllers addObject:NGVC];
    [topTitles addObject:@"New group"];
    
    NSMutableArray *groups = [[GroupWrapper fetchAllNonDeletedGroupsWithSortKey:@"name" ascending:YES]mutableCopy];
    [groups addObjectsFromArray: [GroupWrapper fetchAllDeletedGroupsWithSortKey:@"name" ascending:YES]];
    
    for (Group *group in groups)
    {
        GroupCollectionViewController *gcvc = [storyboard instantiateViewControllerWithIdentifier:@"GroupCollectionViewController"];
        [gcvc setDropDelegate:self];
        [gcvc setGroup:group];
        if (!group.deletedGroup) [gcvc addToArray:[MyselfObject sharedInstance]];
        [gcvc addToArrayFromArray:[group.members allObjects]];
        [_groupsScrollView addSubview:gcvc.view];
        [self addChildViewController:gcvc];
        [topViewControllers addObject:gcvc];
        
        if (group.deletedGroup) {
            [topTitles addObject:[NSString stringWithFormat:@"Deleted: %@", group.name]];
        }else{
            [topTitles addObject:group.name];
        }
    }
    
    [_groupsScrollView setContentSize:CGSizeMake(iphoneWidth*topViewControllers.count, height)];
    
    //groupNavigationBarTitleView
    groupNavigationBarTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 44)];
    //[groupNavigationBarTitleView setBackgroundColor:[UIColor blueColor]];
    
    groupNavigationBarPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 29, 300, 15)];
    [groupNavigationBarPageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [groupNavigationBarPageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [groupNavigationBarPageControl setNumberOfPages: topViewControllers.count];
    [groupNavigationBarPageControl setCurrentPage: 0];
    [groupNavigationBarPageControl setUserInteractionEnabled:NO];
    //[groupNavigationBarPageControl.layer setBorderWidth:1];
    //[groupNavigationBarPageControl.layer setBorderColor:[UIColor blackColor].CGColor];
    
    groupNavigationBarScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 300, 28)];
    [groupNavigationBarScrollView setUserInteractionEnabled:NO];
    
    int i = 0;
    for (NSString *text in topTitles)
    {
        [groupNavigationBarScrollView addSubview:[self createGroupNavigationBarTitleLabelWithText:text andPosition:i]];
        i++;
    }
    
    [groupNavigationBarScrollView setContentSize:CGSizeMake(300*topTitles.count, 28)];
    
    [groupNavigationBarTitleView addSubview:groupNavigationBarScrollView];
    [groupNavigationBarTitleView addSubview:groupNavigationBarPageControl];
    [_groupsNavigationBar.topItem setTitleView:groupNavigationBarTitleView];
    
    // Fetch groups from server
    //[[OutboxHandler sharedInstance]listMyGroups];
    //[[OutboxHandler sharedInstance]listDeletedGroups];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Listen to changes in core data
    [[ManagedObjectChangeListener sharedInstance]addChangeListener:self];
    
    int dsa = 20;
    if (!IS_IPHONE_5) dsa = 64;
    
    //if (!IS_IPHONE_5) { // 164(height) + 108(64+44) = 272 + 44 = 316  - if navigationbar - ??
        CGRect rect = _groupsScrollView.frame;
        rect.size.height = height;
        [_groupsScrollView setFrame:rect];
        
        rect = _friendsNavigationBar.frame;
        rect.origin.y = 272-dsa;
        [_friendsNavigationBar setFrame:rect];
        
        rect = _friendsView.frame;
        rect.size.height = height;
        rect.origin.y = 316-dsa;
        [_friendsView setFrame:rect];
    //}
    
    [FCVC.view setFrame:CGRectMake(0, 0, 320, height)];
    
    for (int i = 0; i <= topViewControllers.count-1; i++) {
        UIView *view = [(UIViewController*)[topViewControllers objectAtIndex:i] view];
        [view setFrame:CGRectMake(iphoneWidth*i, 0, iphoneWidth, height)];
    }
}

-(void)viewDidLayoutSubviews
{
    int dsa = 20;
    if (!IS_IPHONE_5) dsa = 64;
    
   // if (!IS_IPHONE_5) { // 164(height) + 108(64+44) = 272 + 44 = 316
        CGRect rect = _groupsScrollView.frame;
        rect.size.height = height;
        [_groupsScrollView setFrame:rect];
        
        rect = _friendsNavigationBar.frame;
        rect.origin.y = 272-dsa;
        [_friendsNavigationBar setFrame:rect];
        
        rect = _friendsView.frame;
        rect.size.height = height;
        rect.origin.y = 316-dsa;
        [_friendsView setFrame:rect];
    //}
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // Stop listening to changes in core data
    [[ManagedObjectChangeListener sharedInstance]removeChangeListener:self];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UILabel*)createGroupNavigationBarTitleLabelWithText:(NSString*)text andPosition:(int)i
{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(320*i, 0, 300, 28)];
    [title setTextColor:[UIColor whiteColor]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setLineBreakMode:NSLineBreakByTruncatingTail];
    [title setFont:[UIFont boldSystemFontOfSize:17]];
    [title setText: text];
    
    return title;
}

-(void)reloadTopViews
{
    NSLog(@"reloadTopViews");
    
    // Remove from _groupsScrollView
    for (UIViewController *vc in topViewControllers)
    {
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
    
    // Remove title labels
    [[groupNavigationBarScrollView subviews]makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [topViewControllers removeAllObjects];
    [topTitles removeAllObjects];
    
    // Add back in
    // NewGroupViewController
    [_groupsScrollView addSubview:NGVC.view];
    [self addChildViewController:NGVC];
    [topViewControllers addObject:NGVC];
    [topTitles addObject:@"New group"];
    
    // Groups
    NSMutableArray *groups = [[GroupWrapper fetchAllNonDeletedGroupsWithSortKey:@"name" ascending:YES]mutableCopy];
    [groups addObjectsFromArray: [GroupWrapper fetchAllDeletedGroupsWithSortKey:@"name" ascending:YES]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    for (Group *group in groups)
    {
        GroupCollectionViewController *gcvc = [storyboard instantiateViewControllerWithIdentifier:@"GroupCollectionViewController"];
        [gcvc setDropDelegate:self];
        [gcvc setGroup:group];
        if (!group.deletedGroup) [gcvc addToArray:[MyselfObject sharedInstance]];
        [gcvc addToArrayFromArray:[group.members allObjects]];
        [_groupsScrollView addSubview:gcvc.view];
        [self addChildViewController:gcvc];
        [topViewControllers addObject:gcvc];
        
        if (group.deletedGroup) {
            [topTitles addObject:[NSString stringWithFormat:@"Deleted: %@", group.name]];
        }else{
            [topTitles addObject:group.name];
        }
    }
    
    [_groupsScrollView setContentSize:CGSizeMake(iphoneWidth*topViewControllers.count, height)];
    
    for (int i = 0; i <= topViewControllers.count-1; i++) {
        UIView *view = [(UIViewController*)[topViewControllers objectAtIndex:i] view];
        [view setFrame:CGRectMake(iphoneWidth*i, 0, iphoneWidth, height)];
    }
    
    [groupNavigationBarPageControl setNumberOfPages: topViewControllers.count];
    
    int i = 0;
    for (NSString *text in topTitles)
    {
        [groupNavigationBarScrollView addSubview:[self createGroupNavigationBarTitleLabelWithText:text andPosition:i]];
        i++;
    }
    
    [groupNavigationBarScrollView setContentSize:CGSizeMake(300*topTitles.count, 28)];
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    CGPoint offset = [_groupsScrollView contentOffset];
//    [groupNavigationBarScrollView setContentOffset:offset animated:YES];
    
    if (scrollView == self.groupsScrollView) {
        CGFloat pageWidth = self.groupsScrollView.frame.size.width;
        float fractionalPage = self.groupsScrollView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        groupNavigationBarPageControl.currentPage = page;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = [_groupsScrollView contentOffset];
    [groupNavigationBarScrollView setContentOffset:offset animated:YES];
    
    if (scrollView == self.groupsScrollView) {
        //[self changeGroupsNavigationBarTitle];
    }
}


#pragma mark - DropDelegate

-(void)onDrop:(CGPoint)x sender:(CollectionViewController*)sender
{
    //NSLog(@"onDrop: %@",NSStringFromCGPoint(x));
    
    if (CGRectContainsPoint(topLocation, x))
    {
        //NSLog(@"Dropped in topLocation");
        
        int viewIndex = self.groupsScrollView.contentOffset.x / iphoneWidth;
        
        NSObject<DropViewController> *dropViewController = [topViewControllers objectAtIndex:viewIndex];
        
        //NSLog(@"dropViewController: %@", dropViewController);
        
        if (![dropViewController droppedObjects:itemsToMove])
        {
            //If NO is returned
            NSLog(@"NO was returned. Items can not be dropped in this viewController");
            
            if ([sender isKindOfClass: [FriendsCollectionViewController class]])
            {
                //Inget
            }
            else
            {
                for (NSObject *obj in itemsToMove)
                {
                    [sender addToArray:obj];
                }
                [sender.collectionView reloadData];
            }
        }
        
    }
    else if (CGRectContainsPoint(bottomLocation, x))
    {
        //NSLog(@"Dropped in bottomLocation");
                
        NSObject<DropViewController> *dropViewController = FCVC; //[bottomViews objectAtIndex:viewIndex]; Only one view in bottom
        
        if ([dropViewController isKindOfClass:[FriendsCollectionViewController class]] && [sender isKindOfClass: [GroupCollectionViewController class]])
        {
            //NSMutableArray *membersToRemove = [[NSMutableArray alloc]init];
            
            for (NSObject *object in itemsToMove)
            {
                //NSLog(@"Object: %@", object);
                
                if ([object isKindOfClass:[Friend class]])
                {
                    // Remove member from group
                    [GroupOverlord removeMember:[(Friend*)object tag] fromGroup:[[(GroupCollectionViewController*)sender group]tag]];
                }
                else if ([object isKindOfClass:[MyselfObject class]])
                {
                    // Leave the group
                    [GroupOverlord leaveGroup:[[(GroupCollectionViewController*)sender group]tag]];
                }
                
                [sender removeFromArray:object];
            }
            
            [sender.collectionView reloadData];
        }
        
        if (![dropViewController droppedObjects:itemsToMove])
        {
            //If NO is returned
            NSLog(@"NO was returned. Items can not be dropped in this viewController");
            
            if ([sender isKindOfClass: [FriendsCollectionViewController class]])
            {
                //Inget
            }
            else
            {
                for (NSObject *obj in itemsToMove)
                {
                    [sender addToArray:obj];
                }
                [sender.collectionView reloadData];
            }
        }
    }
}


#pragma mark - ChangeListener

-(void)newChangeWithKey:(NSString *)key
{
    NSLog(@"ManageGroupsVC - newChangeWithKey: %@", key);

    if ([key isEqualToString:kNewGroup] || [key isEqualToString:kDeletedGroup] || [key isEqualToString:kNewDeletedGroup] || [key isEqualToString:kUpdatedFriend] || [key isEqualToString:kDeletedDeletedGroup]){
        [self reloadTopViews];
    }
}


#pragma mark - Orientation

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - DropViewController

-(BOOL)droppedObjects:(NSMutableArray *)objects{
    NSLog(@"Dropped in %@",[self description]);
    return NO;
}

@end