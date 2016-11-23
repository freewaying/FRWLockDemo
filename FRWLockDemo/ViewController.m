//
//  ViewController.m
//  FRWLockDemo
//
//  Created by freewaying on 2016/11/21.
//  Copyright © 2016年 freewaying. All rights reserved.
//

#import "ViewController.h"
#import "FRWNSConditionDemo.h"
#import "FRWNSConditionLockDemo.h"
#import "FRWPthreadMutexLockDemo.h"
#import "FRWPthreadMutexRWLockDemo.h"
#import "FRWPOSIXConditionsDemo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    FRWNSConditionDemo *lockDemo = [[FRWNSConditionDemo alloc] init];
//    [lockDemo start];
//    FRWNSConditionLockDemo *lockDemo = [[FRWNSConditionLockDemo alloc] init];
//    [lockDemo start];
//    FRWPthreadMutexLockDemo *lockDemo = [[FRWPthreadMutexLockDemo alloc] init];
//    [lockDemo start];
//    FRWPthreadMutexRWLockDemo *lockDemo = [[FRWPthreadMutexRWLockDemo alloc] init];
//    [lockDemo start];
    FRWPOSIXConditionsDemo *lockDemo = [[FRWPOSIXConditionsDemo alloc] init];
    [lockDemo start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
