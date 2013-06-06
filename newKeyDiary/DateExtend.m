//
//  DateExtend.m
//  DateExtend
//
//  Created by MissDora on 5/28/13.
//  Copyright (c) 2013 MissDora. All rights reserved.
//

#import "DateExtend.h"

@implementation DateExtend

@synthesize year;
@synthesize month;
@synthesize day;
@synthesize weekday;
@synthesize week;
@synthesize weekOfMonth;
@synthesize weekOfYear;
@synthesize hour;
@synthesize minute;
@synthesize second;

- (id) initWithCalendar:(NSCalendar *)ca {
    self = [super init];
    if (self) {
        calendar = ca;
        [calendar setTimeZone:[NSTimeZone systemTimeZone]];
        
        self.date = [[NSDate alloc] init];
    }
    return self;
}

- (id) initWithCalendar:(NSCalendar *)ca dateStr:(NSString *)dateStr dateFormat:(NSString *)dateFormat {
    self = [super init];
    if (self) {
        calendar = ca;
        [calendar setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:dateFormat];
        self.date = [dateFormatter dateFromString:dateStr];
    }
    return self;
}

- (id) initWithCalendar:(NSCalendar *)ca date:(NSDate *)d {
    self = [super init];
    if (self) {
        calendar = ca;
        [calendar setTimeZone:[NSTimeZone systemTimeZone]];
        self.date = d;
    }
    return self;
}

- (NSString *) toString:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self.date];
}

- (NSDateComponents *) getDateComponents:(NSInteger)calendarUnit {
     return [calendar components:calendarUnit fromDate:self.date];
}

- (NSInteger) year {
    if (!year) {
        year = [[self getDateComponents:NSYearCalendarUnit] year];
    }
    return year;
}

- (NSInteger) month {
    if (!month) {
        month = [[self getDateComponents:NSMonthCalendarUnit] month];
    }
    return month;
}

- (NSInteger) day {
    if (!day) {
        day = [[self getDateComponents:NSDayCalendarUnit] day];
    }
    return day;
}

- (NSInteger) weekOfYear {
    if (!weekOfYear) {
        weekOfYear = [[self getDateComponents:NSWeekOfYearCalendarUnit] weekOfYear];
    }
    return weekOfYear;
}

- (NSInteger) weekOfMonth {
    if (!weekOfMonth) {
        weekOfMonth = [[self getDateComponents:NSWeekOfMonthCalendarUnit] weekOfMonth];
    }
    return  weekOfMonth;
}

- (NSInteger) week {
    return [self weekOfYear];
}

- (NSInteger) weekday {
    if (!weekday) {
        weekday = [[self getDateComponents:NSWeekdayCalendarUnit] weekday];
    }
    return weekday;
}

- (NSInteger) hour {
    if (!hour) {
        hour = [[self getDateComponents:NSHourCalendarUnit] hour];
    }
    return hour;
}

- (NSInteger) minute {
    if (!minute) {
        minute = [[self getDateComponents:NSMinuteCalendarUnit] minute];
    }
    return minute;
}

- (NSInteger) second {
    if (!second) {
        second = [[self getDateComponents:NSSecondCalendarUnit] second];
    }
    return second;
}

/* ================function start ======================= */

- (NSInteger) diffDay:(DateExtend *)dateB {
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit) fromDate:self.date toDate:dateB.date options:0];
    return [components day];
}

- (NSInteger) diffWeek:(DateExtend *)dateB {
    NSDateComponents *components = [calendar components:(NSWeekCalendarUnit) fromDate:self.date toDate:dateB.date options:0];
    return [components week];
}

- (NSInteger) diffMonth:(DateExtend *)dateB {
    NSDateComponents *components = [calendar components:(NSMonthCalendarUnit) fromDate:self.date toDate:dateB.date options:0];
    return [components month];
}

- (DateExtend *) dateByDayOffset:(NSInteger)offset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:offset];
    
    return [[DateExtend alloc] initWithCalendar:calendar date:[calendar dateByAddingComponents:components toDate:self.date options:0]];
}

- (DateExtend *) dateByMonthOffset:(NSInteger)offset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:offset];
    
    return [[DateExtend alloc] initWithCalendar:calendar date:[calendar dateByAddingComponents:components toDate:self.date options:0]];
}

- (DateExtend *) dateByWeekOffset:(NSInteger)offset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeek:offset];
    
    return [[DateExtend alloc] initWithCalendar:calendar date:[calendar dateByAddingComponents:components toDate:self.date options:0]];
}


@end
