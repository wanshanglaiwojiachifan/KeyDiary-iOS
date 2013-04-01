//
//  SBAPIManager.h
//  newKeyDiary
//
//  Created by Black Black on 3/20/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "AFNetworking/AFHTTPClient.h"

@interface SBAPIManager : AFHTTPClient

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

+ (SBAPIManager *)sharedManager;

@end