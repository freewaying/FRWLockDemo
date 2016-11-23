//
//  FRWPOSIXConditionsDemo.m
//  FRWLockDemo
//
//  Created by freewaying on 2016/11/22.
//  Copyright © 2016年 freewaying. All rights reserved.
//

#import "FRWPOSIXConditionsDemo.h"
#import <pthread/pthread.h>

@interface FRWPOSIXConditionsDemo () {
    pthread_mutex_t mutex;
    pthread_cond_t condition;
    
    BOOL readyToGo;
}

@end

@implementation FRWPOSIXConditionsDemo

- (void)start {
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&condition, NULL);
    readyToGo = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self produce];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self consume];
    });
}

- (void)produce {
    while (YES) {
        pthread_mutex_lock(&mutex);
        while (!readyToGo) {
            pthread_cond_wait(&condition, &mutex);
        }
        
        NSLog(@"produce");
        
        readyToGo = NO;
        pthread_mutex_unlock(&mutex);
    }
}

- (void)consume {
    while (YES) {
        pthread_mutex_lock(&mutex);
        readyToGo = YES;
        NSLog(@"consume");
        pthread_cond_signal(&condition);
        pthread_mutex_unlock(&mutex);
    }
}

@end
