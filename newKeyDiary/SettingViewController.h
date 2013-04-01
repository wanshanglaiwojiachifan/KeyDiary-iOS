//
//  SettingViewController.h
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "RemindViewController.h"

@class JASidePanelController;

@interface SettingViewController : UIViewController<RemindViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *remindButton;

@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@property (strong, nonatomic) NSString *username;
@property (nonatomic, strong) RemindViewController *remindForm;

@end
