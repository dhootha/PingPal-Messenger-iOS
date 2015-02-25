//
//  IconChooserViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 13/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol iconChooserDelegate;

@interface IconChooserViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property NSObject<iconChooserDelegate> *delegate;

@end


@protocol iconChooserDelegate <NSObject>

@optional

-(void)iconChooserDidSelectIcon:(NSString*)icon;
-(void)iconChooserDidClickCancel;

@end