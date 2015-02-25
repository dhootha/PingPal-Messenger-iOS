//
//  MapViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-04.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "MapViewController.h"
//#import <Mapbox/Mapbox.h>
#import <MapKit/MapKit.h>
#import "FriendWrapper.h"
#import "MyselfObject.h"

@interface MapViewController (){
    // Mapbox
    // RMMapView *mapView;
    
    // Mapkit
    MKMapView *mapView;
    //MKPointAnnotation *point;

    // Loading view
    UIActivityIndicatorView *activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
}

@end

@implementation MapViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        NSLog(@"MapViewController initWithCoder");
        
        __weak typeof(self) weakSelf = self;
        
        _pingInbox = ^(id payload, id meta, Outbox *outbox){
            NSLog(@"pingInbox payload: %@. Meta: %@", payload, meta);
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf)
            {
                // Remove the loading view
                if ([strongSelf->activityView isAnimating]) {
                    [strongSelf->activityView stopAnimating];
                    [strongSelf->loadingView removeFromSuperview];
                }
                
                BOOL isMyLocation = NO;
                
                NSString *sender = meta[@"from"];
                
                Friend *friend;
                
                if ([sender isEqualToString: [[MyselfObject sharedInstance]getUserTag] ]) {
                    // My location
                    isMyLocation = YES;
                }else{
                    friend = [FriendWrapper fetchFriendWithTag:sender];
                }
                
                NSDictionary *dict = payload[@"location"];
                
                CLLocation *location = [[CLLocation alloc]initWithLatitude:[dict[@"latitude"]doubleValue] longitude:[dict[@"longitude"]doubleValue]];
                
                [strongSelf setRegion:location.coordinate];
                
                MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
                point.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
                if (isMyLocation) {
                    point.title = @"Me";
                }else{
                    point.title = [friend getName];
                }
                
                [strongSelf->mapView addAnnotation:point];
            }
        };
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Mapbox
//    NSString *mapID = @"andrehansson.gohmm79e";
//    RMMapboxSource *mbSource = [[RMMapboxSource alloc]initWithMapID:mapID];
//    
//    mapView = [[RMMapView alloc]initWithFrame:self.view.frame andTilesource:mbSource];
//    [mapView setShowsUserLocation:YES];
//    [mapView setUserTrackingMode:RMUserTrackingModeFollow animated:YES];
//    [mapView setZoom:14];
//    
//    [mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    
//    [self.view addSubview:mapView];
    
    
    // Mapkit
    mapView = [[MKMapView alloc]initWithFrame:self.view.frame];
    [mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

    [self.view addSubview:mapView];
    
    // Loading view
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 10.0;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 40, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
    
    [self.view addSubview:loadingView];
    [activityView startAnimating];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)setRegion:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000);
    [mapView setRegion:region animated:YES];
}


@end