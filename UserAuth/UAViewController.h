//
//  UAViewController.h
//  UserAuth
//
//  Created by CJ Ogbuehi on 12/19/13.
//  Copyright (c) 2013 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UAViewController : UIViewController

@property (nonatomic)BOOL authenticated;

-(void)userLoggedInScreen;

-(void)userLoggedOutScreen;

-(BOOL)isUserLoggedIn;
@end
