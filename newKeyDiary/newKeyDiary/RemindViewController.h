//
//  RemindViewController.h
//  newKeyDiary
//
//  Created by Black Black on 3/27/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RemindViewController;
@protocol RemindViewControllerDelegate <NSObject>
- (void)setRemindTime:(NSString *)remindTime;
@end


@interface RemindViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *minuteDownButton;
@property (strong, nonatomic) IBOutlet UIButton *hourDownButton;
@property (strong, nonatomic) IBOutlet UIButton *minuteUpButton;
@property (strong, nonatomic) IBOutlet UIButton *hourUpButton;
@property (strong, nonatomic) IBOutlet UILabel *minuteLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *hourLabel;
@property (strong, nonatomic) IBOutlet UISwitch *switchButton;
- (IBAction)saveAlert:(id)sender;
@property (nonatomic, weak) id<RemindViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *timeStr;
@property (nonatomic, assign) NSInteger hourNumber;
@property (nonatomic, assign) NSInteger minuteNumber;
- (void)chageTimeLabel:(NSInteger)hour minute:(NSInteger)minute;
- (void)initRemindView:(NSString *)str;
@end
