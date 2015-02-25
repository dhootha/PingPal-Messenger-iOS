//
//  AHChatBarViewController.h
//  AHChatBarView
//
//  Created by André Hansson on 24/09/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AHChatBarViewControllerDelegate;


@interface AHChatBarViewController : UIViewController <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property NSObject<AHChatBarViewControllerDelegate> *delegate;

@property (getter = placeholderText, setter = setPlaceholderText:) NSString *placeholderText;

-(void)addConstraintsWithView:(UIView*)view;

-(void)dismissWithAnimation:(BOOL)animate;

@end


@protocol AHChatBarViewControllerDelegate <NSObject>

@optional
- (void)chatBarViewDidPressSendWithText:(NSString *)chatTextViewText;
- (void)chatTextViewDidChange:(UITextView *)textView;
//- (void)chatBarView:(AHChatBarViewController *)chatBarView
//willChangeFromFrame:(CGRect)startFrame
//            toFrame:(CGRect)endFrame
//           duration:(NSTimeInterval)duration
//     animationCurve:(UIViewAnimationOptions)animationCurve;
-(void)chatBarViewFrameDidChange:(CGRect)frame;
-(void)chatBarViewKeyboardWillShow:(NSNotification*)keyboardNotification;
-(void)chatBarViewKeyboardWillHide:(NSNotification*)keyboardNotification;

-(void)chatBarViewDidPressAccessoryItem:(int)button;

@end