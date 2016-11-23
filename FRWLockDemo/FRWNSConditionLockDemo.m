//
//  FRWNSConditionLockDemo.m
//  FRWLockDemo
//
//  Created by freewaying on 2016/11/22.
//  Copyright © 2016年 freewaying. All rights reserved.
//

#import "FRWNSConditionLockDemo.h"

@interface FRWNSConditionLockDemo ()

@property (nonatomic, strong) NSConditionLock *conditionLock;
@property (nonatomic, assign) NSInteger count;

@end

@implementation FRWNSConditionLockDemo

- (void)start {
    self.conditionLock = [[NSConditionLock alloc] init];
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(produce) object:nil];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(consume) object:nil];
    [thread1 start];
    [thread2 start];
}

- (void)produce {
    while (YES) {
        [self.conditionLock lockWhenCondition:0];
        NSLog(@"produce");
        self.count++;
        [self.conditionLock unlockWithCondition:1];
    }
}

- (void)consume {
    while (YES) {
        [self.conditionLock lockWhenCondition:1];
        NSLog(@"consume");
        self.count--;
        [self.conditionLock unlockWithCondition:0];
    }
}

/**
 NSConditionLock 对象所定义的互斥锁可以在使得在某个条件下进行锁定和解锁。它和 NSCondition 很像，但实现方式是不同的。
 
 当两个线程需要特定顺序执行的时候，例如生产者消费者模型，则可以使用 NSConditionLock 。当生产者执行执行的时候，消费者可以通过特定的条件获得锁，当生产者完成执行的时候，它将解锁该锁，然后把锁的条件设置成唤醒消费者线程的条件。锁定和解锁的调用可以随意组合，lock 和 unlockWithCondition: 配合使用 lockWhenCondition: 和 unlock 配合使用。
 */

@end
