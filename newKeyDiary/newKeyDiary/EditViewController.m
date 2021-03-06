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
#import "DateExtend.h"

@interface EditViewController ()

- (IBAction)backToDiary:(id)sender;
- (IBAction)saveDiary:(id)sender;
- (IBAction)dateChange:(id)sender;
- (IBAction)deleteButton:(id)sender;

@end

@implementation EditViewController{
    NSDateFormatter *dateFormatYMD;
    NSDateFormatter *dateFormatYM;
    NSDateFormatter *dateFormatD;
    NSString *keywordBefore;
    BOOL forSync;
    UIColor *_themeColor;
    DateExtend *_current;
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
    
    _themeColor = [UIColor colorWithRed:69/255.0 green:212/255.0 blue:218/255.0 alpha:1.0];
    [self.saveButton setBackgroundColor:_themeColor];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.layer.cornerRadius = 5.0f;
    
    self.closeButton.layer.cornerRadius = 5.0f;
    [self.closeButton setTitleColor:_themeColor forState:UIControlStateNormal];
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

- (void)setFormInfo:(DateExtend *)date keyword:(NSString *)keyword sectionIndex:(NSInteger)section rowIndex:(NSInteger)row sync:(BOOL)sync
{
    //NSLog(@"setFormInfo section - %d, row - %d", section, [date weekday]);
    //[self.KeywordField becomeFirstResponder];
    _current = date;
    keywordBefore = keyword;
    self.KeywordField.backgroundColor = [UIColor whiteColor];
    self.DateField.text =  [NSString stringWithFormat:@"%@ %@", [_current toString:@"yyyy-MM-dd"], [self getWeekdayChinese:[_current weekday]]];
    self.KeywordField.text = keyword;
    self.sectionIndex = section;
    self.rowIndex = row;
    forSync = sync;
    
    if (sync) {
        [self.saveButton setTitle:NSLocalizedString(@"Save Again", nil) forState:UIControlStateNormal];
        [self.deleteButton setTitle:NSLocalizedString(@"Drop", nil) forState:UIControlStateNormal];
    } else {
        [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        [self.deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    }
    [self.saveButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.saveButton sizeToFit];
    CGRect buttonFrame = self.saveButton.frame;
    CGRect frame = self.view.frame;
    [self.saveButton setFrame:CGRectMake(frame.size.width - 12 - buttonFrame.size.width, buttonFrame.origin.y, buttonFrame.size.width, buttonFrame.size.height)];
}


- (IBAction)saveDiary:(id)sender {
    [self doSave];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.DateField) {
        return NO;
    } else if (textField == self.KeywordField) {
        [self.delegate editFormMoveToTop];
    }
    //NSLog(@"textFieldShouldBeginEditing");
    return YES;
}

- (NSString *)getWeekdayChinese:(NSInteger)weekday{
    NSString *str;
    switch (weekday) {
        case 1:
            str = NSLocalizedString(@"Sun", nil);
            break;
        case 2:
            str = NSLocalizedString(@"Mon", nil);
            break;
        case 3:
            str = NSLocalizedString(@"Tue", nil);
            break;
        case 4:
            str = NSLocalizedString(@"Wed", nil);
            break;
        case 5:
            str = NSLocalizedString(@"Thu", nil);
            break;
        case 6:
            str = NSLocalizedString(@"Fri", nil);
            break;
        case 7:
            str = NSLocalizedString(@"Sat", nil);
            break;
        default:
            str = @"";
            break;
    }
    return str;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *newStringClean = [self getCleanString:newString];
    //NSLog(@"shouldChangeCharactersInRange %d %@", [self getKeywordCount:newStringClean], newStringClean);
    //区分中文7个字和英文14个字 todo
    if ([self getKeywordCount:newStringClean] > 14) {
        self.KeywordField.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
    } else {
        self.KeywordField.backgroundColor = [UIColor whiteColor];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.KeywordField) {
        //NSLog(@"textFieldShouldReturn");

        [theTextField resignFirstResponder];
        [self.delegate editFormMoveToCenter];
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
        [self.delegate editFormMoveToCenter];
    }
    [super touchesBegan:touches withEvent:event];
}
- (void)doSave
{
    //NSLog(@"doSave section - %d, row - %d", self.sectionIndex, self.rowIndex);
    NSString *keyword = self.KeywordField.text;
    NSString *cleanString = [self getCleanString:keyword];
    
    //NSLog(@"doSave %@ %d", cleanString, [self getKeywordCount:cleanString]);
    if ([self getKeywordCount:cleanString] > 14) {
        self.KeywordField.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not more than 14 characters", nil) message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    } else {
        [self.KeywordField resignFirstResponder];
        [self.delegate editFormMoveToCenter];
        self.KeywordField.backgroundColor = [UIColor whiteColor];
        NSString *dateStr = [_current toString:@"yyyy-MM-dd"];
        if ([cleanString isEqualToString:@""]) {
            [self.delegate deleteDiary:dateStr sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
        } else {
            [self.delegate updateDiary:dateStr keyword:keyword sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
        }
    }
}

- (NSInteger)getKeywordCount:(NSString *)keyword
{
     NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSUInteger bytes = [keyword lengthOfBytesUsingEncoding:enc];
    return bytes;
}

- (NSString *)getCleanString:(NSString *)origin {
    NSString *newStringClean = [origin stringByReplacingOccurrencesOfString:@" " withString:@""];
    //newStringClean = [newStringClean stringByReplacingOccurrencesOfString:@"," withString:@""];
    //newStringClean = [newStringClean stringByReplacingOccurrencesOfString:@"." withString:@""];
    //newStringClean = [newStringClean stringByReplacingOccurrencesOfString:@"。" withString:@""];
    //newStringClean = [newStringClean stringByReplacingOccurrencesOfString:@"，" withString:@""];
    return newStringClean;
}


- (IBAction)deleteButton:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure to delete?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles: nil];
    [sheet showInView:[self.delegate getSelfView]];
}
- (void)viewDidUnload {
    [self setSaveButton:nil];
    [self setDeleteButton:nil];
    [self setCloseButton:nil];
    [super viewDidUnload];
}

/* action delegate */
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"didDismissWithButtonIndex %@ %d", [actionSheet buttonTitleAtIndex:buttonIndex], buttonIndex);
    NSString *str = [_current toString:@"yyyy-MM-dd"];
    if (buttonIndex == 0) {
        if (forSync) {
            [self.delegate dropDiary:str sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
        } else {
            [self.delegate deleteDiary:str sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
        }
    }
}
- (IBAction)closeClick:(id)sender {
    [self.delegate hideEditForm:nil];
}

- (void)setFieldFocus {
    [self.KeywordField becomeFirstResponder];
}

@end
