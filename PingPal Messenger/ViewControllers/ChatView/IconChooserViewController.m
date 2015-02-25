//
//  IconChooserViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 13/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "IconChooserViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface IconChooserViewController (){
    NSArray *icons;
    UICollectionView *iconsCollectionView;
    
    UIToolbar *toolbar;
    UIButton *cancelButton;
}

@end

@implementation IconChooserViewController

-(id)init{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    icons = @[@"Ping_h100.png", @"Ping_happy_h100.png", @"Ping_angry_h100.png", @"Ping_blush_h100.png", @"Ping_sad_h100.png", @"Ping_awkward_h100.png", @"Ping_OMG_h100.png", @"Ping_scared_h100.png", @"Ping_sleepy_h100.png", @"Ping_thumbs_up_h100.png", @"Ping_WTF_h100.png"];
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:.98 alpha:.98]];
    //[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view setAutoresizesSubviews:YES];
    
    toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar setTranslucent:YES];
    [toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    // Cancel button
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(toolbar.frame.size.width-65, 0, 55, 40)];
    [cancelButton setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColorFromRGB(0x48BB90) forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    // CollectionView
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [layout setItemSize:CGSizeMake(93, 80)];
    
    //(top, left, bottom, right)
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    //Space between cells horizontaly
    [layout setMinimumLineSpacing:5];
    
    //Space between cells verticaly
    [layout setMinimumInteritemSpacing:5];
    
    iconsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    [iconsCollectionView setDataSource:self];
    [iconsCollectionView setDelegate:self];
    [iconsCollectionView setAutoresizingMask: UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    [iconsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"iconCell"];
    [iconsCollectionView setBackgroundColor:[UIColor clearColor]];
    
    [iconsCollectionView setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
    
    
    [self.view addSubview:iconsCollectionView];
    [self.view addSubview:toolbar];
    [toolbar addSubview:cancelButton];
    
    
    [iconsCollectionView reloadData];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return icons.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"iconCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[icons objectAtIndex:indexPath.item]]];
    
    [cell setBackgroundView:imageView];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AudioServicesPlaySystemSound(0x450);
    
    if ([_delegate respondsToSelector:@selector(iconChooserDidSelectIcon:)])
    {
        [_delegate iconChooserDidSelectIcon: [icons objectAtIndex:indexPath.item]];
    }
}

- (void)cancelButtonClicked
{
    NSLog(@"cancelButtonClicked");
    if ([_delegate respondsToSelector:@selector(iconChooserDidClickCancel)])
    {
        [_delegate iconChooserDidClickCancel];
    }
}


@end