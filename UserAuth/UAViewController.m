//
//  UAViewController.m
//  UserAuth
//
//  Created by CJ Ogbuehi on 12/19/13.
//  Copyright (c) 2013 CJ Ogbuehi. All rights reserved.
//

#import "UAViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UAAppDelegate.h"
#import "LoggedInViewController.h"


@interface UAViewController ()

@end


@implementation UAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   	// Do any additional setup after loading the view, typically from a nib.
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *accountName = @"CJ_O";
    NSString *finalUUID = [NSString stringWithFormat:@"%@-%@",accountName,uuid];
    NSLog(@"%@",finalUUID);
}



- (IBAction)facebookLoginButton {
    // if the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
        //close the session and remove the access token from the cache.
        //the session state handler in the app delegate will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        //if the session state is not any of the two "open" states when the button is clicked
    }else{
        //open a sessiom showing user the login UI
        //must ALWAYS ask for basic_info when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_friends",@"user_photos"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          //get app delegate
                                          UAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                                          //call the app delegates session changed method
                                          [appDelegate sessionStateChanged:session state:status error:error];
                                          
                                      }];
    }
}


-(void)userLoggedInScreen
{
    
    return;
}

-(void)userLoggedOutScreen
{
    return;
}

-(BOOL)isUserLoggedIn
{
    return self.authenticated;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
