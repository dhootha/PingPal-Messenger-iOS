//
//  PPChatHeaderTableViewCell.m
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "PPChatHeaderTableViewCell.h"

@interface PPChatHeaderTableViewCell ()

@property (nonatomic, retain) UILabel *label;

@end

@implementation PPChatHeaderTableViewCell

+ (CGFloat)height
{
    return 28.0;
}

- (void)setDate:(NSDate *)value
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *text = [dateFormatter stringFromDate:value];
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [PPChatHeaderTableViewCell height])];
    self.label.text = text;
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.shadowOffset = CGSizeMake(0, 1);
    self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:self.label];
}

@end