//
//  OrientationNavigationController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-30.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "OrientationNavigationController.h"

@interface OrientationNavigationController ()

@end

@implementation OrientationNavigationController


// Ask the topViewController for supportedInterfaceOrientations

-(NSUInteger)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
}

@end