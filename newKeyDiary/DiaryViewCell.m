//
//  DiaryViewCell.m
//  newKeyDiary
//
//  Created by Black Black on 3/22/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "DiaryViewCell.h"

@implementation DiaryViewCell

//@synthesize monthLabel;
//@synthesize keywordLabel;
//@synthesize noticeButton;
@synthesize rowIndex;
@synthesize sectionIndex;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
