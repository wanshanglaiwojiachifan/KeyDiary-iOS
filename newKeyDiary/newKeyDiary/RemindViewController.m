//
//  RemindViewController.m
//  newKeyDiary
//
//  Created by Black Black on 3/27/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "RemindViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RemindViewController ()

@end

@implementation RemindViewController {
    UIColor *_themeColor;
}

@synthesize hourNumber;
@synthesize minuteNumber;
@synthesize timeStr;

- (IBAction)switchAlert:(id)sender {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (IBAction)hourMinus:(id)sender {
    self.hourNumber--;
    if (self.hourNumber < 0) {
        self.hourNumber = 0;
    }
    [self chageTimeLabel:self.hourNumber minute:self.minuteNumber];
}

- (IBAction)hourPlus:(id)sender {
    self.hourNumber++;
    if (self.hourNumber > 23) {
        self.hourNumber = 23;
    }
    [self chageTimeLabel:self.hourNumber minute:self.minuteNumber];
}

- (IBAction)minutePlus:(id)sender {
    self.minuteNumber += 10;
    if (self.minuteNumber > 59) {
        self.minuteNumber = 59;
    }
    [self chageTimeLabel:self.hourNumber minute:self.minuteNumber];
}

- (IBAction)minuteMinus:(id)sender {
    self.minuteNumber -= 10;
    if (self.minuteNumber < 0) {
        self.minuteNumber = 0;
    }
    [self chageTimeLabel:self.hourNumber minute:self.minuteNumber];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveAlert:(id)sender {
    NSString *hourStr = [self getTimeStr:self.hourNumber];
    NSString *minuteStr = [self getTimeStr:self.minuteNumber];
    if ([self.switchButton isOn]) {
        [self.delegate setRemindTime:[NSString stringWithFormat:@"%@:%@", hourStr, minuteStr]];
    } else {
        [self.delegate setRemindTime:@"NO"];
    }
}

- (void)viewDidUnload {
    [self setSwitchButton:nil];
    [self setSaveButton:nil];
    [self setHourUpButton:nil];
    [self setMinuteUpButton:nil];
    [self setHourDownButton:nil];
    [self setMinuteDownButton:nil];
    [super viewDidUnload];
}

- (void)initRemindView:(NSString *)str
{
    _themeColor = [UIColor colorWithRed:69/255.0 green:212/255.0 blue:218/255.0 alpha:1.0];
    [self.saveButton setBackgroundColor:_themeColor];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.layer.cornerRadius = 5.0f;
    
    /*
    [self.hourDownButton setBackgroundColor:_themeColor];
    [self.hourDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.hourDownButton.layer.cornerRadius = 20.0f;

    [self.hourUpButton setBackgroundColor:_themeColor];
    [self.hourUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.hourUpButton.layer.cornerRadius = 15.0f;
    
    [self.minuteUpButton setBackgroundColor:_themeColor];
    [self.minuteUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.minuteUpButton.layer.cornerRadius = 20.0f;
    
    [self.minuteDownButton setBackgroundColor:_themeColor];
    [self.minuteDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.minuteDownButton.layer.cornerRadius = 20.0f;*/
    
    if ([str isEqualToString:@"NO"]) {
        [self.switchButton setOn:NO];
    } else {
        [self.switchButton setOn:YES];
    }
    NSArray *arr = [str componentsSeparatedByString:@":"];
    if ([arr count] > 1) {
        self.hourNumber = [[arr objectAtIndex:0] intValue];
        self.minuteNumber = [[arr objectAtIndex:1] intValue];
    } else {
        self.hourNumber = 12;
        self.minuteNumber = 0;
    }
    [self chageTimeLabel:self.hourNumber minute:self.minuteNumber];
}

- (NSString *)getTimeStr:(NSInteger)time
{
    if (time > 9) {
        return [NSString stringWithFormat:@"%d", time];
    } else {
        return [NSString stringWithFormat:@"0%d", time];
    }
}

- (void)chageTimeLabel:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *hourStr;
    if (hour > 9) {
        hourStr = [NSString stringWithFormat:@"%d", hour];
    } else {
        hourStr = [NSString stringWithFormat:@"0%d", hour];
    }
    
    NSString *minuteStr;
    if (minute > 9) {
        minuteStr = [NSString stringWithFormat:@"%d", minute];
    } else {
        minuteStr = [NSString stringWithFormat:@"0%d", minute];
    }
    self.hourLabel.text = hourStr;
    self.minuteLabel.text = minuteStr;
}
@end
