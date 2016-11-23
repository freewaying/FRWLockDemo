//
//  FRWPthreadMutexLockDemo.m
//  FRWLockDemo
//
//  Created by freewaying on 2016/11/22.
//  Copyright © 2016年 freewaying. All rights reserved.
//

#import "FRWPthreadMutexLockDemo.h"
#import <pthread/pthread.h>

@interface FRWPthreadMutexLockDemo ()

@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic, assign) NSInteger count;

@end

@implementation FRWPthreadMutexLockDemo

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

- (void)start {
    pthread_mutex_init(&_lock, NULL);
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(produce) object:nil];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(consume) object:nil];
    [thread1 start];
    [thread2 start];
}

- (void)produce {
    while (YES) {
        pthread_mutex_lock(&_lock);
        NSLog(@"produce");
        self.count++;
        pthread_mutex_unlock(&_lock);
    }
}

- (void)consume {
    while (YES) {
        pthread_mutex_lock(&_lock);
        NSLog(@"consume");
        self.count--;
        pthread_mutex_unlock(&_lock);
    }
}

/**
 POSIX 互斥锁是一种超级易用的互斥锁，使用的时候，只需要初始化一个 pthread_mutex_t, 用 pthread_mutex_lock 来锁定, pthread_mutex_unlock 来解锁，当使用完成后，记得调用 pthread_mutex_destroy 来销毁锁。
 */

 @end
