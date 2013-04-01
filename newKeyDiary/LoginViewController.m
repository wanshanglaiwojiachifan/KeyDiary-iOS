//
//  LoginViewController.m
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "LoginViewController.h"
#import "DiaryViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginViewController ()
- (IBAction)submitLogin:(id)sender;
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation LoginViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initAlertView
 {
 self.alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
 }
- (void)showAlertView:(NSString *)info
{
    [self.alertView setMessage:info];
    [self.alertView show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAlertView];
    UIColor *themeColor = [UIColor colorWithRed:69/255.0 green:212/255.0 blue:218/255.0 alpha:1.0];
    [self.loginButton setBackgroundColor:themeColor];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = 5.0f;
    NSLog(@"loginViewController viewDidLoad");
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitLogin:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    NSLog(@"submitLogin %@ %@", username, password);

    if ([username isEqual: @""] || [password isEqual: @""]) {
        [self showAlertView:@"Login info is incomplete!"];
    } else {
        [self.delegate checkUserLogin:username password:password];
    }
}
- (IBAction)register:(id)sender {
    NSURL *registerUrl = [NSURL URLWithString:@"http://www.keydiary.net/app/accounts/register?type=app"];
    [[UIApplication sharedApplication] openURL:registerUrl];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //if (theTextField == self.passwordField) {
        [theTextField resignFirstResponder];
    //}
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //[[self view] endEditing:YES];
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] != self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    if ([touch view] != self.usernameField) {
        [self.usernameField resignFirstResponder];
    }

    [super touchesBegan:touches withEvent:event];
}

- (void)setLoginForm:(NSString *)username password:(NSString *)password
{
    self.usernameField.text = username;
    self.passwordField.text = password;
}
- (void)viewDidUnload {
    [self setLoginButton:nil];
    [super viewDidUnload];
}
@end
