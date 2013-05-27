//
//  DiaryViewController.h
//  newKeyDiary
//
//  Created by Black Black on 3/20/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "EditViewController.h"
#import "SingleDay.h"
#import "SliderPageControl.h"
#import "UserLogin.h"
#import "MBProgressHUD.h"
#import "DiaryRequest.h"

@class JASidePanelController;

@interface DiaryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SliderPageControlDelegate, UIScrollViewDelegate, UserLoginDelegate, MBProgressHUDDelegate, LoginViewControllerDelegate, EditViewControllerDelegate, UITextFieldDelegate, DiaryRequestDelegate>
@property (nonatomic, strong) NSString *launchUrl;

/* for table scroll view*/
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) SliderPageControl *sliderPageControl;
@property (nonatomic, retain) UITableView *tableView1;
@property (nonatomic, retain) UITableView *tableView2;
@property (nonatomic, retain) UITableView *tableView3;

/* for login view and edit view */
@property (nonatomic, strong) LoginViewController *loginForm;
@property (nonatomic, strong) EditViewController *editForm;
/*@property (nonatomic, retain) UIView *loginContainer;
@property (nonatomic, retain) UIView *editContainer;
*/

/* for core data */
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerUser;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


/* for table scroll view */
- (void)slideToCurrentPage:(bool)animated;
- (void)changeToPage:(int)page animated:(BOOL)animated;

/* for login and edit */
- (void) hideLoginForm:(id)sender;
- (void) showLoginForm:(id)sender;
- (void) showEditForm:(id)sender;
- (void) hideEditForm:(id)sender;
- (void) setLoginForm:(NSString *)username password:(NSString *)password;

/* for core data */
- (void) updateDiary:(NSString *)dateStr keyword:(NSString *)keyword;
- (void) deleteDiary:(NSString *)dateStr;

/* for login view callback */
- (void)checkUserLogin:(NSString *)username password:(NSString *)password;

- (NSString *)getUsername;
- (NSString *)getRemindTime;

/* IBOutlet */
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;
- (IBAction)showEdit:(id)sender;
- (IBAction)showSetting:(id)sender;

- (void)setRemindTime:(NSString *)remineTime;

@end
