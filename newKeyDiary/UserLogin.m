//
//  UserLogin.m
//  newKeyDiary
//
//  Created by Black Black on 3/20/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import "UserLogin.h"
#import "AFNetworking/AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "SBAPIManager.h"
#import "SingleDay.h"
#import "KeychainItemWrapper.h"

@implementation UserLogin

@synthesize delegate;
@synthesize keychain = _keychain;

- (void)checkUserExist:(NSString *)username password:(NSString *)password
{
    //username = @"black.caffeine@gmail.com";
    //password = @"222222";
    NSString *totalUrl = [NSString stringWithFormat:@"/accounts/verify%@", [self getURLString]];
    NSLog(@"checkUserExist %@ %@", username, password);
    [[SBAPIManager sharedManager] setUsername:username andPassword:password];
    
    [[SBAPIManager sharedManager] getPath:totalUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"after check %@", [JSON class]);
        [self.delegate checkUserCallback:JSON code:[operation.response statusCode]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request Failure Because %@ %d",[error userInfo], [operation.response statusCode]);
        [self.delegate checkUserCallback:nil code:[operation.response statusCode]];
    }];

}

- (void)getDiary:(NSString *)username password:(NSString *)password
{
    NSString *totalUrl = [NSString stringWithFormat:@"/diaries%@", [self getURLString]];
    NSLog(@"checkUserExist %@", totalUrl);
    [[SBAPIManager sharedManager] setUsername:username andPassword:password];
    
    [[SBAPIManager sharedManager] getPath:totalUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"IP Address: %@", [JSON class]);
        [self.delegate getUserDiaryCallback:JSON code:[operation.response statusCode]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request Failure Because %@ %d",[error userInfo], [operation.response statusCode]);
        [self.delegate getUserDiaryCallback:nil code:[operation.response statusCode]];
    }];
}

- (NSString *)getURLString
{
    return @"?source=3&accessKey=hEllo$worlD";
}

/* 用户密码存储 */
- (void)setUserInfo:(NSString *)username password:(NSString *)password
{
    NSLog(@"set user info");
    /*NSArray *allUsers = [self getAllUserInfo];
    //NSLog(@"setUserInfo %@", allUsers);
    for (int i = 0; i < [allUsers count] - 1; i++) {
        NSLog(@" delete password %c", [self deletePassword:[[allUsers objectAtIndex:i] valueForKeyPath:@"acct"]]);
    }
    return [SSKeychain setPassword:password forService:@"KeyDiary" account:username];
     */
    [self deletePassword];
    [self.keychain setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [self.keychain setObject:password forKey:(__bridge id)(kSecValueData)];
}

- (id)getUsername
{
    NSLog(@"get user name");
    return [self.keychain objectForKey:(__bridge id)(kSecAttrAccount)];
}
- (id)getPassword
{
    NSLog(@"get pass word");
    return [_keychain objectForKey:(__bridge id)(kSecValueData)];
}
- (void)deletePassword
{
    //NSLog(@"deletePassword %@", username);
    [self.keychain resetKeychainItem];
}

- (KeychainItemWrapper *)keychain
{
    if (_keychain != nil) {
        return _keychain;
    }
    
    _keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"KeyDiary" accessGroup:nil];
    return _keychain;
}

@end
