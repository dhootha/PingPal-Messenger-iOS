//
//  FacebookConnector.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-03.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "FacebookConnector.h"
#import "MyselfObject.h"
#import "FriendWrapper.h"
#import "CFacebook.h"
#import "OutboxHandler.h"

#import <PPLocationManager/Outbox.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

static FacebookConnector *sharedInstance = nil;

@implementation FacebookConnector{
    NSString *facebookID;
    //NSMutableDictionary *fbNames;
    
    BOOL loginFetchCalled;
}

-(id)init{
    self = [super init];
    if (self)
    {
        NSLog(@"FacebookConnector init");
        
        loginFetchCalled = NO;
    }
    return self;
}

+(id)sharedInstance{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

-(void)checkFriends
{
    NSLog(@"FacebookConnector - checkFriends");
    
    if ([FBSession.activeSession isOpen])
    {
        // Session is open
        NSLog(@"FacebookConnector - checkFriends - Facebook session is OPEN");
        [self matchFriends];
    }
    else
    {
        // Session is closed - can't match friends
        NSLog(@"FacebookConnector - checkFriends - Facebook session is CLOSED");
    }
}


#pragma mark - FBLoginViewDelegate

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    NSLog(@"FacebookConnector - loginViewFetchedUserInfo");
    //NSLog(@"User name: %@. User id: %@.", user.first_name, user.id);
    
    if (_loginListener) {
        NSLog(@"loginViewFetchedUserInfo - _loginListener");
        [_loginListener loggedInWithName:user.name andID:user.objectID];
    }
    
    if (loginFetchCalled) {
        NSLog(@"loginViewFetchedUserInfo has already been called");
        return;
    }else{
        // First time called
        loginFetchCalled = YES;
    }
    
    NSString *FBID = [[MyselfObject sharedInstance]getFBID];
    
    NSLog(@"********** FBID = %@ **********", FBID);
    
    if (!FBID) {
        facebookID = user.objectID;
        
        [[MyselfObject sharedInstance]setFBID:facebookID];
    }
    
    if (![[MyselfObject sharedInstance]getFirstName]) {
        [[MyselfObject sharedInstance]setFirstName: user.first_name];
    }
    
    if (![[MyselfObject sharedInstance]getLastName]) {
        [[MyselfObject sharedInstance]setLastName: user.last_name];
    }
    
    if (![[MyselfObject sharedInstance]getImageFileName]) {
        NSMutableArray *myID = [[NSMutableArray alloc]initWithObjects:user.objectID, nil];
        [self downloadImages:myID];
        
        [[MyselfObject sharedInstance]setImageFileName:[NSString stringWithFormat:@"%@.jpeg",user.objectID]];
    }
    
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"FacebookConnector - loginViewShowingLoggedInUser");
    [_loginListener loggedIn];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"FacebookConnector - loginViewShowingLoggedOutUser");
    [_loginListener loggedOut];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


#pragma mark - Match friends

-(void)matchFriends
{
    NSLog(@"matchFriends");
 
    NSMutableDictionary *facebookFriends = [[NSMutableDictionary alloc]init];
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        
        if (error) {
            NSLog(@"matchFriends - friendsRequest Error: %@", error);
        }
        
        NSArray* friends = [result objectForKey:@"data"];
        //NSLog(@"result: %@", result);
        NSLog(@"Found: %lu friends", (unsigned long)friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends)
        {
            //NSLog(@"Name: %@. id: %@", friend.name, friend.id);
            
            [facebookFriends setObject: @{@"firstName":friend.first_name, @"lastName":friend.last_name} forKey:friend.objectID];
            //[FBIDs addObject:friend.objectID];
        }
        
        
        if (facebookFriends.count != 0)
        {
            NSArray *facebookIDs = [facebookFriends allKeys];
            
            NSMutableArray *toDownload = [[NSMutableArray alloc]init];
            NSMutableArray *FBIDsInCoreData = [[NSMutableArray alloc]init];
            
            //Fetch all friends
            NSMutableArray *fetchedFriends = [[NSMutableArray alloc]init];
            [fetchedFriends addObjectsFromArray:[FriendWrapper fetchAllFriends]];
            
            if (fetchedFriends.count != 0)
            {
                for (Friend *f in fetchedFriends)
                {
                    if ([f facebook])
                    {
                        [FBIDsInCoreData addObject:[f.facebook fbid]];
                        
                        // If the image is missing, download it.
                        UIImage *image = [[UIImage alloc]initWithContentsOfFile:[f getImageFilePath]];
                        if (!image) [toDownload addObject:[f.facebook fbid]];
                    }
                    else
                    {
                        NSLog(@"matchFriends error - Friend does not have facebook - SHOULD NEVER HAPPEN");
//                        if ([[dict allValues] containsObject:f.uid]) {
//                            // This is a friend i have thats registered with something other than facebook
//                            // I need to create a facebook object and add it to the friend
//                            NSString *fbid = [[dict allKeysForObject:f.uid]firstObject];
//                            NSString *firstName = [[fbNames objectForKey:fbid] objectForKey:@"firstName"];
//                            NSString *lastName = [[fbNames objectForKey:fbid] objectForKey:@"lastName"];
//                            CFacebook *newFacebook = [FriendHandler createFacebook:fbid withFirstName:firstName andLastName:lastName];
//                            [f setFacebook:newFacebook];
//                            [arr addObject:fbid];
//                            [toDownload addObject:fbid];
//                        }
                    }
                }
            }
            
            NSLog(@"FBIDsInCoreData: %@", FBIDsInCoreData);
            NSLog(@"facebookIDs: %@", facebookIDs);
            
            for (NSString *key in facebookIDs) // key is facebook id
            {
                if (![FBIDsInCoreData containsObject:key])
                {
                    NSString *tag = [NSString stringWithFormat:@"#%@", key];
                    
                    [Outbox tagExists:tag withCallback:^(NSError *error, BOOL exists){
                        NSLog(@"tagExists - Callback: %@", exists ? @"YES":@"NO");
                        
                        if (error) {
                            NSLog(@"tagExists Error: %@", error);
                            return;
                        }
                        
                        if (exists)
                        {
                            [toDownload addObject:key];
                            NSString *first = [[facebookFriends objectForKey:key] objectForKey:@"firstName"];
                            NSString *last = [[facebookFriends objectForKey:key] objectForKey:@"lastName"];
                            [FriendWrapper createFriend:tag withFacebook:[FriendWrapper createFacebook:key withFirstName:first andLastName:last]];
                        }
                    }];
                }
            }
            
            [self downloadImages:toDownload];
        }
        else
        {
            NSLog(@"matchFriends - No friends has the app.");
        }
    }];
}


#pragma mark - Download images

-(void)downloadImages: (NSArray*) fbIDs
{
    NSLog(@"Starting download");
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    dispatch_async(kBgQueue, ^{
        
        NSInteger total = fbIDs.count;
        int current = 1;
        
        for (NSString* fbID in fbIDs)
        {
            NSLog(@"Downloading: %i/%li", current, (long)total);
            current++;
            
            // Get an image from the URL below
            NSString *MyURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=120&height=120", fbID];
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:MyURL]]];
            
            // Let's save the file into Document folder.
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * jpegFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg",fbID]];
            NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(image, 0.5f)];//1.0f = 100% quality
            [data2 writeToFile:jpegFilePath atomically:YES];
        }
        
        [self performSelectorOnMainThread:@selector(imagesDownloaded) withObject:nil waitUntilDone:YES];
        
    });
}

-(void)imagesDownloaded{
    NSLog(@"Download complete!");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end