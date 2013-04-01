//
//  NSObject+DiaryRequest.m
//  newKeyDiary
//
//  Created by Black Black on 3/24/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "DiaryRequest.h"
#import "AFNetworking/AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "SBAPIManager.h"

@implementation DiaryRequest

@synthesize sectionIndex;
@synthesize rowIndex;
@synthesize delegate;

- (void)insertDiary:(NSString *)username password:(NSString *)password dateStr:(NSString *)dateStr keyword:(NSString *)keyword sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
{
    self.rowIndex = row;
    self.sectionIndex = section;

    NSString *totalUrl = [NSString stringWithFormat:@"/diaries/upsert%@", [self getURLString]];
    NSLog(@"userlogin insertDiary %@", totalUrl);
    [[SBAPIManager sharedManager] setUsername:username andPassword:password];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dateStr, keyword, nil] forKeys:[NSArray arrayWithObjects:@"d", @"content", nil]];
    [[SBAPIManager sharedManager] postPath:totalUrl parameters:dict success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"insertDiary: %@", [JSON valueForKeyPath:@"stat"]);
        [self.delegate insertDiaryCallback:JSON code:[operation.response statusCode] sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"insertDiary Request Failure Because %@ %d",[error userInfo], [operation.response statusCode]);
        [self.delegate insertDiaryCallback:nil code:[operation.response statusCode] sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
    }];
}
- (void)deleteDiary:(NSString *)username password:(NSString *)password dateStr:(NSString *)dateStr  sectionIndex:(NSInteger)section rowIndex:(NSInteger)row
{
    self.rowIndex = row;
    self.sectionIndex = section;
    
    
    NSString *totalUrl = [NSString stringWithFormat:@"/diaries/remove%@", [self getURLString]];
    NSLog(@"userlogin deleteDiary %@", totalUrl);
    [[SBAPIManager sharedManager] setUsername:username andPassword:password];
    //todo 改成POST
    //d 日记日期，格式为 YYYY-MM-DD
    //content 日记内容，长度不能超过 14 个字符
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dateStr, nil] forKeys:[NSArray arrayWithObjects:@"d", nil]];
    [[SBAPIManager sharedManager] postPath:totalUrl parameters:dict success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"deleteDiary userlogin callback: %@", [JSON valueForKeyPath:@"stat"]);
        [self.delegate deleteDiaryCallback:JSON code:[operation.response statusCode] sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"deleteDiary Request Failure Because %@ %d",[error userInfo], [operation.response statusCode]);
        [self.delegate deleteDiaryCallback:nil code:[operation.response statusCode] sectionIndex:self.sectionIndex rowIndex:self.rowIndex];
    }];
}

- (void)setRemindTime:(NSString *)username password:(NSString *)password remindTime:(NSString *)remindTime
{
    NSLog(@"setRemindTime %@", remindTime);
    [self.delegate setRemindTimeCallback:nil code:0];
}

- (NSString *)getURLString
{
    return @"?source=3&accessKey=hEllo$worlD";
}


@end
