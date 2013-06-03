//
//  DateExtend.h
//  DateExtend
//
//  Created by MissDora on 5/28/13.
//  Copyright (c) 2013 MissDora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateExtend : NSObject {
    NSCalendar *calendar;
}

@property (retain, nonatomic) NSDate *date;
@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) NSInteger month;
@property (assign, nonatomic) NSInteger day;
@property (assign, nonatomic) NSInteger weekday;
@property (assign, nonatomic) NSInteger week;
@property (assign, nonatomic) NSInteger weekOfYear;
@property (assign, nonatomic) NSInteger weekOfMonth;
@property (assign, nonatomic) NSInteger hour;
@property (assign, nonatomic) NSInteger minute;
@property (assign, nonatomic) NSInteger second;



- (id) initWithCalendar:(NSCalendar *)ca;
- (id) initWithCalendar:(NSCalendar *)ca dateStr:(NSString *)dateStr dateFormat:(NSString *)dateFormat;
- (id) initWithCalendar:(NSCalendar *)ca date:(NSDate *)d;
- (NSString *) toString:(NSString *)format;

/* 计算与dateB间隔的天数 */
- (NSInteger) diffDay:(DateExtend *)dateB;
/* 计算与dateB间隔的周数 */
- (NSInteger) diffWeek:(DateExtend *)dateB;
/* 计算与dateB间隔的月份数 */
- (NSInteger) diffMonth:(DateExtend *)dateB;

/* 通过间隔天数获取新日期 */
- (DateExtend *) dateByDayOffset:(NSInteger)offset;
/* 通过间隔周数获取新日期 */
- (DateExtend *) dateByWeekOffset:(NSInteger)offset;
/* 通过间隔月数获取新日期 */
- (DateExtend *) dateByMonthOffset:(NSInteger)offset;

@end
