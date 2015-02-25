//
//  IntroViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 29/07/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookConnector.h"

@protocol IntroViewDelegate;

@interface IntroViewController : UIViewController <UIScrollViewDelegate, fbLoginStatusListener>

@property NSObject<IntroViewDelegate> *delegate;

@end



@protocol IntroViewDelegate <NSObject>

@required
-(void)introDone;

@end