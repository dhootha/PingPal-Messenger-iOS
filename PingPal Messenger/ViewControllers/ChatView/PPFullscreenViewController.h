//
//  PPFullscreenImageViewController.h
//  PPChatTableView
//
//  Created by André Hansson on 12/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PPFullscreenViewController : UIViewController <UIScrollViewDelegate>

-(id)initWithImage:(UIImage*)image;

-(id)initWithMapView:(MKMapView*)mapView;

@end