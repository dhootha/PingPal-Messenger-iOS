//
//  IntroViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 29/07/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "IntroViewController.h"
#import "UIImage+ImageEffects.h"
#import <FacebookSDK/FacebookSDK.h>

@interface IntroViewController (){
    UIScrollView *scrollView;
    UIImageView *scrollViewBackground;
    UIImage *standardImage;
    UIImage *blurredImage;
    UIPageControl *introPageControl;
    UIButton *scrollButton;
    NSMutableArray *pages;
    int width;
    
    UIView *startView;
    UIImageView *startImageView;
    UILabel *startTitleLabel;
    UIView *startBottomView;
    UILabel *startLabel;
    UILabel *startLabel2;
    UIButton *startButton;
    
    FBLoginView *fbLoginButton;
}

@end

@implementation IntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Self
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Pages
    pages = [[NSMutableArray alloc]init];
    [self createPages];

    // ScrollView
    scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    [scrollView setDelegate:self];
    [scrollView setPagingEnabled:YES];
    
    // Images
    // Only retina images, it did not work otherwise 
    if (IS_IPHONE_5)
    {
        UIImage *img = [UIImage imageNamed:@"intro_screen568h@2x.png"];
        UIImage *img2 = [self croppingImageByImageName:img toRect:CGRectMake(0, img.size.height-320, img.size.width, 320)];
        standardImage = [self imageByCombiningImage:img withImage:img2];
        blurredImage = [[UIImage imageNamed:@"intro_screen568h@2x.png"]applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.1] saturationDeltaFactor:1.4 maskImage:nil];
    }
    else
    {
        UIImage *img = [UIImage imageNamed:@"intro_screen@2x.png"];
        UIImage *img2 = [self croppingImageByImageName:img toRect:CGRectMake(0, img.size.height-320, img.size.width, 320)];
        standardImage = [self imageByCombiningImage:img withImage:img2];
        blurredImage = [[UIImage imageNamed:@"intro_screen@2x.png"]applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.1] saturationDeltaFactor:1.4 maskImage:nil];
    }
    
    // ScrollView Background
    scrollViewBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [scrollViewBackground setImage:standardImage];
    
    //Page control
    introPageControl = [[UIPageControl alloc] init];
    introPageControl.frame = CGRectMake(0, self.view.frame.size.height-75, 320, 20);
    [introPageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [introPageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    introPageControl.numberOfPages = pages.count;
    introPageControl.currentPage = 0;
    //[introPageControl setBackgroundColor:[[UIColor greenColor]colorWithAlphaComponent:.5]];
    
    // ScrollButton
    scrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scrollButton setFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
    [scrollButton setBackgroundColor:UIColorFromRGB(0x48BB90)];
    [scrollButton setTitle:NSLocalizedString(@"Next", @"") forState:UIControlStateNormal];
    [scrollButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scrollButton addTarget:self action:@selector(scrollButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // FacebookConnector listener
    [[FacebookConnector sharedInstance]setLoginListener:self];
    
    // FBLoginView
    fbLoginButton = [[FBLoginView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-48, scrollButton.frame.size.width, scrollButton.frame.size.height)];
    fbLoginButton.readPermissions = @[@"public_profile", @"user_friends"];
    [fbLoginButton setDelegate:[FacebookConnector sharedInstance]];
    
    [self createStartView];
    
    [self.view addSubview:scrollViewBackground];
    [self.view addSubview:scrollView];
    [self.view addSubview:scrollButton];
    [self.view addSubview:introPageControl];
    
    [self.view addSubview:startView];
}

- (UIImage *)croppingImageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return [cropped applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.1] saturationDeltaFactor:1.4 maskImage:nil];
}

- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage
{
    UIImage *image = nil;
    
    UIGraphicsBeginImageContext(CGSizeMake(firstImage.size.width, firstImage.size.height));
    
    [firstImage drawAtPoint:CGPointMake(0,0)];
    [secondImage drawAtPoint:CGPointMake(0, firstImage.size.height-secondImage.size.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for ( UIView *v in pages )
    {
        [scrollView addSubview: v];
        width += v.frame.size.width;
    }
    
    scrollView.contentSize = CGSizeMake(width, self.view.frame.size.height);
    
    [self performSelector:@selector(animateFirstPage) withObject:nil afterDelay:.5];
}

-(void)animateFirstPage
{
    [UIView animateWithDuration:0.7
                     animations:^{
                         
                         [startImageView setFrame:CGRectMake(0, -90, 320, self.view.frame.size.height)];
                         [startBottomView setFrame:CGRectMake(-1, self.view.frame.size.height-181, 322, 181)];

                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
    
    [startImageView addSubview:startTitleLabel];
    
    [startImageView setImage:[startImageView.image applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1.0 alpha:0.1] saturationDeltaFactor:1.4 maskImage:nil]];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [startImageView.layer addAnimation:transition forKey:nil];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)createStartView
{
    startView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImage *startImage;
    if (IS_IPHONE_5){
        startImage = [UIImage imageNamed:@"PingPalMessengerIntro568h@2x.png"];
    }else{
        startImage = [UIImage imageNamed:@"PingPalMessengerIntro@2x.png"];
    }
    
    NSLog(@"startImage size: %@", NSStringFromCGSize(startImage.size));
    
    startImageView = [[UIImageView alloc]initWithImage:startImage];
    [startImageView setFrame:startView.frame];
    
    NSLog(@"startImage size: %@", NSStringFromCGSize(startImage.size));
    
    startTitleLabel = [[UILabel alloc]init];
    [startTitleLabel setText:@"PingPal Messenger"];
    [startTitleLabel setTextColor:[UIColor whiteColor]];
    [startTitleLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [startTitleLabel setShadowColor:[UIColor blackColor]];
    [startTitleLabel setShadowOffset:CGSizeMake(1, 1)];
    [startTitleLabel sizeToFit];
    [startTitleLabel setCenter:self.view.center];
    
    [startView addSubview:startImageView];
    
    startBottomView = [[UIView alloc]initWithFrame:CGRectMake(-1, self.view.frame.size.height+1, 322, 181)];
    [startBottomView setBackgroundColor:[UIColor whiteColor]];
    [startBottomView.layer setBorderWidth:.5];
    [startBottomView.layer setBorderColor:[UIColor colorWithWhite:0 alpha:.2].CGColor];
    
    startLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 40)];
    [startLabel setTextAlignment:NSTextAlignmentCenter];
    [startLabel setTextColor:[UIColor blackColor]];
    [startLabel setText:NSLocalizedString(@"StartWelcome", @"")];
    [startLabel setFont:[UIFont boldSystemFontOfSize:19]];
    
    startLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 320, 50)];
    [startLabel2 setTextAlignment:NSTextAlignmentCenter];
    [startLabel2 setTextColor:[UIColor blackColor]];
    [startLabel2 setText:NSLocalizedString(@"StartText", @"")];
    [startLabel2 setFont:[UIFont systemFontOfSize:16]];
    
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton setFrame:CGRectMake(40, startBottomView.frame.size.height-50, 240, 40)];
    [startButton setBackgroundColor:UIColorFromRGB(0x48BB90)];
    [startButton.layer setCornerRadius:20];
    [startButton setTitle:NSLocalizedString(@"GetStarted", @"") forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [startBottomView addSubview:startLabel];
    [startBottomView addSubview:startLabel2];
    [startBottomView addSubview:startButton];
    [startView addSubview:startBottomView];
}

-(void)startButtonClicked
{    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [startView setFrame:CGRectMake(-320, 0, 320, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [startView removeFromSuperview];
                     }];
}

-(UILabel*)createPageTitleLabelWithText:(NSString*)text
{
    UILabel *pageTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-155, 320, 30)];
    [pageTitleLabel setText:text];
    [pageTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [pageTitleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    [pageTitleLabel setTextColor:[UIColor whiteColor]];
    [pageTitleLabel setShadowColor:[UIColor blackColor]];
    [pageTitleLabel setShadowOffset:CGSizeMake(1, 1)];
    
    //[pageTitleLabel setBackgroundColor:[[UIColor redColor]colorWithAlphaComponent:.5]];

    return pageTitleLabel;
}

-(UILabel*)createPageLabelWithText:(NSString*)text
{
    UILabel *pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-125, 320, 50)];
    [pageLabel setText:text];
    [pageLabel setTextAlignment:NSTextAlignmentCenter];
    [pageLabel setNumberOfLines:0];
    [pageLabel setFont:[UIFont systemFontOfSize:18]];
    [pageLabel setTextColor:[UIColor whiteColor]];
    [pageLabel setShadowColor:[UIColor blackColor]];
    [pageLabel setShadowOffset:CGSizeMake(1, 1)];
    
    //[pageLabel setBackgroundColor:[[UIColor blueColor]colorWithAlphaComponent:.5]];
    
    return pageLabel;
}

-(void)createPages
{
    // Page1
    UIView *page1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-50)];
    [page1 addSubview:[self createPageTitleLabelWithText:NSLocalizedString(@"Page1Title", @"")]];
    [page1 addSubview:[self createPageLabelWithText:NSLocalizedString(@"Page1Text", @"")]];
    
    // Page 2
    UIView *page2 = [[UIView alloc]initWithFrame:CGRectMake(320, 0, 320, self.view.frame.size.height-50)];
    [page2 addSubview:[self createPageTitleLabelWithText:NSLocalizedString(@"Page2Title", @"")]];
    [page2 addSubview:[self createPageLabelWithText:NSLocalizedString(@"Page2Text", @"")]];
    
    // Page 3
    UIView *page3 = [[UIView alloc]initWithFrame:CGRectMake(640, 0, 320, self.view.frame.size.height-50)];
    [page3 addSubview:[self createPageTitleLabelWithText:NSLocalizedString(@"Page3Title", @"")]];
    [page3 addSubview:[self createPageLabelWithText:NSLocalizedString(@"Page3Text", @"")]];
    
    [pages addObject:page1];
    [pages addObject:page2];
    [pages addObject:page3];
}

-(void)scrollButtonClicked
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    switch (page) {
        case 0:
            //NSLog(@"First page button clicked");
            [self scrollToIndex:1];
            break;
        case 1:
            //NSLog(@"Second page button clicked");
            [self scrollToIndex:2];
            break;
        case 2:
            //NSLog(@"Third page button clicked");
            [self done];
            break;
            
        default:
            break;
    }
}

-(void)scrollToIndex: (int)x{
    CGRect bottomFrame = scrollView.frame;
    bottomFrame.origin.x = bottomFrame.size.width * x;
    bottomFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [scrollView scrollRectToVisible:bottomFrame animated:NO];
                     }completion:^(BOOL finished){
                     }];
}

-(void)done
{
    [self.delegate introDone];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view setFrame:CGRectMake(0, self.view.frame.size.height, 320, self.view.frame.size.height)];
                     }completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];
}

-(void)blurrScrollViewBackgroundImage
{
    if (scrollViewBackground.image != blurredImage)
    {
        NSLog(@"blurrScrollViewBackgroundImage");

        [scrollViewBackground setImage:blurredImage];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [scrollViewBackground.layer addAnimation:transition forKey:nil];
    }
}

-(void)clearScrollViewBackground
{
    if (scrollViewBackground.image != standardImage)
    {
        NSLog(@"clearScrollViewBackground");
        
        [scrollViewBackground setImage:standardImage];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [scrollViewBackground.layer addAnimation:transition forKey:nil];
    }
}


#pragma mark - scrollView Delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView2
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    introPageControl.currentPage = page;
    
    switch (page) {
        case 0:
            //NSLog(@"First page");
            [self clearScrollViewBackground];
            //[scrollButton setTitle:@"Next" forState:UIControlStateNormal];
            break;
        case 1:
            //NSLog(@"Second page");
            [self blurrScrollViewBackgroundImage];
            if (fbLoginButton.superview != nil) {
                [fbLoginButton removeFromSuperview];
            }
            [scrollButton setTitle:NSLocalizedString(@"Next", @"") forState:UIControlStateNormal];
            break;
        case 2:
            //NSLog(@"Third page");
            if (fbLoginButton.superview == nil && ![FBSession.activeSession isOpen]){
                [self.view addSubview:fbLoginButton];
            }
            [scrollButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark - fbLoginStatusListener

-(void)loggedIn
{
    if (fbLoginButton.superview != nil) {
        [fbLoginButton removeFromSuperview];
    }
}

-(void)loggedOut{}
-(void)loggedInWithName:(NSString *)name andID:(NSString *)id{}


@end