//
//  FRWNSConditionDemo.h
//  FRWLockDemo
//
//  Created by freewaying on 2016/11/21.
//  Copyright © 2016年 freewaying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRWNSConditionDemo : NSObject

- (void)start;

@end

/**
 # NSLock
 
 NSLock实现了最基本的互斥锁，遵循了 NSLocking 协议，通过 lock 和 unlock 来进行锁定和解锁。其使用也非常简单
 
 - (void)doSomething {
 [self.lock lock];
 //TODO: do your stuff
 [self.lock unlock];
 }
 
 由于是互斥锁，当一个线程进行访问的时候，该线程获得锁，其他线程进行访问的时候，将被操作系统挂起，直到该线程释放锁，其他线程才能对其进行访问，从而却确保了线程安全。但是如果连续锁定两次，则会造成死锁问题。那如果想在递归中使用锁，那要怎么办呢，这就用到了 NSRecursiveLock 递归锁。
 
 # NSRecursiveLock
 
 递归锁，顾名思义，可以被一个线程多次获得，而不会引起死锁。它记录了成功获得锁的次数，每一次成功的获得锁，必须有一个配套的释放锁和其对应，这样才不会引起死锁。只有当所有的锁被释放之后，其他线程才可以获得锁
 
 NSRecursiveLock *theLock = [[NSRecursiveLock alloc] init];
 
 void MyRecursiveFunction(int value)
 {
 [theLock lock];
 if (value != 0)
 {
 --value;
 MyRecursiveFunction(value);
 }
 [theLock unlock];
 }
 
 MyRecursiveFunction(5);
 
 
 # OSSpinLock
 
 自旋锁，和互斥锁类似，都是为了保证线程安全的锁。但二者的区别是不一样的，对于互斥锁，当一个线程获得这个锁之后，其他想要获得此锁的线程将会被阻塞，直到该锁被释放。但自选锁不一样，当一个线程获得锁之后，其他线程将会一直循环在哪里查看是否该锁被释放。所以，此锁比较适用于锁的持有者保存时间较短的情况下。
 
 // 初始化
 spinLock = OS_SPINLOCK_INIT;
 // 加锁
 OSSpinLockLock(&spinLock);
 // 解锁
 OSSpinLockUnlock(&spinLock);
 
 然而，YYKit 作者 @ibireme 的文章也有说这个自旋锁存在优先级反转问题，具体文章可以戳 不再安全的 OSSpinLock。
 
 # os_unfair_lock
 
 自旋锁已经不在安全，然后苹果又整出来个 os_unfair_lock_t (╯‵□′)╯︵┻━┻
 这个锁解决了优先级反转问题。
 
 os_unfair_lock_t unfairLock;
 unfairLock = &(OS_UNFAIR_LOCK_INIT);
 os_unfair_lock_lock(unfairLock);
 os_unfair_lock_unlock(unfairLock);
 
 # dispatch_semaphore
 
 信号量机制实现锁，等待信号，和发送信号，正如前边所说的看门人一样，当有多个线程进行访问的时候，只要有一个获得了信号，其他线程的就必须等待该信号释放。
 
 - (void)semphone:(NSInteger)tag {
 
 dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW);
 // do your stuff
 dispatch_semaphore_signal(semaphore);
 }
 
 # @synchronized
 
 一个便捷的创建互斥锁的方式，它做了其他互斥锁所做的所有的事情。
 
 - (void)myMethod:(id)anObj
 {
 @synchronized(anObj)
 {
 // Everything between the braces is protected by the @synchronized directive.
 }
 }
 
 如果你在不同的线程中传过去的是一样的标识符，先获得锁的会锁定代码块，另一个线程将被阻塞，如果传递的是不同的标识符，则不会造成线程阻塞。
 
 # 总结
 
 应当针对不同的操作使用不同的锁，而不能一概而论那种锁的加锁解锁速度快。
 
 当进行文件读写的时候，使用 pthread_rwlock 较好，文件读写通常会消耗大量资源，而使用互斥锁同时读文件的时候会阻塞其他读文件线程，而 pthread_rwlock 不会。
 当性能要求较高时候，可以使用 pthread_mutex 或者 dispath_semaphore，由于 OSSpinLock 不能很好的保证线程安全，而在只有在 iOS10 中才有 os_unfair_lock ，所以，前两个是比较好的选择。既可以保证速度，又可以保证线程安全。
 对于 NSLock 及其子类，速度来说 NSLock < NSCondition < NSRecursiveLock < NSConditionLock 。
 
 文／XcodeMen（简书作者）
 原文链接：http://www.jianshu.com/p/6c8bf19eb10d
 著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
 */
