//
//  UAAppDelegate.h
//  UserAuth
//
//  Created by CJ Ogbuehi on 12/19/13.
//  Copyright (c) 2013 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface UAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)sessionStateChanged:(FBSession *)session
                     state:(FBSessionState)status
                     error:(NSError *)error;
@end
