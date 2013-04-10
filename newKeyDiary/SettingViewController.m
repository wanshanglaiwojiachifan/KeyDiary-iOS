//
//  SettingViewController.m
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "SettingViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "RemindViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+MJPopupViewController.h"

@interface SettingViewController ()
- (IBAction)showLogin:(id)sender;

@end

@implementation SettingViewController
@synthesize username;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.accountButton setBackgroundColor:[UIColor whiteColor]];
    [self.remindButton setBackgroundColor:[UIColor whiteColor]];
    self.username = [self.sidePanelController.centerPanel getUsername];
    NSLog(@"setting view did load");
    [self setRemindButtonTitle:[self.sidePanelController.centerPanel getRemindTime]];
    NSLog(@"setButtonName %@ %@", self.username, self.accountButton.titleLabel.text);
	// Do any additional setup after loading the view.
}

- (void)setRemindButtonTitle:(NSString *)remindTime
{
    [self.accountButton setTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Logout : ", nil), self.username] forState:UIControlStateNormal];
    if ([remindTime isEqualToString:@"NO"]) {
        [self.remindButton setTitle:NSLocalizedString(@"Remind : Closed", nil) forState:UIControlStateNormal];
    } else {
        NSString *remindTitle = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Remind : ", nil), remindTime];
        [self.remindButton setTitle:remindTitle forState:UIControlStateNormal];
    }
}

- (void)initRemindForm
{
    self.remindForm = [self.storyboard instantiateViewControllerWithIdentifier:@"RemindViewController"];
    self.remindForm.delegate = self;
    self.remindForm.view.layer.cornerRadius = 10.0f;
    self.remindForm.view.clipsToBounds = YES;
    CGRect remindFrame = [self.view bounds];
    remindFrame.size.height = [self.view bounds].size.height *0.8;
    remindFrame.size.width = [self.view bounds].size.width *0.8;
    
    [self.remindForm.view setFrame:remindFrame];
    
}
- (void)hideRemindForm
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)showRemindForm:(NSString *)remindTime
{
    if (self.remindForm == nil) {
        [self initRemindForm];
    }
    [self.remindForm initRemindView:remindTime];
    [self presentPopupViewController:self.remindForm animationType:MJPopupViewAnimationFade];
}
- (void)setRemindTime:(NSString *)remindTime
{
    
    [self.sidePanelController.centerPanel setRemindTime:remindTime];
    [self setRemindButtonTitle:remindTime];
    [self hideRemindForm];
}
- (void)setRemindNotification:(NSString *)remindTime
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showLogin:(id)sender {
    [self.sidePanelController.centerPanel showLoginForm:sender];
}

- (IBAction)showRemind:(id)sender {
    [self showRemindForm:[self.sidePanelController.centerPanel getRemindTime]];
}

- (void)viewDidUnload {
    [self setRemindButton:nil];
    [super viewDidUnload];
}
@end
