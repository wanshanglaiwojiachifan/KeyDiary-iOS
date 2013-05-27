//
//  EditViewController.m
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "EditViewController.h"
#import "SingleDay.h"
#import "DiaryViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface EditViewController ()

- (IBAction)backToDiary:(id)sender;
- (IBAction)saveDiary:(id)sender;
- (IBAction)dateChange:(id)sender;
- (IBAction)deleteButton:(id)sender;

@end

@implementation EditViewController{
    NSString *currentDateStr;
    NSDateFormatter *dateFormatYMD;
    NSDateFormatter *dateFormatYM;
    NSDateFormatter *dateFormatD;
    NSString *keywordBefore;
    BOOL forSync;
    UIColor *_themeColor;
}

@synthesize delegate;
@synthesize sectionIndex;
@synthesize rowIndex;

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
    
    dateFormatYMD = [[NSDateFormatter alloc] init];
    [dateFormatYMD setDateFormat:@"yyyy-MM-dd"];

    dateFormatYM = [[NSDateFormatter alloc] init];
    [dateFormatYM setDateFormat:@"yyyy-MM"];
    
    dateFormatD = [[NSDateFormatter alloc] init];
    [dateFormatD setDateFormat:@"dd"];

    currentDateStr = [self getYMD:[NSDate date]];
    self.DateField.text = currentDateStr;
    
    _themeColor = [UIColor colorWithRed:69/255.0 green:212/255.0 blue:218/255.0 alpha:1.0];
    [self.saveButton setBackgroundColor:_themeColor];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.layer.cornerRadius = 5.0f;
    
    self.deleteButton.layer.cornerRadius = 5.0f;
    [self.deleteButton setTitleColor:_themeColor forState:UIControlStateNormal];
}

- (NSString *)getYearAndMonth:(NSDate *)date{
    return [dateFormatYM stringFromDate:date];
}

- (NSString *)getYMD:(NSDate *)date{
    return [dateFormatYMD stringFromDate:date];
}

- (NSString *)getD:(NSDate *)date{
    return [dateFormatD stringFromDate:date];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFormInfo:(NSString *)date keyword:(NSString *)keyword sectionIndex:(NSInteger)section rowIndex:(NSInteger)row sync:(BOOL)sync
{
    NSLog(@"setFormInfo section - %d, row - %d", section, row);
    //[self.KeywordField becomeFirstResponder];

    keywordBefore = keyword;
    self.DateField.text = date;
    self.KeywordField.text = keyword;
    self.sectionIndex = section;
    self.rowIndex = row;
    currentDateStr = date;
    forSync = sync;
    
    if (sync) {
        [self.saveButton setTitle:NSLocalizedString(@"Save Again", nil) forState:UIControlStateNormal];
        [self.deleteButton setTitle:NSLocalizedString(@"Drop", nil) forState:UIControlStateNormal];
    } else {
        [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    }
}

/*- (IBAction)backToDiary:(id)sender {
    NSLog(@"edit view controller backToDiary");
    [self.delegate hideEditForm:sender];
}*/

- (IBAction)saveDiary:(id)sender {
    [self.KeywordField resignFirstResponder];

    [self doSave];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.DateField) {
        return NO;
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *newStringClean = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"shouldChangeCharactersInRange %d %@", [self getKeywordCount:newStringClean], newStringClean);
    //区分中文7个字和英文14个字 todo
    if ([self getKeywordCount:newStringClean] > 14) {
        self.KeywordField.backgroundColor = [UIColor redColor];
    } else {
        self.KeywordField.backgroundColor = [UIColor whiteColor];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.KeywordField) {
        [theTextField resignFirstResponder];
    }
    //[self doSave];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //[[self view] endEditing:YES];

    UITouch *touch = [[event allTouches] anyObject];
    if ([self.KeywordField isFirstResponder] && [touch view] != self
        .KeywordField) {
        [self.KeywordField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
- (void)doSave
{
    NSLog(@"doSave section - %d, row - %d", self.sectionIndex, self.rowIndex);
    NSString *keyword = self.KeywordField.text;
    NSString *cleanString = [keyword stringByReplacingOccurrencesOfString:@" " withString:@""];//[keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    //NSLog(@"doSave %@ %d", cleanString, [self getKeywordCount:cleanString]);
    if ([self getKeywordCount:cleanString] > 14) {
        NSLog(@"key word > 14");
        self.KeywordField.backgroundColor = [UIColor redColor];
    } else {
        self.KeywordField.backgroundColor = [UIColor whiteColor];
        if ([cleanString isEqualToString:@""]) {
            [self.delegate deleteDiary:currentDateStr sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
        } else {
            [self.delegate updateDiary:currentDateStr keyword:keyword sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
        }
    }
}

- (NSInteger)getKeywordCount:(NSString *)keyword
{    
     NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSUInteger bytes = [keyword lengthOfBytesUsingEncoding:enc];
    return bytes;
}



- (IBAction)deleteButton:(id)sender {
    if (forSync) {
        [self.delegate dropDiary:currentDateStr sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
    } else {
        [self.delegate deleteDiary:currentDateStr sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
    }
}
- (void)viewDidUnload {
    [self setSaveButton:nil];
    [self setDeleteButton:nil];
    [super viewDidUnload];
}
@end
