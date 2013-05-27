//
//  UserLogin.h
//  newKeyDiary
//
//  Created by Black Black on 3/20/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

@class UserLogin;

@protocol UserLoginDelegate <NSObject>

- (void)checkUserCallback:(NSDictionary *)userInfo code:(NSInteger)code;
- (void)getUserDiaryCallback:(NSDictionary *)diaryInfo code:(NSInteger)code;
//- (void)insertDiaryCallback:(NSDictionary *)insertInfo code:(NSInteger)code;
//- (void)deleteDiaryCallback:(NSDictionary *)deleteInfo code:(NSInteger)code;

@end

@interface UserLogin : NSObject

@property (nonatomic, weak) id <UserLoginDelegate> delegate;
@property (nonatomic, strong) KeychainItemWrapper *keychain;
- (void)checkUserExist:(NSString *)username password:(NSString *)password;
- (void)getDiary:(NSString *)username password:(NSString *)password;
//- (void)insertDiary:(NSString *)username password:(NSString *)password dateStr:(NSString *)dateStr keyword:(NSString *)keyword;
//- (void)deleteDiary:(NSString *)username password:(NSString *)password dateStr:(NSString *)dateStr;
- (void)setUserInfo:(NSString *)username password:(NSString *)password;
- (id)getUsername;
- (id)getPassword;
- (void)deletePassword;

@end
