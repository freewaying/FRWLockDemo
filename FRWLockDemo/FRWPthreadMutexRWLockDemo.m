//
//  FRWPthreadMutexRWLockDemo.m
//  FRWLockDemo
//
//  Created by freewaying on 2016/11/22.
//  Copyright © 2016年 freewaying. All rights reserved.
//

#import "FRWPthreadMutexRWLockDemo.h"
#import <pthread/pthread.h>

@interface FRWPthreadMutexRWLockDemo ()

@property (nonatomic, assign) pthread_rwlock_t rwlock;

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileContent;

@end

@implementation FRWPthreadMutexRWLockDemo

- (void)start {
    pthread_rwlock_init(&_rwlock, NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readBookWithTag:1];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readBookWithTag:2];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self writeBookWithTag:3];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self writeBookWithTag:4];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self readBookWithTag:5];
    });
}

- (void)readBookWithTag:(NSInteger)tag {
    pthread_rwlock_rdlock(&_rwlock);
    NSLog(@"start read -- %ld", tag);
    self.filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"doc"];
    self.fileContent = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"end read -- %ld", tag);
    pthread_rwlock_unlock(&_rwlock);
}

- (void)writeBookWithTag:(NSInteger)tag {
    pthread_rwlock_wrlock(&_rwlock);
    NSLog(@"start write -- %ld", tag);
    [self.fileContent writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"end write -- %ld", tag);
    pthread_rwlock_unlock(&_rwlock);
}

/** output
 start read -- 1
 start read -- 2
 end read -- 2
 end read -- 1
 start write -- 3
 end write -- 3
 start write -- 4
 end write -- 4
 start read -- 5
 end read -- 5
 */

/** 
 pthread_rwlock
 
 读写锁，在对文件进行操作的时候，写操作是排他的，一旦有多个线程对同一个文件进行写操作，后果不可估量，但读是可以的，多个线程读取时没有问题的。
 
 当读写锁被一个线程以读模式占用的时候，写操作的其他线程会被阻塞，读操作的其他线程还可以继续进行。
 当读写锁被一个线程以写模式占用的时候，写操作的其他线程会被阻塞，读操作的其他线程也被阻塞。
 */
 
 @end
