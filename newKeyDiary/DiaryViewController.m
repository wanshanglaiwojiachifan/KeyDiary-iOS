//
//  DiaryViewController.m
//  newKeyDiary
//
//  Created by Black Black on 3/20/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "DiaryViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "SettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SingleDay.h"
#import "MonthTableViewController.h"
#import "MBProgressHUD.h"
#import "UserLogin.h"
#import "GCDiscreetNotificationView/GCDiscreetNotificationView.h"
#import "UIViewController+MJPopupViewController.h"
#import "SettingViewController.h"
#import "DiaryViewCell.h"
#import "DiaryRequest.h"

@interface DiaryViewController ()

@property (nonatomic, strong) UserLogin *userLogin;
@property (nonatomic, strong) MBProgressHUD *progressView;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIView *loginContainer;
@property (nonatomic, strong) GCDiscreetNotificationView *notificationView;

@end

@implementation DiaryViewController
{
    NSInteger _currentMonthIndex;
    NSInteger _currentSectionIndex;
    NSInteger _currentPageIndex;
    
    NSInteger _monthCount;
    NSDate *_currentSectionDate;
    NSDate *_currentDate;
    NSInteger _prePageIndex;
    NSDate *_userStartDate;
    NSDate *_userRegDate;
    NSString *_username;
    NSString *_password;
    UITextField *activeTextField;
    NSIndexPath *_currentSelectCell;
    NSString *_remindTime;
    
    BOOL pageControlUsed;
    BOOL dataReady;
    BOOL keyboardShown;
}

@synthesize loginForm;
@synthesize editForm;
@synthesize launchUrl;

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
    NSLog(@"Diary view did load %@", [self.sidePanelController class]);
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    _currentSectionDate = [self getCurrentDate];
    NSString *year = [self dateToStrByFormat:_currentSectionDate format:@"yyyy"];
    NSString *month = [self dateToStrByFormat:_currentSectionDate format:@"MM"];
    
    _currentDate = [self getCurrentDate];
    dataReady = NO;
    NSLog(@"current date %@ %@", _currentDate, [NSString stringWithFormat:@"%@-%@-01", year, month]);
    
    // do init
    [self initUserLogin];
    //[self initProgressView];
    [self initAlertView];
    [self initLoginForm];
    [self initEditForm];

    [self checkUserWhenStart];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* APP启动时，检查用户信息 */
- (void)checkUserWhenStart{
    NSString *username = [self.userLogin getUsername];
    //NSLog(@"checkUserWhenStart list %@", [username class]);
    if (!username || [username isEqualToString:@""]) {
        _username = @"";
        _password = @"";
        [self showLoginForm:nil];
    } else {
        NSString *password = [self.userLogin getPassword];
        NSArray *info = [self getUserInfoFromCoreData:username];
        NSLog(@"getUserInfo Array %@", info);
        if (info != nil && [info count] >= 3) {
            NSDate *lastLogin = [self strToDateByFormat:[info objectAtIndex:2] format:@"yyyy-MM-dd HH:mm:ss"];
            if ([info count] >= 4 && [info objectAtIndex:3] != nil) {
                _remindTime = (NSString *)[info objectAtIndex:3];
            } else {
                _remindTime = @"NO";
            }
            if ([self getDateCount:lastLogin endDate:_currentDate] < 5) {
                _username = username;
                _password = password;
                _userStartDate = [self strToDateByFormat:[info objectAtIndex:1] format:@"yyyy-MM-dd HH:mm:ss"];
                NSLog(@"initUserView by cor data");
                [self initUserView:username password:password created:[info objectAtIndex:0]];
                return;
            }
        } else {
            _remindTime = @"NO";
            [self checkUserLogin:username password:password];
        }
    }
}

/* 登录完成之后初始化用户信息 */
- (void)initUserInfo:(NSString *)username password:(NSString *)password startDate:(NSString *)startDate
{
    NSLog(@"initUserInfo %@, %@, %@", username, password, startDate);
    _username = username;
    _password = password;
    _userRegDate = startDate == nil ? [self getCurrentDate] : [self strToDateByFormat:startDate format:@"yyyy-MM-dd HH:mm:ss"];
    //SettingViewController *rightPanel = (SettingViewController *)self.sidePanelController.rightPanel;
    NSLog(@"initUserInfo done regdate - %@, %@ %@", _userRegDate, [self strToDateByFormat:@"2013-03-25 23:38:46" format:@"yyyy-MM-dd HH:mm:ss"], [startDate class]);
}

- (NSString *)getUsername
{
    return _username;
}

- (NSString *)getRemindTime
{
    return _remindTime;
}


- (void)initUserLogin
{
    self.userLogin = [[UserLogin alloc] init];
    self.userLogin.delegate = self;
}

- (void)initProgressView
{
    self.progressView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.progressView];
    self.progressView.delegate = self;
}

- (void)initAlertView
{
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}
- (void)initLoginForm
{
    
    self.loginContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    
    self.loginContainer.hidden = YES;
    self.loginContainer.frame = self.view.bounds;
    self.loginContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.loginContainer];
    self.loginForm = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.loginForm.delegate = self;
    CGRect loginFrame = self.view.bounds;
    //loginFrame.size.width = [self.view bounds].size.width * 0.8;
    //loginFrame.size.height = [self.view bounds].size.height *0.8;
    [self.loginForm.view setFrame:loginFrame];
    [self.loginContainer addSubview:self.loginForm.view];
}
- (void)initEditForm
{
    self.editForm = [self.storyboard instantiateViewControllerWithIdentifier:@"EditViewController"];
    self.editForm.delegate = self;
    self.editForm.view.layer.cornerRadius = 10.0f;
    self.editForm.view.clipsToBounds = YES;
    CGRect editFrame = [self.view bounds];
    editFrame.size.height = [self.view bounds].size.height *0.4;
    editFrame.size.width = [self.view bounds].size.width *0.8;
    
    [self.editForm.view setFrame:editFrame];
}

- (void)showProgress:(NSString *)text
{
    if (self.progressView == nil) {
        [self initProgressView];
    }
    //NSLog(@"showProgress %@", text);
    self.progressView.labelText = text;
    [self.progressView show:YES];
}

- (void)hideProgress
{
    [self.progressView hide:YES afterDelay:3];
}

- (void)showAlertView:(NSString *)info
{
    [self.alertView setMessage:info];
    [self.alertView show];
}

- (void)showNotification:(NSString *)text activity:(BOOL)activity delay:(NSInteger)delay
{
    NSLog(@"showNotification %@", text);
    if (self.notificationView == nil) {
        self.notificationView = [[GCDiscreetNotificationView alloc] initWithText:text showActivity:activity inPresentationMode:GCDiscreetNotificationViewPresentationModeTop inView:self.view];
    } else {
        
        [self.notificationView setTextLabel:text andSetShowActivity:activity animated:YES];
    }
    [self.notificationView showAndDismissAfter:delay];

    //[self.notificationView showAnimated];
/*
    if (delay == 0) {
    } else {
        [self.notificationView showAndDismissAfter:delay];
    }*/
    //[self.notificationView hideAnimatedAfter:1000];
}


/* 检查用户密码是否正常 */
/* 用户密码正常 - 从服务器上拉最新的数据 - 检查本地数据是否最新，否则覆盖掉 */
/* 密码不正常或者未注册，出登录页面 */
- (void)checkUserLogin:(NSString *)username password:(NSString *)password
{
    NSLog(@"checkUserLogin %@, %@", username, password);
    [self showProgress:NSLocalizedString(@"Login...", nil)];
    if (_username != username) {
        NSLog(@"a new user %@", username);
        /* 如果登录用户名和之前登录的不同,则删除本地所有日记 */
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [self deleteAllDiary:context];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);            
            abort();
        }
    }
    _username = username;
    _password = password;
    [self.userLogin checkUserExist:username password:password];
}
/* 检查用户登录的回调函数 */
- (void)checkUserCallback:(NSDictionary *)userInfo code:(NSInteger)code
{
    if (userInfo != nil && [[NSString stringWithFormat:@"%@", [userInfo valueForKeyPath:@"stat"]] isEqual:@"1"]) {
        NSLog(@"checkUserCallback %@", userInfo);
        NSDictionary *data = [userInfo valueForKeyPath:@"data"];
        NSString *created =  [data valueForKeyPath:@"created"];
        NSLog(@"check callback %@", [[userInfo valueForKeyPath:@"stat"] class]);
        NSLog(@"check callback 2 %@", created);

        NSLog(@"initUserView by service");
        [self initUserView:_username password:_password created:created];
    } else {
        //[self.loginForm setLoginForm:_username password:_password];
        [self showLoginForm:nil];
        if (code == 0) {
            [self showAlertView:NSLocalizedString(@"Network Failed", nil)];
        } else {
            [self.userLogin deletePassword];
            [self showAlertView:NSLocalizedString(@"Password Not Compatible", nil)];
        }
        _username = @"";
        _password = @"";
    }
}

- (void)initUserView:(NSString *)username password:(NSString *)password created:(NSString *)created
{
    //[self.loginForm setLoginForm:_username password:_password];
    NSLog(@"initUserView");
    dataReady = NO;
    [self.userLogin setUserInfo:_username password:_password];
    self.progressView.labelText = [NSString stringWithFormat:@"Welcome %@", _username];
    
    [self hideLoginForm:nil];
    [self initUserInfo:_username password:_password startDate:created];
    [self getUserDiary];
}

/* 更新日记的回调函数 */
- (void)insertDiaryCallback:(NSDictionary *)insertInfo code:(NSInteger)code sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
{
    [self hideProgress];
    NSString *dateStr = [self getDateStrBySectionRow:section row:row];
    NSLog(@"insertDiaryCallback %@ section - %d row - %d date - %@", insertInfo, section, row, dateStr);

    if (insertInfo != nil && [[NSString stringWithFormat:@"%@", [insertInfo valueForKeyPath:@"stat"]] isEqualToString:@"1"]) {
        [self updateStatusInDiary:dateStr success:@"0"];
        [self showNotification:NSLocalizedString(@"Upload Success", nil) activity:NO delay:2];
    } else {
        [self updateStatusInDiary:dateStr success:@"1"];
        if (code == 0) {
            [self showAlertView:NSLocalizedString(@"Network Failed", nil)];
        }
        //检查网络不佳还是密码错误导致的 todo
        [self showNotification:NSLocalizedString(@"Upload Fail", nil) activity:NO delay:2];
    }
    UITableView *tableView = [self getCurrentTableView];
    [tableView reloadData];
    //[self configureCell:(DiaryViewCell *)[tableView cellForRowAtIndexPath:_currentSelectCell] atIndexPath:_currentSelectCell tableView:tableView];
}
/* 删除日记的回调函数 */
- (void)deleteDiaryCallback:(NSDictionary *)deleteInfo code:(NSInteger)code sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
{
    [self hideProgress];
    NSString *dateStr = [self getDateStrBySectionRow:section row:row];
    NSLog(@"deleteDiaryCallback %@ section - %d row - %d, date - %@", deleteInfo, section, row, dateStr);
    if (deleteInfo != nil && [[NSString stringWithFormat:@"%@", [deleteInfo valueForKeyPath:@"stat"]] isEqualToString:@"1"]) {
        [self updateStatusInDiary:dateStr success:@"0"];
        [self showNotification:NSLocalizedString(@"Delete Success", nil) activity:NO delay:2];
    } else {
        [self updateStatusInDiary:dateStr success:@"1"];
        if (code == 0) {
            [self showAlertView:NSLocalizedString(@"Network Failed", nil)];
        }
        //检查网络不佳还是密码错误导致的 todo
        [self showNotification:NSLocalizedString(@"Delete Fail", nil) activity:NO delay:2];
    }
    UITableView *tableView = [self getCurrentTableView];
    [tableView reloadData];
}
/* HTTP请求用户日记 */
- (void)getUserDiary
{
    [self showProgress:NSLocalizedString(@"Loading Diary...", nil)];
    [self.userLogin getDiary:_username password:_password];
}
/* HTTP请求用户日记的回调函数 */
- (void)getUserDiaryCallback:(NSDictionary *)diaryInfo  code:(NSInteger)code
{
    NSDictionary *data = [diaryInfo valueForKey:@"data"];
    _userStartDate = [data valueForKeyPath:@"startDateFormat"] == nil ? [self getCurrentDate] : [self strToDateByFormat:[data valueForKeyPath:@"startDateFormat"] format:@"yyyy-MM-dd"];
    NSLog(@"getUserDiaryCallback! start date class regdate - %@, start - %@", _userRegDate, [data valueForKeyPath:@"startDate"]);

    NSLog(@"getDiaryCallback %@", _userStartDate);
    if ([[NSString stringWithFormat:@"%@", [diaryInfo valueForKeyPath:@"stat"]] isEqual:@"1"]) {
        [self setUserInfoToCoreData:_username info:[NSString stringWithFormat:@"%@;%@;%@;%@",
                                                    [self dateToStrByFormat:_userRegDate format:@"yyyy-MM-dd HH:mm:ss"],
                                                    [self dateToStrByFormat:_userStartDate format:@"yyyy-MM-dd HH:mm:ss"],
                                                    [self dateToStrByFormat:[self getCurrentDate] format:@"yyyy-MM-dd HH:mm:ss"],
                                                    _remindTime]];
        [self importToCoreData:[data valueForKeyPath:@"diaries"]];
        [self hideProgress];
    } else {
        if (code == 0) {
            [self showAlertView:NSLocalizedString(@"Network Failed", nil)];
            NSLog(@"init slider from core data");
            [self initSlider];
        } else {
            [self showAlertView:NSLocalizedString(@"Error When Getting Diaries", nil)];
            [self showLoginForm:nil];
        }
    }
}

/* 初始化3个TABLE VIEW */
- (void)initSlider
{
    NSLog(@"initSlider");
    if (self.scrollView == nil) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, [self.view bounds].size.width, [self.view bounds].size.height - 100)];
        [self.scrollView setPagingEnabled:YES];
        [self.scrollView setContentSize:CGSizeMake(3 * self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setDelegate:self];
        [self.view addSubview:self.scrollView];
        
        self.sliderPageControl = [[SliderPageControl alloc] initWithFrame:CGRectMake(0, [self.view bounds].size.height - 20, [self.view bounds].size.width, 20)];
        [self.sliderPageControl addTarget:self action:@selector(onPageChanged:) forControlEvents:UIControlEventValueChanged];
        [self.sliderPageControl setDelegate:self];
        [self.sliderPageControl setShowsHint:YES];
        [self.view addSubview:self.sliderPageControl];
        [self.sliderPageControl setNumberOfPages:3];
        self.sliderPageControl.hidden = YES;
        [self.sliderPageControl setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        
        UIView *tableContainer;
        MonthTableViewController *tableView;
        for (int i = 0; i < 3; i++)
        {
            tableContainer = [[UIView alloc] initWithFrame:CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            tableContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            tableView = [self.storyboard instantiateViewControllerWithIdentifier:@"MonthTableViewController"];
            //[tableView.tableView registerClass:[DiaryViewCell class] forCellReuseIdentifier:@"DiaryViewCell"];
            tableView.tableView.delegate = self;
            tableView.tableView.dataSource = self;
            tableView.tableView.tag = i;
            [tableView.tableView setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            [tableContainer addSubview:tableView.tableView];
            //[self addChildViewController:tableView];
            if (i == 0) {
                self.tableView1 = tableView.tableView;
            } else if (i == 1) {
                self.tableView2 = tableView.tableView;
            } else if (i == 2) {
                self.tableView3 = tableView.tableView;
            }
            [self.scrollView addSubview:tableContainer];
        }
        /*[self.tableView1 registerClass:[DiaryViewCell class] forCellReuseIdentifier:@"DiaryViewCell"];
        [self.tableView2 registerClass:[DiaryViewCell class] forCellReuseIdentifier:@"DiaryViewCell"];
        [self.tableView3 registerClass:[DiaryViewCell class] forCellReuseIdentifier:@"DiaryViewCell"];*/
    }
    [self initDefaultPage];
}
/* 初始化当前页为最后一页 */
- (void)initDefaultPage
{
    [self showNotification:_username activity:NO delay:2];
    _currentSectionIndex = [self getMonthCount:_userStartDate] - 1;
    _prePageIndex = 2;
    [self changeToPage:2 animated:NO];
    [self updateMonthText:_currentSectionDate];
}

- (void)scrollToBottom:(UITableView *)tableView animate:(BOOL)ifAnimate
{
    CGFloat yOffset = 0;
    if (tableView.contentSize.height > tableView.bounds.size.height) {
        yOffset = tableView.contentSize.height - tableView.bounds.size.height;
    }
    
    [tableView setContentOffset:CGPointMake(0, yOffset) animated:ifAnimate];
}
/* 设置日记提醒时间  xx:xx or NO */
- (void)setRemindTime:(NSString *)remindTime
{
    _remindTime = remindTime;
    DiaryRequest *remindReq = [[DiaryRequest alloc] init];
    remindReq.delegate = self;
    [self showNotification:NSLocalizedString(@"Saving Remind Time...", nil) activity:YES delay:2];
    [remindReq setRemindTime:_username password:_password remindTime:remindTime];
    [self.sidePanelController showCenterPanelAnimated:YES];
}

- (void)setRemindTimeCallback:(NSDictionary *)remindInfo code:(NSInteger)code
{
    NSLog(@"setRemindTimeCallback ");
    [self setUserInfoToCoreData:_username info:[NSString stringWithFormat:@"%@;%@;%@;%@",
                                                [self dateToStrByFormat:_userRegDate format:@"yyyy-MM-dd HH:mm:ss"],
                                                [self dateToStrByFormat:_userStartDate format:@"yyyy-MM-dd HH:mm:ss"],
                                                [self dateToStrByFormat:[self getCurrentDate] format:@"yyyy-MM-dd HH:mm:ss"],
                                                _remindTime]];
}

/* 获取currentSectionIndex对应的tableView */
- (UITableView *)getCurrentTableView
{
    if (_currentSectionIndex == 0) {
        return self.tableView1;
    }
    if (_currentSectionIndex == [self getMonthCount:_userStartDate] - 1) {
        return self.tableView3;
    }
    return self.tableView2;
}
/* 获取某个tableview对应的section */
- (NSInteger)getSectionIndex:(NSInteger)currentPage currentSection:(NSInteger)currentSection tableView:(UITableView *)tableView
{
    NSInteger sectionIndex;
    if (currentPage == 0) {
        if (tableView.tag == 0) {
            sectionIndex = currentSection;
        } else if (1 == tableView.tag) {
            sectionIndex = currentSection + 1;
        } else {
            sectionIndex = currentSection + 2;
        }
    } else if(currentPage == 2) {
        if (0 == tableView.tag) {
            sectionIndex = currentSection - 2;
        } else if (1 == tableView.tag) {
            sectionIndex = currentSection - 1;
        } else {
            sectionIndex = currentSection;
        }
    } else {
        if (0 == tableView.tag) {
            sectionIndex = currentSection - 1;
        } else if (1 == tableView.tag) {
            sectionIndex = currentSection;
        } else {
            sectionIndex = currentSection + 1;
        }
    }
    //NSLog(@"getSectionIndex: section - %d, currentPage - %d", sectionIndex, currentPage);
    return sectionIndex;
}

- (NSDate *)getSectionMonth:(NSInteger)sectionIndex
{
    NSInteger monthCount = [self getMonthCount:_userStartDate];
    NSInteger offset = (sectionIndex - monthCount + 1);
    NSLog(@"getSectionMonth section - %d, monthcount - %d, offset - %d, currenDate - %@", sectionIndex, monthCount, offset, _currentDate);
    return [self getMonthByOffset:_currentDate offset:offset];
}

/* 更新日期LABEL */
- (void) updateMonthText:(NSDate *)date
{
    self.monthLabel.text = [self dateToStrByFormat:date format:@"yyyy - MM"];
}


/* scroll view 代理 */
#pragma mark scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView_
{
  //  NSLog(@"scrollViewDidEndDecelerating currentPage - %d, prePage - %d, currentSection - %d, monthCount - %d", self.sliderPageControl.currentPage, _prePageIndex, _currentSectionIndex, [self getMonthCount:_userStartDate]);
    if (_prePageIndex != self.sliderPageControl.currentPage) {
        if (_prePageIndex < self.sliderPageControl.currentPage) {
            _currentSectionIndex = _currentSectionIndex + 1;
        } else {
            _currentSectionIndex = _currentSectionIndex - 1;
        }
        if (_currentSectionIndex > [self getMonthCount:_userStartDate] - 1) {
            _currentSectionIndex = [self getMonthCount:_userStartDate] - 1;
        } else if (_currentSectionIndex < 0) {
            _currentSectionIndex = 0;
        }
        if (_currentSectionIndex == 0){
            [self changeToPage:0 animated:NO];
            [self.tableView2 reloadData];
            [self.tableView3 reloadData];
        } else if(_currentSectionIndex == [self getMonthCount:_userStartDate] - 1) {
            [self changeToPage:2 animated:NO];
            [self.tableView1 reloadData];
            [self.tableView2 reloadData];
        } else {
            [self changeToPage:1 animated:NO];
            [self.tableView1 reloadData];
            [self.tableView3 reloadData];
        }
    }
    NSInteger monthCount = [self getMonthCount:_userStartDate] - 1;
    _currentSectionDate = [self getMonthByOffset:_currentDate offset:(_currentSectionIndex - monthCount)];
    _prePageIndex = self.sliderPageControl.currentPage;
    [self updateMonthText:_currentSectionDate];
    pageControlUsed = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    //NSLog(@"scrollViewDidScroll");
    if (pageControlUsed)
	{
        return;
    }
	
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[self.sliderPageControl setCurrentPage:page animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView_
{
	pageControlUsed = NO;
}

#pragma mark sliderPageControlDelegate

- (void)onPageChanged:(id)sender
{
    NSLog(@"onPageChange");
	pageControlUsed = YES;
	[self slideToCurrentPage:YES];
}

- (void)slideToCurrentPage:(bool)animated
{
    NSLog(@"sliderToCurrentPage");
	int page = self.sliderPageControl.currentPage;
	
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:animated];
}

- (void)changeToPage:(int)page animated:(BOOL)animated
{
    NSLog(@"changeToPage %d", page);
	[self.sliderPageControl setCurrentPage:page animated:YES];
	[self slideToCurrentPage:animated];
    [[self getCurrentTableView] reloadData];
}

/* TABLE 代理 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getTableViewDayCount:tableView];
    
    //NSLog(@"numberOfSectionsInTableView month - %@, month day - %d, section - %d, table tag - %d", month, [self getMonthDays:monthDate], sectionIndex, tableView.tag);
}
- (NSInteger)getTableViewDayCount:(UITableView *)tableView
{
    NSInteger sectionIndex = [self getSectionIndex:self.sliderPageControl.currentPage currentSection:_currentSectionIndex tableView:tableView];
    NSDate *monthDate = [self getSectionMonth:sectionIndex];
    NSLog(@"numberOfRowsInSection monthDate %d, %@, %d", sectionIndex, monthDate, [self getMonthCount:_userStartDate]);
    if (sectionIndex == [self getMonthCount:_userStartDate] - 1) {
        NSString *year = [self dateToStrByFormat:monthDate format:@"yyyy"];
        NSString *month = [self dateToStrByFormat:monthDate format:@"MM"];
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@-01", year, month];
     //   NSLog(@"numberOfRowsInSection %@, %@", dateStr, _currentDate);
        NSDate *startDate = [self strToDateByFormat:dateStr format:@"yyyy-MM-dd"];
        return [self getDateCount:startDate endDate:_currentDate];
    } else {
        return [self getMonthDays:monthDate];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath %@", indexPath);
    static NSString *CellIdentifier = @"DiaryViewCell";
    DiaryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSLog(@"cell is nil");
        cell = [[DiaryViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSLog(@"in configure index %@", [cell class]);
    [self configureCell:cell atIndexPath:indexPath tableView:tableView];
    return cell;
}
/* 根据section, row获取cell */
- (UITableViewCell *)getTableCellBySectionRow:(NSInteger)section row:(NSInteger)row
{
}
- (void)configureCell:(DiaryViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSLog(@"configurexxxx cell row - %d", [indexPath row]);
    NSInteger row = [indexPath row];
    NSInteger sectionIndex = [self getSectionIndex:self.sliderPageControl.currentPage currentSection:_currentSectionIndex tableView:tableView];
    NSString *rowStr;
    if (row > 8) {
        rowStr = [NSString stringWithFormat:@"%d", row + 1];
    } else {
        rowStr = [NSString stringWithFormat:@"0%d", row + 1];
    }

    NSString *rowDateStr = [self getDateStrBySectionRow:sectionIndex row:row];
    NSArray *result = [self getDiaryExist:rowDateStr];
    UILabel *dayLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *keywordLabel = (UILabel *)[cell viewWithTag:2];
    UIButton *noticeButton = (UIButton *)[cell viewWithTag:3];
    dayLabel.text = rowStr;
    cell.rowIndex = row;
    cell.sectionIndex = sectionIndex;

    if ([result count] > 0) {
        NSManagedObject *cellData = [result objectAtIndex:0];
        NSLog(@"configure test %@", [cellData valueForKey:@"keyword"]);

        NSString *updateStatus = [cellData valueForKey:@"update"];
        NSLog(@"cellForRowAtIndexPath %@ %@", rowDateStr, updateStatus);
        keywordLabel.text = [cellData valueForKey:@"keyword"];
        [noticeButton addTarget:self action:@selector(syncButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        if ([updateStatus isEqualToString:@"0"]) {
            noticeButton.hidden = YES;
            [noticeButton setTitle:@"S" forState:UIControlStateNormal];
        } else if ([updateStatus isEqualToString:@"1"]) {
            noticeButton.hidden = NO;
            [noticeButton setTitle:@"!!" forState:UIControlStateNormal];
        } else {
            noticeButton.hidden = NO;
            [noticeButton setTitle:@"L" forState:UIControlStateNormal];
        }
    } else {

        keywordLabel.text = @"";
        [noticeButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)syncButtonTouch:(UIButton *)button
{
    DiaryViewCell *cell = (DiaryViewCell *)button.superview.superview;
    NSString *dateStr = [self getDateStrBySectionRow:cell.sectionIndex row:cell.rowIndex];
    NSLog(@"syncButtonTouch %d %d, %@", cell.sectionIndex, cell.rowIndex, dateStr);

    //NSArray *result = [self getDiaryExist:dateStr];
    //if ([result count] > 0) {
    [self showEditFormForCell:dateStr keyword:cell.keywordLabel.text sectionIndex:cell.sectionIndex rowIndex:cell.rowIndex sync:YES];
    //}
}

#pragma mark - Table view delegate
/* core data 方法 */
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiaryDetail" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateStr" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Diary"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}



- (NSFetchedResultsController *)fetchedResultsControllerUser
{
    if (_fetchedResultsControllerUser != nil) {
        return _fetchedResultsControllerUser;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"DiaryUser"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsControllerUser = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsControllerUser performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsControllerUser;
}
/* 读取用户信息，包括注册时间，日记起始时间 yyyy-MM-dd hh:ii:ss*/
/* registerDate;startDate;lastLoginDate;remindTime(12:00) */

- (NSArray *)getUserInfoFromCoreData:(NSString *)username
{
    NSLog(@"getUserInfoFromCoreData start");
    NSString *usernameReplace = [username stringByReplacingOccurrencesOfString:@"@" withString:@","];
    NSManagedObjectContext *context = [self.fetchedResultsControllerUser managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsControllerUser fetchRequest] entity];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", usernameReplace];
    [request setPredicate:predicate];

     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    //NSLog(@"getUserInfoFromCoreData %@, %@", usernameReplace, result);

    if ([result count] > 0) {
        NSManagedObject *userData = [result objectAtIndex:0];
        NSString *info = [userData valueForKeyPath:@"info"];
        if (info != nil && ![info isEqualToString:@""]) {
            return [info componentsSeparatedByString:@";"];
        }
    }
    return nil;
}

- (void)setUserInfoToCoreData:(NSString *)username info:(NSString *)info
{
    NSString *usernameReplace = [username stringByReplacingOccurrencesOfString:@"@" withString:@","];
    NSLog(@"setUserInfoToCoreData %@, %@", usernameReplace, info);
    NSManagedObjectContext *context = [self.fetchedResultsControllerUser managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsControllerUser fetchRequest] entity];
    NSError *error;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", usernameReplace];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSArray *result = [context executeFetchRequest:request error:&error];
    if ([result count] > 0) {
        for (int i = 0; i < [result count]; i++) {
            [context deleteObject:[result objectAtIndex:i]];
        }
    }
    //NSLog(@"setuserinfo entity name %@", [entity name]);
    NSManagedObject *newUser = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newUser setValue:usernameReplace forKey:@"username"];
    [newUser setValue:info forKey:@"info"];
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        abort();
    }
}
/* 当数据变化时执行 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"controllerWillChangeContent");
    if (!dataReady) {
        return;
    }
    [[self getCurrentTableView] beginUpdates];
}

/* 当实体中的某个对象改变时 */
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!dataReady) {
        return;
    }
    //NSLog(@"didChangeObject %@", indexPath);
    /*UITableView *tableView = [self getCurrentTableView];
    if (type == NSFetchedResultsChangeUpdate) {
        NSLog(@"change object update");
        [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath tableView:tableView];
    }*/
}

/* 当数据变化完成时 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"controllerDidChangeContent %@", [controller cacheName]);
    if ([[controller cacheName] isEqualToString:@"DiaryUser"]) {
        return;
    }
    if (!dataReady) {
        [self initSlider];
        dataReady = true;
        return;
    }
    if (dataReady) {
        [[self getCurrentTableView] endUpdates];
    }
}

/* 根据dateStr获取本地数据 */
- (NSArray *)getDiaryExist:(NSString *)dateStr
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];// 为什么不用self.managedObjectContext
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    // Set the predicate -- much like a WHERE statement in a SQL database
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateStr == %@", dateStr];
    [request setPredicate:predicate];
    
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    //NSLog(@"getDiaryExist error %@", error);
    return result;
}

/* 从服务器获取数据之后与本地数据合并 */
/* 如果本地某天的数据更新状态为1|2, 则将服务器的数据存在keyword_service */
/* 检查本地所有更新状态为0的日记,与服务器取回的数据做对比,如果服务器上不存在某天的数据,则相应的删除本地数据 */
- (void)importToCoreData:(NSArray *)dataFromService
{
    NSLog(@"importToCoreData %@", dataFromService);
    if (dataFromService == nil || [dataFromService count] == 0) {
        [self initSlider];
        return;
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];

    NSDictionary *singleData;
    NSManagedObject *singleCoreData;
    NSArray *notUpdate;
    NSArray *updatedDiaries = [self getDiaryUpdate:context];
    NSMutableDictionary *serverMap = [NSMutableDictionary dictionaryWithCapacity:5];
    NSString *serverDate;
    for (int i = 0; i < [dataFromService count]; i++) {
        singleData = [dataFromService objectAtIndex:i];
        serverDate = [singleData valueForKeyPath:@"d"];
        notUpdate = [self getDiaryNotUpdate:context dateStr:serverDate];
        [serverMap setValue:@"1" forKey:serverDate];
        if ([notUpdate count] == 0) {
            [self insertSingleDiary:[singleData valueForKeyPath:@"d"] keyword:[singleData valueForKeyPath:@"content"] updateTime:[self strToDateByFormat:[singleData valueForKeyPath:@"created"] format:@"yyyy-MM-dd HH:mm:ss"] context:context];
        } else {
            NSLog(@"not update %@", [singleData valueForKey:@"d"]);
            singleCoreData = [notUpdate objectAtIndex:0];
            [singleCoreData setValue:[singleData valueForKeyPath:@"content"] forKey:@"keyword_server"];
        }
    }

    for (int j = 0; j < [updatedDiaries count]; j++) {
        singleCoreData = [updatedDiaries objectAtIndex:j];
        if (![serverMap valueForKey:[singleCoreData valueForKey:@"dateStr"]]) {
            NSLog(@"delete core data if not exist on server %@", [singleCoreData valueForKey:@"dateStr"]);
            [context deleteObject:singleCoreData];
        }
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        }
        else {
            NSLog(@"  %@", [error userInfo]);
        }
        
        abort();
    }
}
/* 获取本地所有日记 */
- (NSArray *)getAllDiary
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];// 为什么不用self.managedObjectContext
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error;
    return [context executeFetchRequest:request error:&error];
}
/* 获取本地某天未发送成功的日记 */
- (NSArray *)getDiaryNotUpdate:(NSManagedObjectContext *)context dateStr:(NSString *)dateStr
{
    
    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];// 为什么不用self.managedObjectContext
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    // Set the predicate -- much like a WHERE statement in a SQL database
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"update != 0 and dateStr == %@", dateStr];
    [request setPredicate:predicate];
    
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error;
    return [context executeFetchRequest:request error:&error];
}
/* 获取所有更新状态为成功的日记 */
- (NSArray *)getDiaryUpdate:(NSManagedObjectContext *)context
{
    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];// 为什么不用self.managedObjectContext
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    // Set the predicate -- much like a WHERE statement in a SQL database
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"update == 0"];
    [request setPredicate:predicate];
    
    // Set the sorting -- mandatory, even if you're fetching a single record/object
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSError *error;
    return [context executeFetchRequest:request error:&error];
}
/* 删除本地数据，但并不保存 */
- (void)deleteAllDiary:(NSManagedObjectContext *)context
{
    NSArray *result =  [self getAllDiary];
    //NSLog(@"deleteAllDiary %@", result);

    for (int i = 0; i < [result count]; i++) {
        [context deleteObject:[result objectAtIndex:i]];
    }
}
- (void)insertSingleDiary:(NSString *)dateStr keyword:(NSString *)keyword updateTime:(NSDate *)updateTime context:(NSManagedObjectContext *)context
{    
    NSArray *result = [self getDiaryExist:dateStr];
    if ([result count] > 0) {
        NSManagedObject *diary = [result objectAtIndex:0];
        [diary setValue:@"0" forKey:@"update"];
        [diary setValue:keyword forKey:@"keyword"];
        [diary setValue:updateTime forKey:@"date"];
    } else {
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *detail = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [detail setValue:@"0" forKey:@"update"];
        [detail setValue:keyword forKey:@"keyword"];
        [detail setValue:dateStr forKey:@"dateStr"];
        [detail setValue:updateTime forKey:@"date"];
    }
    NSLog(@"insertSingleDiary %@, %@", dateStr, keyword);

}

/* 控制login form 显示 */
- (void) hideLoginForm:(id)sender
{
    self.loginContainer.hidden = YES;
    //[self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void) showLoginForm:(id)sender
{
    [self.loginForm setLoginForm:_username password:_password];
    [self.sidePanelController showCenterPanelAnimated:YES];
    self.loginContainer.hidden = NO;
    [self.view bringSubviewToFront:self.loginContainer];
}

/* 控制 edit form 显示 */
- (void) hideEditForm:(id)sender
{
    NSLog(@"DiaryViewController hideEditForm ");
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
/* 显示编辑界面 */
- (void) showEditForm:(id)sender
{
    //self.editContainer.hidden = NO;
    [self presentPopupViewController:self.editForm animationType:MJPopupViewAnimationFade];

}
- (void)showEditFormForCell:(NSString *)date keyword:(NSString *)keyword sectionIndex:(NSInteger)section rowIndex:(NSInteger)row sync:(BOOL)sync
{
    [self.editForm setFormInfo:date keyword:keyword sectionIndex:section rowIndex:row sync:sync];
    [self showEditForm:nil];
}
- (IBAction)showEdit:(id)sender {
    [self showEditForm:sender];
}

/* 控制 setting view 显示 */
- (IBAction)showSetting:(id)sender {
    NSLog(@"show setting");
    [self.sidePanelController showRightPanelAnimated:YES];
}
/* 更新日记的状态 */
- (BOOL)updateStatusInDiary:(NSString *)dateStr success:(NSString *)success
{
    NSLog(@"updateStatusInDiary date-%@ success-%@", dateStr, success);
    NSArray *result = [self getDiaryExist:dateStr];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];// 为什么不用self.managedObjectContext
    if ([result count] > 0) {
        NSManagedObject *diary = [result objectAtIndex:0];
        [diary setValue:success forKey:@"update"];
        [diary setValue:[self getCurrentDate] forKey:@"date"];
    } else {
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *detail = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [detail setValue:success forKey:@"update"];
        [detail setValue:dateStr forKey:@"dateStr"];
        [detail setValue:[self getCurrentDate] forKey:@"date"];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        abort();
        return NO;
    }
    return YES;
}
/* 更新日记关键词，可以设置update status 0success,1fail,2sending */
- (BOOL)updateKeywordInDiary:(NSString *)dateStr keyword:(NSString *)keyword success:(NSString *)success
{
    NSLog(@"updateKeywordInDiary date-%@  keyword-%@ success-%@", dateStr, keyword, success);
    NSArray *result = [self getDiaryExist:dateStr];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];// 为什么不用self.managedObjectContext
    if ([result count] > 0) {
        NSManagedObject *diary = [result objectAtIndex:0];
        [diary setValue:success forKey:@"update"];
        [diary setValue:keyword forKey:@"keyword"];
        [diary setValue:[self getCurrentDate] forKey:@"date"];
    } else {
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *detail = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [detail setValue:success forKey:@"update"];
        [detail setValue:keyword forKey:@"keyword"];
        [detail setValue:dateStr forKey:@"dateStr"];
        [detail setValue:[self getCurrentDate] forKey:@"date"];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        abort();
        return NO;
    } else {
        return YES;
    }
}
/* 丢弃未同步的日记关键词，可以设置update status 0success,1fail,2sending */
- (BOOL)dropKeywordInDiary:(NSString *)dateStr
{
    NSLog(@"dropKeywordInDiary date-%@", dateStr);
    NSArray *result = [self getDiaryExist:dateStr];
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];// 为什么不用self.managedObjectContext
    NSLog(@"dropKeywordInDiary reslut : %@", result);
    if ([result count] > 0) {
        NSManagedObject *diary = [result objectAtIndex:0];
        [diary setValue:@"0" forKey:@"update"];
        [diary setValue:[diary valueForKey:@"keyword_server"] forKey:@"keyword"];
        [diary setValue:[self getCurrentDate] forKey:@"date"];
    }
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        abort();
        return NO;
    } else {
        return YES;
    }
}
/* 更新日记的接口 */
- (void) updateDiary:(NSString *)dateStr keyword:(NSString *)keyword sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
{
    NSLog(@"diary view controller update diary %@ section - %d row - %d", keyword, section, row);

    [self hideEditForm:nil];
    [self showProgress:NSLocalizedString(@"Upload Diary...", nil)];
    //[self showNotification:@"Sending Diary ..." activity:YES delay:0];
    DiaryRequest *request = [[DiaryRequest alloc] init];
    request.delegate = self;
    [request insertDiary:_username password:_password dateStr:dateStr keyword:keyword sectionIndex:section rowIndex:row];
    NSArray *dateArr = [dateStr componentsSeparatedByString:@" - "];
    BOOL saveToCore = [self updateKeywordInDiary:[dateArr componentsJoinedByString:@"-"] keyword:keyword success:@"2"];
    if (saveToCore) {
        NSLog(@"updateDiary saveToCore success");
        UITableView *tableView = [self getCurrentTableView];
        [self configureCell:(DiaryViewCell *)[tableView cellForRowAtIndexPath:_currentSelectCell] atIndexPath:_currentSelectCell tableView:tableView];
    } else {
        NSLog(@"updateDiary saveToCore fail");
        [self showAlertView:NSLocalizedString(@"Save Data Error", nil)];
    }
}
/* 删除日记 */
- (void) deleteDiary:(NSString *)dateStr sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
{
    NSLog(@"Diary view controller deleteDiary");
    [self hideEditForm:nil];
    [self showProgress:NSLocalizedString(@"Deleting Diary...", nil)];
    DiaryRequest *request = [[DiaryRequest alloc] init];
    request.delegate = self;
    [request deleteDiary:_username password:_password dateStr:dateStr sectionIndex:section rowIndex:row];
    
    BOOL saveToCore = [self updateKeywordInDiary:dateStr keyword:@"" success:@"2"];
    if (saveToCore) {
        NSLog(@"deleteDiary saveToCore success");
        UITableView *tableView = [self getCurrentTableView];
        [self configureCell:(DiaryViewCell *)[tableView cellForRowAtIndexPath:_currentSelectCell] atIndexPath:_currentSelectCell tableView:tableView];
    } else {
        NSLog(@"deleteDiary saveToCore fail");
        [self showAlertView:NSLocalizedString(@"Save Data Error", nil)];
    }
}
- (void) dropDiary:(NSString *)dateStr sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
{
    [self hideEditForm:nil];
    [self showProgress:NSLocalizedString(@"Droping Diary...", nil)];
    BOOL saveToCore = [self dropKeywordInDiary:dateStr];
    if (saveToCore) {
        NSLog(@"dropDiary saveToCore success");
        UITableView *tableView = [self getCurrentTableView];
        [self configureCell:(DiaryViewCell *)[tableView cellForRowAtIndexPath:_currentSelectCell] atIndexPath:_currentSelectCell tableView:tableView];
    } else {
        NSLog(@"updateDiary saveToCore fail");
        [self showAlertView:NSLocalizedString(@"Save Data Error", nil)];
    }
}
/* tools */
/* 根据sectionInex, rowIndex计算日期 */
- (NSString *)getDateStrBySectionRow:(NSInteger)section row:(NSInteger)row
{
    NSDate *monthDate = [self getSectionMonth:section];
    NSString *year = [self dateToStrByFormat:monthDate format:@"yyyy"];
    NSString *month = [self dateToStrByFormat:monthDate format:@"MM"];
    NSString *rowStr;
    if (row > 8) {
        rowStr = [NSString stringWithFormat:@"%d", row + 1];
    } else {
        rowStr = [NSString stringWithFormat:@"0%d", row + 1];
    }
    return [NSString stringWithFormat:@"%@-%@-%@", year, month, rowStr];
}
/* 计算从开始到现在的间隔月数 */
- (NSInteger)getMonthCount:(NSDate *)startDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:startDate toDate:_currentDate options:0];
    
    if ([components month] < 3) {
        return 3;
    }
    return [components month] + 1;
    //NSInteger days = [components day];
}
/* 计算start到end的天数 */
- (NSInteger)getDateCount:(NSDate *)startDate endDate:(NSDate *)endDate
{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:startDate toDate:endDate options:0];
    
    return [components day] + 1;
}

/* 计算当前月的天数 */

- (NSInteger)getMonthDays:(NSDate *)date
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return days.length;
}

/* 月份递增或递减 */
- (NSDate *)getMonthByOffset:(NSDate *)date offset:(NSInteger)offset
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    // now build a NSDate object for the next day
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:offset];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:date options:0];
    return nextDate;
}

- (NSDate *)getCurrentDate
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}

- (NSString *)dateToStrByFormat:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

- (NSDate *)strToDateByFormat:(NSString *)dateStr format:(NSString *)format
{
    NSDateFormatter *dateFormat =[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [dateFormat dateFromString:dateStr];

}
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentSelectCell = nil;
    NSLog(@"willDeselectRowAtIndexPath %d", [indexPath row]);
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath %d", [indexPath row]);
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentSelectCell = indexPath;
    //NSLog(@"didSelectRowAtIndexPath=============== %d", [indexPath row]);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *dayLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *keywordLabel = (UILabel *)[cell viewWithTag:2];
    NSString *date = [NSString stringWithFormat:@"%@ - %@", self.monthLabel.text, dayLabel.text];
    NSInteger sectionIndex = [self getSectionIndex:self.sliderPageControl.currentPage currentSection:_currentSectionIndex tableView:tableView];
    [self showEditFormForCell:date keyword:keywordLabel.text sectionIndex:sectionIndex rowIndex:[indexPath row] sync:NO];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = [self getSectionIndex:self.sliderPageControl.currentPage currentSection:_currentSectionIndex tableView:tableView];
    if((sectionIndex == [self getMonthCount:_userStartDate] - 1) && ([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row)){
       // NSLog(@"end loading tag - %d, row - %d, section - %d", tableView.tag, [indexPath row], sectionIndex);
        [self scrollToBottom:tableView animate:YES];

    }
}

@end
