//
//  UAAppDelegate.m
//  UserAuth
//
//  Created by CJ Ogbuehi on 12/19/13.
//  Copyright (c) 2013 CJ Ogbuehi. All rights reserved.
//

#import "UAAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoggedInViewController.h"
#import "UAViewController.h"
#import "LoggedInViewController.h"

@implementation UAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    //Whenever a person opens the app, check for cached sesssion
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded){
        //if theres one just open silently without showing login
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          //Handler for session state changes
                                          // This method will be called EACH time the session state changes
                                          [self sessionStateChanged:session state:status error:error];
                                      }];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //handle the user leaving the app while the facebook login dialog is being shown
    //for example when the user presses the home button while to login ui is up
    [FBAppCall handleDidBecomeActive];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook SDK
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [FBSession.activeSession setStateChangeHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        UAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sessionStateChanged:session state:status error:error];
    }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

-(void)sessionStateChanged:(FBSession *)session
                     state:(FBSessionState)status
                     error:(NSError *)error
{
    __block NSString *alertText;
    __block NSString *alertTitle;
    
    //session opened successully
    if (!error && status == FBSessionStateOpen){
        NSLog(@"Session opened");
        //show user logged in UI
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoggedInViewController *loggedInVc = [storyBoard instantiateViewControllerWithIdentifier:@"LoggedIn"];
        loggedInVc.facebookUser = YES;
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:loggedInVc animated:YES completion:nil];
        return;
        
    }
    if (status == FBSessionStateClosed || status == FBSessionStateClosedLoginFailed){
        //if the session is closed
        NSLog(@"Session closed");
        //show user logged out view
       // [self.window makeKeyAndVisible];
        [[self topMostController] dismissViewControllerAnimated:YES completion:nil];

        return;
        
    }
    //Handle errors
    if (error) {
        NSLog(@"Error");
        //if the error requires people do something outside the app to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }else{
            //if the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled){
                NSLog(@"User cancelled login");
                
                //handle session closures that happen outside of the app
            }else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again";
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        //show user logged out UI
        //[self userLoggedOut];
    }
}

-(void)showMessage:(NSString *)message
         withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"Ok!"
                      otherButtonTitles:nil] show];
}

#pragma mark - convience methods
-(void)transitionToViewController:(UIViewController *)viewController
                   withTransition:(UIViewAnimationOptions)transition
{
    [UIView transitionFromView:self.window.rootViewController.navigationController.view
                        toView:viewController.view
                      duration:0.65f
                       options:transition
                    completion:^(BOOL finished) {
                        self.window.rootViewController = viewController;
                    }];
    
}

-(UIViewController*) topMostController {
    UIViewController *topController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

@end
