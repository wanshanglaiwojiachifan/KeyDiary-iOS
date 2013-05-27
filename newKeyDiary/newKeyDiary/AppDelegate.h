//
//  AppDelegate.h
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiaryViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) DiaryViewController *centerPanel;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
