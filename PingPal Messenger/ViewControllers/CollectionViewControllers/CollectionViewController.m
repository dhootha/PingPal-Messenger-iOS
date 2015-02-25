//
//  CollectionViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-16.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionItem.h"
#import "UIImage+ImageEffects.h"

@interface CollectionViewController (){
    NSMutableArray *cellsToMove;
    NSMutableArray *cellDictionaries;
    
    UIView *dragAndDropView;
    id selectedArrayItem;
    NSObject <DropDelegate> *dropDelegate;

}

@end

@implementation CollectionViewController

@synthesize array;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        array = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    if(IS_IPHONE_5) // CollectionView height: 208
    {
        //Cell size
        [flowLayout setItemSize:CGSizeMake(60, 60)];

        //(top, left, bottom, right)
        flowLayout.sectionInset = UIEdgeInsetsMake(7, 10, 7, 10);
    
        //Space between cells horizontaly
        [flowLayout setMinimumLineSpacing:7];
    
        //Space between cells verticaly
        [flowLayout setMinimumInteritemSpacing:7];
    
//        if (isGroup) {
//            [flowLayout setFooterReferenceSize:CGSizeMake(70, 244)];
//        }
    }
    else // CollectionView height: 164
    {
        //Cell size
        [flowLayout setItemSize:CGSizeMake(60, 60)];
        
        //(top, left, bottom, right)
        flowLayout.sectionInset = UIEdgeInsetsMake(14.6, 10, 14.6, 10);
        
        //Space between cells horizontaly
        [flowLayout setMinimumLineSpacing:7];
        
        //Space between cells verticaly
        [flowLayout setMinimumInteritemSpacing:14];
//        if (isGroup) {
//            [flowLayout setFooterReferenceSize:CGSizeMake(65, 210)];
//        }
    }

    [self.collectionView setCollectionViewLayout:flowLayout];
    
    cellsToMove = [[NSMutableArray alloc]init];
    cellDictionaries = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    
    [cell setTag:indexPath.item];
    
    //Avatar image
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:[(NSObject<CollectionItem>*)[array objectAtIndex:indexPath.item]getImageFilePath]];
    if (image) {
        [imageView setImage:image];
    }else{
        [imageView setImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
    }
    
    //Name Label
    NSString *cellText = [(NSObject<CollectionItem>*)[array objectAtIndex:indexPath.item] getFirstName];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:100];
    textLabel.text = cellText;

    //if selected
    UIImageView *selectedImageView = (UIImageView*)[cell viewWithTag:300];

    if ([cellsToMove containsObject: [array objectAtIndex:cell.tag]]) {
        [selectedImageView setHidden:NO];
        [imageView setAlpha:.8];
    }else{
        [selectedImageView setHidden:YES];
        [imageView setAlpha:1];
    }
    
    if (![self addGestureRecognizersToCell:cell WithIndexPath:indexPath]) {
        [imageView setImage:[self convertToGreyscale:imageView.image]];
    }
    
    return cell;
}

- (UIImage *) convertToGreyscale:(UIImage *)i {
    
    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;
    
    int colors = kGreen | kBlue | kRed;
    int m_width = i.size.width;
    int m_height = i.size.height;
    
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [i CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
            uint32_t rgbPixel=rgbImage[y*m_width+x];
            uint32_t sum=0,count=0;
            if (colors & kRed) {sum += (rgbPixel>>24)&255; count++;}
            if (colors & kGreen) {sum += (rgbPixel>>16)&255; count++;}
            if (colors & kBlue) {sum += (rgbPixel>>8)&255; count++;}
            m_imageData[y*m_width+x]=sum/count;
        }
    }
    free(rgbImage);
    
    // convert from a gray scale image back into a UIImage
    uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);
    
    // process the image back to rgb
    for(int i = 0; i < m_height * m_width; i++) {
        result[i*4]=0;
        int val=m_imageData[i];
        result[i*4+1]=val;
        result[i*4+2]=val;
        result[i*4+3]=val;
    }
    
    // create a UIImage
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    free(m_imageData);
    
    // make sure the data will be released by giving it to an autoreleased NSData
    [NSData dataWithBytesNoCopy:result length:m_width * m_height];
    
    return resultUIImage;
}

#pragma mark - Gesture recognizers

-(BOOL)addGestureRecognizersToCell:(UICollectionViewCell*)cell WithIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"CollectionViewController addGestureRecognizersToCell");
    [cell addGestureRecognizer: self.myLPGRMethod];
    [cell addGestureRecognizer: self.myTGRMethod];
    return YES;
}

-(UIGestureRecognizer *)myTGRMethod
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    
    return tapGesture;
}

-(void) tapGesture:(UITapGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.view.superview.superview];
    
    UICollectionViewCell *cell = (UICollectionViewCell*) gesture.view;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:cell.tag inSection:0];
    NSObject *friend = [array objectAtIndex:indexPath.item];
    
    UIImageView *selectedImageView = (UIImageView*)[cell viewWithTag:300];
    UIImageView *cellImageView = (UIImageView*)[cell viewWithTag:200];
    
    if (![cellsToMove containsObject:friend]) {
        [cellsToMove addObject:friend];
        
        NSDictionary *cellDict = [[NSDictionary alloc]initWithObjects: [NSArray arrayWithObjects:friend, indexPath, [NSValue valueWithCGPoint:location], nil] forKeys:[NSArray arrayWithObjects:@"object", @"indexPath", @"center", nil]];
        
        [cellDictionaries addObject:cellDict];
        
        [selectedImageView setHidden:NO];
        [cellImageView setAlpha:.8];
    }else{
        
        NSMutableArray *dictionariesToDiscard = [NSMutableArray array];
        
        for (NSDictionary *dict in cellDictionaries) {
            if ([dict objectForKey:@"object"] == friend) {
                [dictionariesToDiscard addObject:dict];
            }
        }
        
        [cellDictionaries removeObjectsInArray:dictionariesToDiscard];
        
        [cellsToMove removeObject:friend];
        
        [selectedImageView setHidden:YES];
        [cellImageView setAlpha:1];
    }
    
    NSLog(@"Cells To Move: %lu", (unsigned long)cellsToMove.count);
}

-(UIGestureRecognizer *)myLPGRMethod
{
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)];
    
    [longGesture setMinimumPressDuration:0.4];
    
    return longGesture;
}

-(void) deleteOnDragBegin: (NSArray*)dictionaries
{
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"indexPath"
                                                                  ascending:NO];
    
    NSArray *sortedArray = [cellDictionaries sortedArrayUsingDescriptors:@[sortByIndex]];
    
    for (NSDictionary *dict in sortedArray)
    {
        NSObject *obj = [dict objectForKey:@"object"];
        [self removeFromArray:obj];
        
        
        NSIndexPath *i = [dict objectForKey:@"indexPath"];
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:i]];

        // Was needed for iOS 6. iOS 6 is no longer supported by PingPal Messenger
//        @try
//        {
//            NSIndexPath *i = [dict objectForKey:@"indexPath"];
//            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:i]];
//        }
//        @catch (NSException *except)
//        {
//            NSLog(@"DEBUG: failure to delete item.  %@", except.description);
//            [self.collectionView reloadData];
//        }
        
    }
}

-(void) longGesture:(UILongPressGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.view.superview.superview];
    
    UICollectionViewCell *cell = (UICollectionViewCell*) gesture.view;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            
            for (NSDictionary *cellDict in cellDictionaries) {
                NSIndexPath *indexPath = [cellDict objectForKey:@"indexPath"];
                UICollectionViewCell *cell2 = [self.collectionView cellForItemAtIndexPath:indexPath];
                NSValue *val = [cellDict objectForKey:@"center"];
                CGPoint center = [val CGPointValue];
                
                UIGraphicsBeginImageContext(cell.contentView.bounds.size);
                [cell2.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                UIView *dragAndDropView2 = [[UIView alloc]initWithFrame:iv.frame];
                [dragAndDropView2 addSubview:iv];
                [dragAndDropView2 setCenter:center];
                
                // Behöver denna ha en tag. Om ja, ska det inte vara cell2 tag???
                [dragAndDropView2 setTag:[cell tag]];
                
                [self.view.superview.superview addSubview:dragAndDropView2];
                
                [UIView animateWithDuration:.3
                                      delay:0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     [dragAndDropView2 setCenter:location];
                                 }
                                 completion:^(BOOL finished) {
                                     [dragAndDropView2 removeFromSuperview];
                                 }];
                
            }
            
            
            UIGraphicsBeginImageContext(cell.contentView.bounds.size);
            [cell.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageView *iv = [[UIImageView alloc] initWithImage:img];
            dragAndDropView = [[UIView alloc]initWithFrame:iv.frame];
            [dragAndDropView addSubview:iv];
            [dragAndDropView setCenter:[gesture locationInView:self.view.superview.superview]];
            [dragAndDropView setTag:[cell tag]];
            
            [self.view.superview.superview addSubview:dragAndDropView];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:cell.tag inSection:0];
            selectedArrayItem = [array objectAtIndex:indexPath.item];
            
            if (![cellsToMove containsObject:selectedArrayItem]) {
                [cellsToMove addObject:selectedArrayItem];
                UIImageView *selectedImageView = (UIImageView*)[cell viewWithTag:300];
                UIImageView *cellImageView = (UIImageView*)[cell viewWithTag:200];
                [selectedImageView setHidden:NO];
                [cellImageView setAlpha:.8];
                
                NSDictionary *cellDict = [[NSDictionary alloc]initWithObjects: [NSArray arrayWithObjects:selectedArrayItem, indexPath, nil] forKeys:[NSArray arrayWithObjects:@"object", @"indexPath", nil]];
                
                [cellDictionaries addObject:cellDict];
            }
            
            [dropDelegate.itemsToMove addObjectsFromArray:cellsToMove];
            
            [self deleteOnDragBegin:cellDictionaries];
            
        }
            break;
            
        case UIGestureRecognizerStateChanged:{
            
            [dragAndDropView setCenter:[gesture locationInView:self.view.superview.superview]];
            //[dropDelegate onHold:location sender:self];
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:{
            
            [dropDelegate onDrop:location sender: self];
            [dragAndDropView removeFromSuperview];
            dragAndDropView = nil;
            
            [cellsToMove removeAllObjects];
            [cellDictionaries removeAllObjects];
            [dropDelegate.itemsToMove removeAllObjects];
            
            [self.collectionView reloadData];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Array

//-(void)setArray:(NSMutableArray *)arr{
//    array = arr;
//}

-(void)addToArray:(NSObject*)object{
    [array addObject:object];
    //NSLog(@"addToArray: %@", array);
    [self.collectionView reloadData];
}

-(void)addToArrayFromArray:(NSArray *)arr{
    [array addObjectsFromArray:arr];
    //NSLog(@"addToArrayFromArray: %@", array);
    [self.collectionView reloadData];
}

-(void)removeFromArray:(NSObject *)object{
    [array removeObject:object];
}

-(void)setDropDelegate:(NSObject<DropDelegate> *)drop{
    dropDelegate = drop;
}

-(BOOL)arrayContainsObject:(id)object{
    return [array containsObject:object];
}


#pragma mark - DropViewController

-(BOOL)droppedObjects:(NSMutableArray*)objects
{
    NSLog(@"CollectionViewController - Dropped in %@",[self description]);
    NSLog(@"Objects: %@", objects);
    
    for (NSObject *object in objects) {
        
        //NSLog(@"Object: %@", object);
        
        if ([array containsObject: object]) {
            //Gör inget
            NSLog(@"Array already contains object");
        }else{
            
            NSLog(@"Add object to array");
            
            [self addToArray:object];
            
            //[self.collectionView reloadData];
        }
    }
    
    return YES;
}

@end