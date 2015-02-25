//
//  FacebookViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-12.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "FacebookViewController.h"
#import "SWRevealViewController.h"

@interface FacebookViewController (){
    NSString *facebookID;
    NSMutableDictionary *fbNames;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

//@property (weak, nonatomic) IBOutlet UIButton *checkForFriendsButton;

//- (IBAction)checkForFriendsButtonClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation FacebookViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[FacebookConnector sharedInstance]setLoginListener:self];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // ***** Side menu *****
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // FBLoginView
    _loginView.readPermissions = @[@"public_profile", @"user_friends"];
    [_loginView setDelegate:[FacebookConnector sharedInstance]];
    
    [_profilePictureView.layer setCornerRadius:30];
    [_profilePictureView.layer setBorderWidth:2];
    [_profilePictureView.layer setBorderColor:UIColorFromRGB(0x48BB90).CGColor];
    
    // CheckForFriendsButton
    //[_checkForFriendsButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    [[FacebookConnector sharedInstance]checkFriends];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LoginStatusListener

-(void)loggedInWithName:(NSString *)name andID:(NSString *)id{
    NSLog(@"FacebookViewController - loggedInWithName");
    self.profilePictureView.profileID = id;
    self.nameLabel.text = name;
}

-(void)loggedIn{
    //[_checkForFriendsButton setEnabled:YES];
    
    NSLog(@"FacebookViewController - loggedIn");
    
    self.statusLabel.text = NSLocalizedString(@"LoggedInAs", @"You're logged in as:");
}

-(void)loggedOut{
    //[_checkForFriendsButton setEnabled:NO];
    
    NSLog(@"FacebookViewController - loggedOut");
    
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
    self.statusLabel.text= NSLocalizedString(@"NotLoggedIn", @"You're not logged in!");
}


@end