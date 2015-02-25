//
//  TableViewTopView.m
//  PingPal Messenger
//
//  Created by André Hansson on 06/05/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "TableViewTopView.h"

@implementation TableViewTopView

+(UIView *)createTableViewTopView
{
    UIImage *image = [UIImage imageNamed:@"PingPalLogo_inverted.png"]; // 230 × 76
    UIImageView *imageV = [[UIImageView alloc]initWithImage:image];
    [imageV setFrame:CGRectMake(45, 424, 230, 76)];
    [imageV setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(-1, -500, 322, 500)];
    [topView setBackgroundColor:UIColorFromRGB(0x48BB90)];
    [topView.layer setBorderColor:[UIColor grayColor].CGColor];
    [topView.layer setBorderWidth:1];
    [topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [topView addSubview:imageV];
    
    return topView;
}

@end