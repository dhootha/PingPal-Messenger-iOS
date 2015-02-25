//
//  PPChatTableView.m
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "PPChatTableView.h"

#import "PPMessageData.h"
#import "PPChatTableViewCell.h"
#import "PPChatImageTableViewCell.h"
#import "PPChatHeaderTableViewCell.h"
#import "PPChatTypingTableViewCell.h"

@interface PPChatTableView ()

@property (nonatomic, retain) NSMutableArray *bubbleSection;

@end

@implementation PPChatTableView


#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[self setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    // PPChatTableView default properties
    self.snapInterval = 120;
    self.typingBubble = PPTypingTypeNobody;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}


#pragma mark - Override

- (void)reloadData
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.bubbleSection = nil;
    
    // Loading new data
    NSInteger count = 0;

    self.bubbleSection = [[NSMutableArray alloc] init];
    
    if (self.PPDataSource && (count = [self.PPDataSource rowsForChatTable:self]) > 0)
    {
        NSMutableArray *messageData = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.PPDataSource chatTableView:self dataForRow:i];
            assert([object isKindOfClass:[PPMessageData class]]);
            [messageData addObject:object];
        }
        
        [messageData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             PPMessageData *messageData1 = (PPMessageData *)obj1;
             PPMessageData *messageData2 = (PPMessageData *)obj2;
             
             return [messageData1.date compare:messageData2.date];
         }];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        
        for (int i = 0; i < count; i++)
        {
            PPMessageData *data = (PPMessageData *)[messageData objectAtIndex:i];
            
            if ([data.date timeIntervalSinceDate:last] > self.snapInterval)
            {
                currentSection = [[NSMutableArray alloc] init];
                
                [self.bubbleSection addObject:currentSection];
            }
            
            [currentSection addObject:data];
            last = data.date;
        }
    }
    
    [super reloadData];
}


#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger result = [self.bubbleSection count];
    if (self.typingBubble != PPTypingTypeNobody) result++;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing bubble
	if (section >= [self.bubbleSection count]) return 1;
    
    return [[self.bubbleSection objectAtIndex:section] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        static NSString *cellId = @"PPTypingCell";
        PPChatTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) cell = [[PPChatTypingTableViewCell alloc] init];
        
        cell.type = self.typingBubble;
        cell.showAvatar = self.showAvatars;
        
        return cell;
    }
    
    // Header with date and time
    if (indexPath.row == 0)
    {
        static NSString *cellId = @"PPHeaderCell";
        PPChatHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        PPMessageData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:0];
        
        if (cell == nil) cell = [[PPChatHeaderTableViewCell alloc] init];
        
        cell.date = data.date;
                
        return cell;
    }
    
    // Message
    PPMessageData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    
    if (data.style == PPMessageStyleImage || data.style == PPMessageStyleMap)
    {
        // Image
        static NSString *cellId = @"PPImageCell";
        PPChatImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) cell = [[PPChatImageTableViewCell alloc] init];
        
        cell.data = data;
        cell.showAvatar = self.showAvatars;
        cell.showOnlySomeoneElseAvatar = self.showOnlySomeoneElseAvatar;
        
        return cell;
    }
    
    // Standard bubble
    static NSString *cellId = @"PPCell";
    PPChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) cell = [[PPChatTableViewCell alloc] init];
        
    cell.data = data;
    cell.showAvatar = self.showAvatars;
    cell.showOnlySomeoneElseAvatar = self.showOnlySomeoneElseAvatar;
    
    return cell;
}


#pragma mark - UITableViewDelegate implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        return MAX([PPChatTypingTableViewCell height], self.showAvatars ? 52 : 0);
    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [PPChatHeaderTableViewCell height];
    }
    
    PPMessageData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    if (data.style != PPMessageStyleImage)
    {
        return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom + 20, self.showAvatars ? 52 : 0);
    }
    else
    {
        return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom, self.showAvatars ? 52 : 0);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= [self.bubbleSection count] || indexPath.row == 0){
        // Typing or header
        return;
    }

    PPMessageData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    [self.PPDelegate chatTableViewDidSelectRowWithData:data];
}


#pragma mark - Public interface

- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated
{
    NSInteger lastSectionIdx = [self numberOfSections] - 1;
    
    if (lastSectionIdx >= 0)
    {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self numberOfRowsInSection:lastSectionIdx] - 1) inSection:lastSectionIdx] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


@end