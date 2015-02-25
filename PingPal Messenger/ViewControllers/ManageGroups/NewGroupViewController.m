//
//  NewGroupViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-17.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "NewGroupViewController.h"
#import "GroupWrapper.h"
#import "GroupServer.h"
#import "GroupOverlord.h"

@interface NewGroupViewController (){
    NSString *newGroupName;
}

@property (weak, nonatomic) IBOutlet UIButton *createButton;

- (IBAction)createButtonClicked:(UIButton *)sender;

- (IBAction)textFieldChanged:(UITextField *)sender;

@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;

@end

@implementation NewGroupViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [_createButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_createButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    if (sender.text.length == 0) {
        [_createButton setEnabled:NO];
    }else{
        [_createButton setEnabled:YES];
    }
}


#pragma mark - Create group

- (IBAction)createButtonClicked:(UIButton *)sender
{
    NSLog(@"createButtonClicked");

    [GroupOverlord createGroupWithName:_groupNameTextField.text];
    
    [_groupNameTextField setText:@""];
    [_groupNameTextField resignFirstResponder];
}


#pragma mark - DropViewController

-(BOOL)droppedObjects:(NSMutableArray*)objects{
    NSLog(@"Dropped in %@",[self description]);
    return NO;
}


@end