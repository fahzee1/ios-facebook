//
//  LoggedInViewController.m
//  UserAuth
//
//  Created by CJ Ogbuehi on 12/19/13.
//  Copyright (c) 2013 CJ Ogbuehi. All rights reserved.
//

#import "LoggedInViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLRequestSerialization.h"
#import "LoggedInViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UAAppDelegate.h"


@interface LoggedInViewController ()
@property (strong,nonatomic)NSString *facebookFirstName;
@property (strong,nonatomic)NSString *facebookLastname;
@property (strong,nonatomic)NSString *facebookGender;
@property (strong,nonatomic)NSString *facebookEmail;
@property (nonatomic)NSString *facebookID;
@property (strong,nonatomic)NSArray *facebookFriends;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;


@property (weak, nonatomic) IBOutlet UILabel *usernameField;


@end

@implementation LoggedInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"before error");
        if(!error){
            NSLog(@"%@",result);
            self.facebookFirstName = [result objectForKey:@"first_name"];
            NSLog(@"%@",self.facebookFirstName);
            self.facebookLastname = [result objectForKey:@"last_name"];
            self.facebookGender = [result objectForKey:@"gender"];
            self.facebookEmail = [result objectForKey:@"email"];
            self.facebookID = [result objectForKey:@"id"];
            
            //set pic
            
            NSString *picUrlString =[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",self.facebookID];
            NSURL *picURLData = [NSURL URLWithString:picUrlString];
            NSData *picData = [NSData dataWithContentsOfURL:picURLData];
            self.profilePicture.image = [UIImage imageWithData:picData];
            self.profilePicture.layer.cornerRadius = 100.0;
            self.usernameField.text = [self returnFullName];
            
    
            
        }else{
            NSLog(@"error handle it");
        }
    }];
            //set pic
    
    
  

    
    /*
    if (self.facebookUser && FBSession.activeSession.isOpen){
        
        //get friends
        [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error){
                NSLog(@"%@",result);
                NSArray *friendsList = [NSArray arrayWithObjects:[result objectForKey:@"data"], nil];
                self.facebookFriends = friendsList;
            }else{
                NSLog(@"error getting friends handle");
            }
        }];
    }
    */

}

- (IBAction)logoutButton {
    // user did not sign in with facebook
    NSLog(@"make decision..");
    if (!self.facebookUser){
        NSLog(@"not a facebook user");
        // build loading box
        UIView *loadingView = [[UIView alloc] init];
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        textLayer.string = @"Loading...";
        textLayer.foregroundColor = [[UIColor whiteColor] CGColor];
        textLayer.fontSize = 19;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.frame = CGRectMake(112,10, 90, 40);
        loadingView.frame = CGRectMake(0, -40, 320, 40);
        [loadingView setBackgroundColor:[UIColor cyanColor]];
        [loadingView.layer addSublayer:textLayer];
        [self.view addSubview:loadingView];
        [self loadBoxStart:loadingView];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager GET:@"http://127.0.0.1:8000/api/v1/user/logout" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"JSON: %@",responseObject);
            [self loadBoxEnd:loadingView];
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoggedInViewController *contoller = (LoggedInViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeScreenNav"];
            [self presentViewController:contoller animated:YES completion:nil];
            

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@",error);
            [self loadBoxEnd:loadingView];
        }];
        
    //user is facebook user lets close session and have app delegate handle
    }else{
        NSLog(@"Is facebook user");
        // if the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
            NSLog(@"closing session");
            //close the session and remove the access token from the cache.
            //the session state handler in the app delegate will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            //if the session state is not any of the two "open" states when the button is clicked
        }else{
            NSLog(@"open a session to login");
            //open a sessiom showing user the login UI
            //must ALWAYS ask for basic_info when opening a session
            [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                               allowLoginUI:YES
                                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                              //get app delegate
                                              UAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                                              //call the app delegates session changed method
                                              [appDelegate sessionStateChanged:session state:status error:error];
                                              
                                          }];
        }

        self.facebookUser = NO;
    }
    

    

    
}
-(void)loadBoxStart:(UIView *)theView
{
    [UIView animateWithDuration:1.0 animations:^{
        theView.frame = CGRectMake(0, self.navigationController.toolbar.frame.size.height + 12, 320, 40);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)loadBoxEnd:(UIView *)theView
{
    [UIView animateWithDuration:1.0 animations:^{
        theView.frame = CGRectMake(0, -40, 320, 40);
    } completion:^(BOOL finished) {
        
    }];
    
}

-(NSString *)returnFullName
{
    NSString *fullName = nil;
    
    fullName = [NSString stringWithFormat:@"%@ %@", self.facebookFirstName,self.facebookLastname];
    return fullName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
