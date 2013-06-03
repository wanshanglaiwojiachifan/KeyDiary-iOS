//
//  EditViewController.h
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleDay.h"
#import "DateExtend.h"
@class EditViewController;
@protocol EditViewControllerDelegate <NSObject>

- (void)hideEditForm:(id)sender;
- (void)updateDiary:(NSString *)dateStr keyword:(NSString *)keyword sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
;
- (void) deleteDiary:(NSString *)dateStr sectionIndex:(NSInteger)section rowIndex:(NSInteger)row;
- (void) dropDiary:(NSString *)dateStr sectionIndex:(NSInteger)section rowIndex:(NSInteger)row;
- (void) editFormMoveToCenter;
- (void) editFormMoveToTop;
- (UIView *)getSelfView;

@end

@interface EditViewController : UIViewController<UITextFieldDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UITextField *KeywordField;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UITextField *DateField;
@property (nonatomic, weak) id<EditViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) NSInteger sectionIndex;

- (void)setFormInfo:(DateExtend *)date keyword:(NSString *)keyword sectionIndex:(NSInteger)section rowIndex:(NSInteger)row sync:(BOOL)sync;

@end
