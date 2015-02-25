//
//  AHChatBarViewController.m
//  AHChatBarView
//
//  Created by André Hansson on 24/09/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "AHChatBarViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define keyboardHeightPortrait ((int) 216) // keyboard height in portrait mode on iPhone
#define keyboardHeightLandscape ((int) 162) // keyboard height in landscape mode on iPhone

@interface AHChatBarViewController (){
    
    // self.view Constraints
    NSLayoutConstraint *selfViewTopConstraint;
    NSLayoutConstraint *selfViewBottomConstraint;
    NSLayoutConstraint *selfViewLeftConstraint;
    NSLayoutConstraint *selfViewRightConstraint;
    
    // barView
    UIView *barView;
    
    // barView Constraints
    NSLayoutConstraint *barViewHeightConstraint;
    NSLayoutConstraint *barViewWidthConstraint;
    NSLayoutConstraint *barViewBottomConstraint;
    NSLayoutConstraint *barViewCenterXConstraint;
    
    // TextView
    UITextView *chatTextView;
    UILabel *placeholderLabel;
    
    // TextView Constraints
    NSLayoutConstraint *textViewHeightConstraint;
    NSLayoutConstraint *textViewLeftConstraint;
    NSLayoutConstraint *textViewRightConstraint;
    NSLayoutConstraint *textViewCenterYConstraint;
    
    // PlaceholderLabel Constraints
    NSLayoutConstraint *placeholderHeightConstraint;
    NSLayoutConstraint *placeholderWidthConstraint;
    NSLayoutConstraint *placeholderCenterXConstraint;
    NSLayoutConstraint *placeholderCenterYConstraint;

    // SendButton
    UIButton *sendButton;
    NSString *sendButtonSendTitle;
    NSString *sendButtonCancelTitle;
    
    // SendButton Constraints
    NSLayoutConstraint *sendButtonHeightConstraint;
    NSLayoutConstraint *sendButtonWidthConstraint;
    NSLayoutConstraint *sendButtonRightConstraint;
    NSLayoutConstraint *sendButtonBottomConstraint;
    
    // AccessoryView
    UICollectionView *accessoryView;
    int accessoryViewPortraitHeight;
    int accessoryViewLandscapeHeight;
    NSArray *accessoryItems;
    
    // AccessoryView Constraints
    NSLayoutConstraint *accessoryViewHeightConstraint;
    NSLayoutConstraint *accessoryViewWidthConstraint;
    NSLayoutConstraint *accessoryViewTopConstraint;
    NSLayoutConstraint *accessoryViewCenterXConstraint;
    
    // AccessoryButton
    UIButton *accessoryButton;
    
    // AccessoryButton Constraints
    NSLayoutConstraint *accessoryButtonHeightConstraint;
    NSLayoutConstraint *accessoryButtonWidthConstraint;
    NSLayoutConstraint *accessoryButtonLeftConstraint;
    NSLayoutConstraint *accessoryButtonBottomConstraint;
    
    // Flags
    BOOL keyboardIsPresent;
    BOOL accessoryViewIsPresent;
    
    // Orientation
    NSInteger lastOrientation;
}

@end

@implementation AHChatBarViewController

@synthesize placeholderText;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.view
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // barView
    barView = [[UIView alloc]init];
    [barView setBackgroundColor:[UIColor colorWithWhite:.98 alpha:.98]];
    [barView.layer setBorderColor:[UIColor grayColor].CGColor];
    [barView.layer setBorderWidth:.7];
    [barView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:barView];
    
    sendButtonSendTitle = @"Send";
    sendButtonCancelTitle = @"Cancel";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    keyboardIsPresent = NO;
    accessoryViewIsPresent = NO;
    
    [self setupTextView];
    [self setupSendButton];
    [self setupAccessoryView];
    [self setupAccessoryButton];
    
    [self setupInternalConstraints];
}

-(void)viewDidLayoutSubviews
{
//    int appExtensionWidth = (int)round(self.view.frame.size.width);
//    
//    int possibleScreenWidthValue1 = (int)round([[UIScreen mainScreen] bounds].size.width);
//    int possibleScreenWidthValue2 = (int)round([[UIScreen mainScreen] bounds].size.height);
//    
//    int screenWidthValue;
//    
//    if (possibleScreenWidthValue1 < possibleScreenWidthValue2) {
//        screenWidthValue = possibleScreenWidthValue1;
//    } else {
//        screenWidthValue = possibleScreenWidthValue2;
//    }
//    
//    if (appExtensionWidth == screenWidthValue) {
//        NSLog(@"PORTRAIT");
//    } else {
//        NSLog(@"LANDSCAPE");
//    }
    
    
    NSInteger currentOrientation;
    
    if([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height)
    {
        currentOrientation = UIDeviceOrientationPortrait;
    }
    else
    {
        currentOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    if (currentOrientation != lastOrientation)
    {
        //NSLog(@"The orientation has changed");
        
        if (accessoryViewIsPresent) {
            [self hideAccessoryViewAnimated:NO];
            [self showAccessoryViewAnimated:NO];
        }
        
        if(currentOrientation == UIDeviceOrientationPortrait)
        {
            lastOrientation = UIDeviceOrientationPortrait;
            //NSLog(@"***Portrait***");
            
            NSTimeInterval animationDuration = 0.25;
            UIViewAnimationOptions keyboardTransitionAnimationCurve = 7 << 16;
            
            accessoryViewHeightConstraint.constant = accessoryViewPortraitHeight;
            [self.view setNeedsUpdateConstraints];
            
            [UIView animateWithDuration:animationDuration
                                  delay:0
                                options:keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        else
        {
            lastOrientation = UIDeviceOrientationLandscapeLeft;
            //NSLog(@"***Landscape***");
            
            NSTimeInterval animationDuration = 0.25;
            UIViewAnimationOptions keyboardTransitionAnimationCurve = 7 << 16;
            
            accessoryViewHeightConstraint.constant = accessoryViewLandscapeHeight;
            [self.view setNeedsUpdateConstraints];
            
            [UIView animateWithDuration:animationDuration
                                  delay:0
                                options:keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                             }];
        }
    }
}


#pragma mark - TextView

-(void)setupTextView
{
    // TextView
    chatTextView = [[UITextView alloc]init];
    [chatTextView setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    chatTextView.layer.cornerRadius = 4;
    [chatTextView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [chatTextView.layer setBorderWidth:.6];
    [chatTextView setBackgroundColor:[UIColor whiteColor]];
    [chatTextView setDelegate:self];
    [chatTextView setReturnKeyType:UIReturnKeyDefault];
    [chatTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [barView addSubview:chatTextView];
    
    //TextView placeholder
    placeholderLabel = [[UILabel alloc] init];
    [placeholderLabel setText:@"AHChatBarView"];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setFont: [UIFont fontWithName:@"helvetica" size:16]];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [placeholderLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [barView addSubview:placeholderLabel];
}

-(void)setPlaceholderText:(NSString*)text{
    placeholderText = text;
    [placeholderLabel setText:placeholderText];
}

-(NSString *)placeholderText{
    return placeholderText;
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    // sendButton cancel
    if([chatTextView.text isEqualToString:@""])
    {
        [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [sendButton setTitle:sendButtonCancelTitle forState:UIControlStateNormal];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    if ([delegate respondsToSelector:@selector(chatTextViewDidChange:)]) {
        [delegate chatTextViewDidChange:textView];
    }
    
    //Placeholder & sendButton
    if([chatTextView.text isEqualToString:@""])
    {
        [placeholderLabel setHidden:NO];
        [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [sendButton setTitle:sendButtonCancelTitle forState:UIControlStateNormal];
    }
    else
    {
        [placeholderLabel setHidden:YES];
        [sendButton setTitleColor:UIColorFromRGB(0x48BB90) forState:UIControlStateNormal];
        [sendButton setTitle:sendButtonSendTitle forState:UIControlStateNormal];
    }
    
    CGRect frameBeforeSizeToFit = chatTextView.frame;
    [chatTextView sizeToFit];
    CGSize contentSize = chatTextView.frame.size;
    chatTextView.frame = frameBeforeSizeToFit;
    
    // MaxHeight
    CGFloat screenHeight = self.view.superview.frame.size.height;
    CGFloat maxHeight;

    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)
    {
        screenHeight  -= keyboardHeightPortrait;
        maxHeight = screenHeight-20;
    }
    else
    {
        screenHeight -= keyboardHeightLandscape;
        maxHeight = screenHeight-20;
    }
    
    barViewHeightConstraint.constant = MIN(contentSize.height+15, maxHeight);
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.17
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([chatTextView.text isEqualToString:@""])
    {
        [placeholderLabel setHidden:NO];
        [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [sendButton setTitle:sendButtonSendTitle forState:UIControlStateNormal];
    }
}


#pragma mark - SendButton

-(void)setupSendButton
{
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:sendButtonSendTitle forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [sendButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
//    [sendButton.layer setBorderColor:[UIColor blackColor].CGColor];
//    [sendButton.layer setBorderWidth:1];
    
    [barView addSubview:sendButton];
}

- (void)sendButtonClicked:(id)sender
{
    if (![chatTextView.text isEqualToString: @""])
    {
        if ([delegate respondsToSelector:@selector(chatBarViewDidPressSendWithText:)]){
            [delegate chatBarViewDidPressSendWithText:chatTextView.text];
        }
        
        chatTextView.text = @"";
    }
    
    if ([chatTextView resignFirstResponder]) {
        //NSLog(@"chatTextView resignFirstResponder");
    }else{
        // The send button was clicked while the keyboard was down
        // textViewDidEndEditing will not be called
        //NSLog(@"chatTextView DID NOT resignFirstResponder");
        
        if ([chatTextView.text isEqualToString:@""])
        {
            [placeholderLabel setHidden:NO];
            [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [sendButton setTitle:sendButtonSendTitle forState:UIControlStateNormal];
        }
    }
}


#pragma mark - AccessoryView

-(void)setupAccessoryView
{
    accessoryViewPortraitHeight = keyboardHeightPortrait;
    accessoryViewLandscapeHeight = keyboardHeightLandscape;
    
    accessoryItems = @[@"Ping", @"Icon"];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [layout setItemSize:CGSizeMake(120, 120)]; // 80, 80
    
    //(top, left, bottom, right)
    layout.sectionInset = UIEdgeInsetsMake(20, 30, 20, 30);
    
    //Space between cells horizontaly
    [layout setMinimumLineSpacing:10];
    
    //Space between cells verticaly
    [layout setMinimumInteritemSpacing:10];
    
    accessoryView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    [accessoryView setDataSource:self];
    [accessoryView setDelegate:self];
    [accessoryView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [accessoryView setBackgroundColor:UIColorFromRGB(0x48BB90)];
    
    [accessoryView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:accessoryView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return accessoryItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
//    [cell.layer setCornerRadius:10];
//    [cell setClipsToBounds:YES];
//    [cell.layer setBorderColor:[UIColor blackColor].CGColor];
//    [cell.layer setBorderWidth:1];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 100, 100)]; // (10, 0, 64, 64)
    [view setBackgroundColor:[UIColor colorWithWhite:.98 alpha:1]];
    [view.layer setCornerRadius:7.5];
    [cell addSubview:view];
    
    // Button images
    UIImageView *imageView;
    
    if ([[accessoryItems objectAtIndex:indexPath.item] isEqualToString:@"Icon"])
    {
        imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Ping_h100.png"]];
    }
    else if ([[accessoryItems objectAtIndex:indexPath.item] isEqualToString:@"Ping"])
    {
        imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pingPin.png"]];
    }
    else
    {
        imageView = [[UIImageView alloc]initWithImage:NULL];
    }
    
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setFrame:CGRectMake(3, 3, 94, 94)]; // (2, 2, 60, 60)
    
//    [imageView setBackgroundColor:[UIColor whiteColor]];
//    [imageView.layer setBorderColor:[UIColor grayColor].CGColor];
//    [imageView.layer setBorderWidth:.5];
//    [imageView.layer setCornerRadius:7.5];
    
    [view addSubview:imageView];
    
    // Label under button
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 100, 20)]; // (0, 60, 80, 20)
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:1];
    //[label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    
//    [label.layer setBorderColor:[UIColor blackColor].CGColor];
//    [label.layer setBorderWidth:1];
    
    [label setText:[accessoryItems objectAtIndex:indexPath.item]];
    [label sizeToFit];
    
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [cell addSubview:label];
    
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:cell
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:cell
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"didSelectItemAtIndexPath item: %d", (int)indexPath.item);
    
    AudioServicesPlaySystemSound(0x450);
    
    if ([delegate respondsToSelector:@selector(chatBarViewDidPressAccessoryItem:)]) {
        [delegate chatBarViewDidPressAccessoryItem:(int)indexPath.item];
    }
}





-(void)showAccessoryViewAnimated:(BOOL)animated
{
    //NSLog(@"showAccessoryViewAnimated: %@", animated ? @"YES":@"NO");
    
    if (animated)
    {
        NSTimeInterval animationDuration = 0.25;
        UIViewAnimationOptions keyboardTransitionAnimationCurve = 7 << 16;
        
        barViewBottomConstraint.constant = -accessoryViewHeightConstraint.constant;
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 accessoryViewIsPresent = YES;
                                 
                                 if ([delegate respondsToSelector:@selector(chatBarViewFrameDidChange:)]) {
                                     [delegate chatBarViewFrameDidChange:self.view.frame];
                                 }
                             }
                         }];
    }
    else
    {
        barViewBottomConstraint.constant = -accessoryViewHeightConstraint.constant;
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
        accessoryViewIsPresent = YES;
        
        if ([delegate respondsToSelector:@selector(chatBarViewFrameDidChange:)]) {
            [delegate chatBarViewFrameDidChange:self.view.frame];
        }
    }
}

-(void)hideAccessoryViewAnimated:(BOOL)animated
{
    //NSLog(@"hideAccessoryViewAnimated: %@", animated ? @"YES":@"NO");
    
    if (animated)
    {
        NSTimeInterval animationDuration = 0.25;
        UIViewAnimationOptions keyboardTransitionAnimationCurve = 7 << 16;
        
        barViewBottomConstraint.constant = 0;
        barViewHeightConstraint.constant = 50;
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 accessoryViewIsPresent = NO;
                                 
                                 if ([delegate respondsToSelector:@selector(chatBarViewFrameDidChange:)]) {
                                     [delegate chatBarViewFrameDidChange:self.view.frame];
                                 }
                             }
                         }];
    }
    else
    {
        barViewBottomConstraint.constant = 0;
        barViewHeightConstraint.constant = 50;
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
        accessoryViewIsPresent = NO;
        
        if ([delegate respondsToSelector:@selector(chatBarViewFrameDidChange:)]) {
            [delegate chatBarViewFrameDidChange:self.view.frame];
        }
    }
}


#pragma mark - AccessoryButton

-(void)setupAccessoryButton
{
    accessoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [accessoryButton setTitle:@"+" forState:UIControlStateNormal];
    [accessoryButton.titleLabel setFont: [UIFont fontWithName:@"helvetica" size:30]];
    [accessoryButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [accessoryButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 5, 0)];
    [accessoryButton setTitleColor:UIColorFromRGB(0x48BB90) forState:UIControlStateNormal];
    [accessoryButton addTarget:self action:@selector(accessoryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    [accessoryButton.layer setBorderColor:[UIColor blackColor].CGColor];
//    [accessoryButton.layer setBorderWidth:1];
    
    [accessoryButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [barView addSubview:accessoryButton];
}

-(void)accessoryButtonClicked:(id)sender
{
    //NSLog(@"accessoryButtonClicked");
    
    if (keyboardIsPresent)
    {
        // Hide keyboard without lowering the chatBarView
        [self.view endEditing:YES];
        [self showAccessoryViewAnimated:YES];
        [self rotateAccessoryButton];
    }
    else
    {
        if (accessoryViewIsPresent)
        {
            // Hide accessoryView
            [self hideAccessoryViewAnimated:YES];
            [self rotateBackAccessoryButton];
        }
        else
        {
            // Show accessoryView
            [self showAccessoryViewAnimated:YES];
            [self rotateAccessoryButton];
        }
    }
}

-(void)rotateAccessoryButton
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         accessoryButton.transform = CGAffineTransformMakeRotation(45.0*M_PI/180.0);
                     }
                     completion:^(BOOL finished) {
                         accessoryViewIsPresent = YES;
                     }
     ];
}

-(void)rotateBackAccessoryButton
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         accessoryButton.transform = CGAffineTransformMakeRotation(0.0*M_PI/180.0);
                     }
                     completion:^(BOOL finished) {
                         accessoryViewIsPresent = NO;
                     }
     ];
}


#pragma mark - Constraints

-(void)addConstraintsWithView:(UIView *)view
{
    barViewHeightConstraint = [NSLayoutConstraint constraintWithItem:barView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
    barViewWidthConstraint = [NSLayoutConstraint constraintWithItem:barView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    barViewBottomConstraint = [NSLayoutConstraint constraintWithItem:barView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    barViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:barView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    [view addConstraints:@[barViewHeightConstraint, barViewWidthConstraint, barViewBottomConstraint, barViewCenterXConstraint]];
}

-(void)setupInternalConstraints
{
    //self.view
    selfViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    selfViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:accessoryView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    selfViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    selfViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[selfViewTopConstraint, selfViewBottomConstraint, selfViewLeftConstraint, selfViewRightConstraint]];
    
    // TextView
    textViewHeightConstraint = [NSLayoutConstraint constraintWithItem:chatTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-15];
    textViewLeftConstraint = [NSLayoutConstraint constraintWithItem:chatTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:accessoryButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:10];
    textViewRightConstraint = [NSLayoutConstraint constraintWithItem:chatTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:sendButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10];
    textViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:chatTextView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    [barView addConstraints:@[textViewHeightConstraint, textViewLeftConstraint, textViewRightConstraint, textViewCenterYConstraint]];
    
    // PlaceholderLabel
    placeholderHeightConstraint = [NSLayoutConstraint constraintWithItem:placeholderLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:chatTextView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    placeholderWidthConstraint = [NSLayoutConstraint constraintWithItem:placeholderLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:chatTextView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-10];
    placeholderCenterXConstraint = [NSLayoutConstraint constraintWithItem:placeholderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:chatTextView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5];
    placeholderCenterYConstraint = [NSLayoutConstraint constraintWithItem:placeholderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:chatTextView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    [barView addConstraints:@[placeholderHeightConstraint, placeholderWidthConstraint, placeholderCenterXConstraint, placeholderCenterYConstraint]];
    
    // SendButton
    sendButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:35];
    sendButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60];
    sendButtonRightConstraint = [NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
    sendButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-7.5];
    
    [barView addConstraints:@[sendButtonHeightConstraint, sendButtonWidthConstraint, sendButtonRightConstraint, sendButtonBottomConstraint]];
    
    // AccessoryView
    accessoryViewHeightConstraint = [NSLayoutConstraint constraintWithItem:accessoryView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:accessoryViewPortraitHeight];
    accessoryViewWidthConstraint = [NSLayoutConstraint constraintWithItem:accessoryView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    accessoryViewTopConstraint = [NSLayoutConstraint constraintWithItem:accessoryView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    accessoryViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:accessoryView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[accessoryViewHeightConstraint, accessoryViewWidthConstraint, accessoryViewTopConstraint, accessoryViewCenterXConstraint]];
    
    // AccessoryButton
    accessoryButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:accessoryButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
    accessoryButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:accessoryButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40];
    accessoryButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:accessoryButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    accessoryButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:accessoryButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:barView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [barView addConstraints:@[accessoryButtonHeightConstraint, accessoryButtonWidthConstraint, accessoryButtonLeftConstraint, accessoryButtonBottomConstraint]];
}


#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([delegate respondsToSelector:@selector(chatBarViewKeyboardWillShow:)]) {
        [delegate chatBarViewKeyboardWillShow:notification];
    }
    
    if (accessoryViewIsPresent) {
        [self rotateBackAccessoryButton];
    }
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardTransitionAnimationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue] << 16;
    
    CGRect rawFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [self.view.superview convertRect:rawFrame fromView:nil];

    if ([chatTextView isFirstResponder])
    {
        barViewBottomConstraint.constant = -keyboardEndFrame.size.height;
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 keyboardIsPresent = YES;

                                 if ([delegate respondsToSelector:@selector(chatBarViewFrameDidChange:)]) {
                                     [delegate chatBarViewFrameDidChange:self.view.frame];
                                 }
                             }
                             
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([delegate respondsToSelector:@selector(chatBarViewKeyboardWillHide:)]) {
        [delegate chatBarViewKeyboardWillHide:notification];
    }
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardTransitionAnimationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    barViewBottomConstraint.constant = 0;
    barViewHeightConstraint.constant = 50;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             keyboardIsPresent = NO;
                             
                             if ([delegate respondsToSelector:@selector(chatBarViewFrameDidChange:)]) {
                                 [delegate chatBarViewFrameDidChange:self.view.frame];
                             }
                         }
                     }];
}


#pragma mark - Dismiss

-(void)dismissWithAnimation:(BOOL)animate
{
    if (accessoryViewIsPresent)
    {
        [self hideAccessoryViewAnimated:animate];
        [self rotateBackAccessoryButton];
    }
    else if (keyboardIsPresent)
    {
        [self.view endEditing:YES];
    }
}


@end