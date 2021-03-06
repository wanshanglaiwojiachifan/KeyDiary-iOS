//
//  LoginViewController.h
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController;
@protocol LoginViewControllerDelegate <NSObject>

- (void)hideLoginForm:(id)sender;
- (void)checkUserLogin:(NSString *)username password:(NSString *)password;

@end

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger viewHeight;

- (void)setLoginForm:(NSString *)username password:(NSString *)password;
- (IBAction)register:(id)sender;

@end
