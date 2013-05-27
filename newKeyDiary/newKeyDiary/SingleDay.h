//
//  SingleDay.h
//  KeyDiary
//
//  Created by Black Black on 3/15/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleDay : NSObject

@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *keyword;
@property (copy, nonatomic) NSString *dateStr;
@property (nonatomic, assign) BOOL update;

@end
