//
//  RegisterViewController.m
//  UserAuth
//
//  Created by CJ Ogbuehi on 12/20/13.
//  Copyright (c) 2013 CJ Ogbuehi. All rights reserved.
//

#import "RegisterViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLRequestSerialization.h"
#import "LoggedInViewController.h"
#import "UAViewController.h"



@interface RegisterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.passwordField.delegate = self;
    self.passwordField.secureTextEntry = YES;
    self.emailField.delegate = self;
    self.usernameField.delegate = self;
	// Do any additional setup after loading the view.
}

- (IBAction)registerButton {
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
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"username":self.usernameField.text,
                             @"password":self.passwordField.text,
                             @"email":self.emailField.text};
    manger.securityPolicy.allowInvalidCertificates = YES;
    manger.requestSerializer = [AFJSONRequestSerializer serializer];
    manger.responseSerializer = [AFJSONResponseSerializer serializer];
    [manger POST:@"http://127.0.0.1:8000/api/v1/register" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success:%@",[responseObject objectForKey:@"apikey"]);
        
        [self loadBoxEnd:loadingView];
        UAViewController *homeVc = [[UAViewController alloc] init];
        homeVc.authenticated = YES;
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoggedInViewController *contoller = (LoggedInViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"LoggedIn"];
        [self presentViewController:contoller animated:YES completion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        sleep(5);
        [self loadBoxEnd:loadingView];
        UAViewController *homeVc = [[UAViewController alloc] init];
        homeVc.authenticated = NO;
        NSLog(@"Error: %@",error);
        if (error.code == -1011){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username Exists!" message:@"Please choose another username"
                delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else if (error.code == -1004){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shit!" message:@"dont kno what happened" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

    }];


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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
