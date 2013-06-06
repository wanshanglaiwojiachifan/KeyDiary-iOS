//
//  HTTPStatus.m
//  newKeyDiary
//
//  Created by MissDora on 6/5/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "HTTPStatus.h"

@implementation HTTPStatus : NSObject

+ (NSString *) getStringByStat:(NSInteger)stat {
    NSString *res;
    switch (stat) {
        case 2:
        case 7:
            res = NSLocalizedString(@"Server Error", nil);
            break;
        case 3:
            res = NSLocalizedString(@"Account Unauthorized", nil);
            break;
        case 2101:
            res = NSLocalizedString(@"Content too long", nil);
            break;
        case 2102:
            res = NSLocalizedString(@"Content empty", nil);
            break;
        case 2201:
            res = NSLocalizedString(@"Date is out of today", nil);
            break;
        case 2202:
            res = NSLocalizedString(@"Date is illegal", nil);
            break;
        case 2203:
            res = NSLocalizedString(@"Date is empty", nil);
            break;
        case 2301:
            res = NSLocalizedString(@"Diary not found", nil);
            break;
        case 1:
            res = NSLocalizedString(@"Request Success", nil);
            break;
        default:
            res = NSLocalizedString(@"Unknown Error", nil);
            break;
    }
    return res;
}

@end
