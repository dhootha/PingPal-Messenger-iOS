//
//  PPFullscreenImageViewController.m
//  PPChatTableView
//
//  Created by André Hansson on 12/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "PPFullscreenViewController.h"

@interface PPFullscreenViewController (){
    // Image
    UIScrollView *imageScrollView;
    UIImageView *imageView;
    
    // doneButton
    UIButton *doneButton;
    UITapGestureRecognizer *tapGesture;
    BOOL isHidden;
}

@end

@implementation PPFullscreenViewController


#pragma mark - init

-(void)setupView
{
    [self.view setFrame:[[[UIApplication sharedApplication]delegate]window].frame];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizesSubviews:YES];
}

-(id)initWithImage:(UIImage *)image
{
    self = [super init];
    
    if (self)
    {
        [self setupView];
        
        isHidden = NO;
        tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
        [self.view addGestureRecognizer:tapGesture];
        
        imageScrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
        [imageScrollView setDelegate:self];
        [imageScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.view addSubview:imageScrollView];
        
        imageView = [[UIImageView alloc]initWithImage:image];
        [imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [imageScrollView addSubview:imageView];
        
        [imageScrollView setMinimumZoomScale:imageScrollView.frame.size.width / imageView.frame.size.width];
        [imageScrollView setMaximumZoomScale:2.0];
        [imageScrollView setZoomScale:imageScrollView.minimumZoomScale];
        
        [imageScrollView setContentSize:imageView.frame.size];
        
        [self createDoneButton];
    }
    
    return self;
}

-(id)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    
    if (self)
    {
        [self setupView];
        
        MKMapView *map = [[MKMapView alloc]initWithFrame:self.view.frame];
        [map setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [map addAnnotations:mapView.annotations];
        [self.view addSubview:map];

        MKPointAnnotation *pointAnnotation = [[map annotations]objectAtIndex:0];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pointAnnotation.coordinate, 2000, 2000);
        [map setRegion:region animated:YES];
        
        [self createDoneButton];
    }
    
    return self;
}


#pragma mark - Done Button

-(void)createDoneButton
{
    doneButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, 25, 50, 25)];
    [doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [doneButton setTitleColor:[[UIColor whiteColor]colorWithAlphaComponent:0.9] forState:UIControlStateNormal];
    
    [doneButton setBackgroundColor:[[UIColor grayColor]colorWithAlphaComponent:0.75]];
    [doneButton.layer setBorderColor:[[UIColor whiteColor] colorWithAlphaComponent:0.9].CGColor];
    [doneButton.layer setBorderWidth:1];
    [doneButton.layer setCornerRadius:3.5];
    [doneButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    
    [doneButton addTarget:self action:@selector(doneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:doneButton];
}

-(void)doneButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    imageView.frame = [self centeredFrameForScrollView:imageScrollView andUIView:imageView];
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView
{
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    return frameToCenter;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (imageView) {
        imageView.frame = [self centeredFrameForScrollView:imageScrollView andUIView:imageView];
    }
}


-(void)checkZoom
{
    
}


#pragma mark - Tap gesture

-(void)handleTapGesture:(UITapGestureRecognizer*)tapGR
{
    if (isHidden)
    {
        [UIView animateWithDuration:0.3 animations:^() {
            [doneButton setAlpha:1];
        }completion:^(BOOL finished){
            isHidden = NO;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^() {
            [doneButton setAlpha:0];
        }completion:^(BOOL finished){
            isHidden = YES;
        }];
    }
}


@end