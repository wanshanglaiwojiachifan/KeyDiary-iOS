//
//  NSObject+DiaryRequest.h
//  newKeyDiary
//
//  Created by Black Black on 3/24/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DiaryRequest;

@protocol DiaryRequestDelegate <NSObject>

- (void)insertDiaryCallback:(NSDictionary *)insertInfo code:(NSInteger)code sectionIndex:(NSInteger)section rowIndex:(NSInteger)row;
- (void)deleteDiaryCallback:(NSDictionary *)deleteInfo code:(NSInteger)code sectionIndex:(NSInteger)section rowIndex:(NSInteger)row;
- (void)setRemindTimeCallback:(NSDictionary *)remindInfo code:(NSInteger)code;

@end
@interface DiaryRequest : NSObject

@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, weak) id <DiaryRequestDelegate> delegate;
- (void)insertDiary:(NSString *)username password:(NSString *)password dateStr:(NSString *)dateStr keyword:(NSString *)keyword sectionIndex:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex;
- (void)deleteDiary:(NSString *)username password:(NSString *)password dateStr:(NSString *)dateStr  sectionIndex:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex;
- (void)setRemindTime:(NSString *)username password:(NSString *)password remindTime:(NSString *)remindTime;

@end
