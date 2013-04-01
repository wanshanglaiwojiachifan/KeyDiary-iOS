//
//  DiaryViewCell.h
//  newKeyDiary
//
//  Created by Black Black on 3/22/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiaryViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *monthLabel;
@property (nonatomic, retain) IBOutlet UILabel *keywordLabel;
@property (nonatomic, retain) IBOutlet UIButton *noticeButton;

@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) NSInteger sectionIndex;

@end
