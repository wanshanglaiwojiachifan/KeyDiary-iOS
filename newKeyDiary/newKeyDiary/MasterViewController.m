//
//  MasterViewController.m
//  newKeyDiary
//
//  Created by Black Black on 3/16/13.
//  Copyright (c) 2013 BlackXBlack. All rights reserved.
//
#import "MasterViewController.h"
#import "SettingViewController.h"

@interface MasterViewController ()


@end

@implementation MasterViewController
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"initWithNibName");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) awakeFromNib
{
    NSLog(@"awakeFromNib");
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"DiaryViewController"]];
    [self setRightPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"]];
    self.allowRightSwipe = YES;
}




@end
