//
//  FRWNSConditionDemo.m
//  FRWLockDemo
//
//  Created by freewaying on 2016/11/21.
//  Copyright © 2016年 freewaying. All rights reserved.
//

#import "FRWNSConditionDemo.h"

#define kIsMultiBreadAllowed 0

@interface FRWBread : NSObject

@end

@implementation FRWBread

@end

@interface FRWNSConditionDemo ()

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, assign) BOOL hasBread;

@end

@implementation FRWNSConditionDemo

- (void)start {
    self.condition = [[NSCondition alloc] init];
    self.hasBread = NO;
    
    NSThread *produceThread = [[NSThread alloc] initWithTarget:self selector:@selector(produce) object:nil];
    NSThread *consumeThread = [[NSThread alloc] initWithTarget:self selector:@selector(consume) object:nil];
    [produceThread start];
    [consumeThread start];
}

-(void)produce {
    while (YES) {
        [self.condition lock];
        if (!self.hasBread) {
            NSLog(@"produce a bread");
            self.hasBread = YES;
            [self.condition signal];
        } else {
            [self.condition wait];
        }
        [self.condition unlock];
    }
}

- (void)consume {
    while (YES) {
        [self.condition lock];
        if (self.hasBread) {
            NSLog(@"consume a bread");
            self.hasBread = NO;
            [self.condition signal];
        } else {
            [self.condition wait];
        }
        [self.condition unlock];
    }
}

/**
 NSCondition 是一种特殊类型的锁，通过它可以实现不同线程的调度。一个线程被某一个条件所阻塞，直到另一个线程满足该条件从而发送信号给该线程使得该线程可以正确的执行。比如说，你可以开启一个线程下载图片，一个线程处理图片。这样的话，需要处理图片的线程由于没有图片会阻塞，当下载线程下载完成之后，则满足了需要处理图片的线程的需求，这样可以给定一个信号，让处理图片的线程恢复运行。
 */
 
 @end
