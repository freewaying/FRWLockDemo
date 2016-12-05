# FRWLockDemo
iOS Locks Demo

# 线程安全

当一个线程访问数据的时候，其他的线程不能对其进行访问，直到该线程访问完毕。即，同一时刻，对同一个数据操作的线程只有一个。只有确保了这样，才能使数据不会被其他线程污染。而线程不安全，则是在同一时刻可以有多个线程对该数据进行访问，从而得不到预期的结果。

比如写文件和读文件，当一个线程在写文件的时候，理论上来说，如果这个时候另一个线程来直接读取的话，那么得到将是不可预期的结果。

为了线程安全，我们可以使用锁的机制来确保，同一时刻只有同一个线程来对同一个数据源进行访问。在开发过程中我们通常使用以下几种锁。

    NSLock
    NSRecursiveLock
    NSCondition
    NSConditionLock
    pthread_mutex
    pthread_rwlock
    POSIX Conditions
    OSSpinLock
    os_unfair_lock
    dispatch_semaphore
    @synchronized

## 信号量

在多线程环境下用来确保代码不会被并发调用。在进入一段代码前，必须获得一个信号量，在结束代码前，必须释放该信号量，其他想要想要执行该代码的线程必须等待直到前者释放了该信号量。

以一个停车场的运作为例。简单起见，假设停车场只有三个车位，一开始三个车位都是空的。这时如果同时来了五辆车，看门人允许其中三辆直接进入，然后放下车拦，剩下的车则必须在入口等待，此后来的车也都不得不在入口处等待。这时，有一辆车离开停车场，看门人得知后，打开车拦，放入外面的一辆进去，如果又离开两辆，则又可以放入两辆，如此往复。
在这个停车场系统中，车位是公共资源，每辆车好比一个线程，看门人起的就是信号量的作用。

## 互斥锁

一种用来防止多个线程同一时刻对共享资源进行访问的信号量，它的原子性确保了如果一个线程锁定了一个互斥量，将没有其他线程在同一时间可以锁定这个互斥量。它的唯一性确保了只有它解锁了这个互斥量，其他线程才可以对其进行锁定。当一个线程锁定一个资源的时候，其他对该资源进行访问的线程将会被挂起，直到该线程解锁了互斥量，其他线程才会被唤醒，进一步才能锁定该资源进行操作。

### NSLock

NSLock实现了最基本的互斥锁，遵循了 NSLocking 协议，通过 lock 和 unlock 来进行锁定和解锁。其使用也非常简单

- (void)doSomething {
   [self.lock lock];
   //TODO: do your stuff
   [self.lock unlock];
}

由于是互斥锁，当一个线程进行访问的时候，该线程获得锁，其他线程进行访问的时候，将被操作系统挂起，直到该线程释放锁，其他线程才能对其进行访问，从而却确保了线程安全。但是如果连续锁定两次，则会造成死锁问题。那如果想在递归中使用锁，那要怎么办呢，这就用到了 NSRecursiveLock 递归锁。

### NSRecursiveLock

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

### NSCondition

NSCondition 是一种特殊类型的锁，通过它可以实现不同线程的调度。一个线程被某一个条件所阻塞，直到另一个线程满足该条件从而发送信号给该线程使得该线程可以正确的执行。比如说，你可以开启一个线程下载图片，一个线程处理图片。这样的话，需要处理图片的线程由于没有图片会阻塞，当下载线程下载完成之后，则满足了需要处理图片的线程的需求，这样可以给定一个信号，让处理图片的线程恢复运行。

- (void)download {
    [self.condition lock];
    //TODO: 下载文件代码
    if (donloadFinish) { // 下载结束后，给另一个线程发送信号，唤起另一个处理程序
        [self.condition signal];
        [self.condition unlock];
    }
}

- (void)doStuffWithDownloadPicture {
    [self.condition lock];

    while (!donloadFinish) {
        [self.condition wait];
    }
    //TODO: 处理图片代码

    [self.condition unlock];
}

### NSConditionLock

NSConditionLock 对象所定义的互斥锁可以在使得在某个条件下进行锁定和解锁。它和 NSCondition 很像，但实现方式是不同的。

当两个线程需要特定顺序执行的时候，例如生产者消费者模型，则可以使用 NSConditionLock 。当生产者执行执行的时候，消费者可以通过特定的条件获得锁，当生产者完成执行的时候，它将解锁该锁，然后把锁的条件设置成唤醒消费者线程的条件。锁定和解锁的调用可以随意组合，lock 和 unlockWithCondition: 配合使用 lockWhenCondition: 和 unlock 配合使用。

- (void)producer {
    while (YES) {
        [self.conditionLock lock];
        NSLog(@"have something");
        self.count++;
        [self.conditionLock unlockWithCondition:1];
    }
}

- (void)consumer {
    while (YES) {
        [self.conditionLock lockWhenCondition:1];
        NSLog(@"use something");
        self.count--;
        [self.conditionLock unlockWithCondition:0];
    }
}

当生产者释放锁的时候，把条件设置成了1。这样消费者可以获得该锁，进而执行程序，如果消费者获得锁的条件和生产者释放锁时给定的条件不一致，则消费者永远无法获得锁，也不能执行程序。同样，如果消费者释放锁给定的条件和生产者获得锁给定的条件不一致的话，则生产者也无法获得锁，程序也不能执行。

### pthread_mutex

POSIX 互斥锁是一种超级易用的互斥锁，使用的时候，只需要初始化一个 pthread_mutex_t 用 pthread_mutex_lock 来锁定 pthread_mutex_unlock 来解锁，当使用完成后，记得调用 pthread_mutex_destroy 来销毁锁。

    pthread_mutex_init(&lock,NULL);
    pthread_mutex_lock(&lock);
    //do your stuff
    pthread_mutex_unlock(&lock);
    pthread_mutex_destroy(&lock);

### pthread_rwlock

读写锁，在对文件进行操作的时候，写操作是排他的，一旦有多个线程对同一个文件进行写操作，后果不可估量，但读是可以的，多个线程读取时没有问题的。

    当读写锁被一个线程以读模式占用的时候，写操作的其他线程会被阻塞，读操作的其他线程还可以继续进行。
    当读写锁被一个线程以写模式占用的时候，写操作的其他线程会被阻塞，读操作的其他线程也被阻塞。

// 初始化
pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER
// 读模式
pthread_rwlock_wrlock(&lock);
// 写模式
pthread_rwlock_rdlock(&lock);
// 读模式或者写模式的解锁
pthread_rwlock_unlock(&lock);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [self readBookWithTag:1];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [self readBookWithTag:2];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [self writeBook:3];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [self writeBook:4];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [self readBookWithTag:5];
    });


- (void)readBookWithTag:(NSInteger )tag {
    pthread_rwlock_rdlock(&rwLock);
    NSLog(@"start read ---- %ld",tag);
    self.path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@".doc"];
    self.contentString = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"end   read ---- %ld",tag);
    pthread_rwlock_unlock(&rwLock);
}

- (void)writeBook:(NSInteger)tag {
    pthread_rwlock_wrlock(&rwLock);
    NSLog(@"start wirte ---- %ld",tag);
    [self.contentString writeToFile:self.path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"end   wirte ---- %ld",tag);
    pthread_rwlock_unlock(&rwLock);
}
start   read ---- 1
start   read ---- 2
end    read ---- 1
end    read ---- 2
start   wirte ---- 3
end    wirte ---- 3
start   wirte ---- 4
end    wirte ---- 4
start   read ---- 5
end    read ---- 5

### POSIX Conditions

POSIX 条件锁需要互斥锁和条件两项来实现，虽然看起来没什么关系，但在运行时中，互斥锁将会与条件结合起来。线程将被一个互斥和条件结合的信号来唤醒。

首先初始化条件和互斥锁，当 ready_to_go 为 flase 的时候，进入循环，然后线程将会被挂起，直到另一个线程将 ready_to_go 设置为 true 的时候，并且发送信号的时候，该线程会才被唤醒。

pthread_mutex_t mutex;
pthread_cond_t condition;
Boolean     ready_to_go = true;

void MyCondInitFunction()
{
    pthread_mutex_init(&mutex);
    pthread_cond_init(&condition, NULL);
}

void MyWaitOnConditionFunction()
{
    // Lock the mutex.
    pthread_mutex_lock(&mutex);

    // If the predicate is already set, then the while loop is bypassed;
    // otherwise, the thread sleeps until the predicate is set.
    while(ready_to_go == false)
    {
        pthread_cond_wait(&condition, &mutex);
    }

    // Do work. (The mutex should stay locked.)

    // Reset the predicate and release the mutex.
    ready_to_go = false;
    pthread_mutex_unlock(&mutex);
}

void SignalThreadUsingCondition()
{
    // At this point, there should be work for the other thread to do.
    pthread_mutex_lock(&mutex);
    ready_to_go = true;

    // Signal the other thread to begin work.
    pthread_cond_signal(&condition);

    pthread_mutex_unlock(&mutex);
}

### OSSpinLock

自旋锁，和互斥锁类似，都是为了保证线程安全的锁。但二者的区别是不一样的，对于互斥锁，当一个线程获得这个锁之后，其他想要获得此锁的线程将会被阻塞，直到该锁被释放。但自选锁不一样，当一个线程获得锁之后，其他线程将会一直循环在哪里查看是否该锁被释放。所以，此锁比较适用于锁的持有者保存时间较短的情况下。

// 初始化
spinLock = OS_SPINLOCK_INIT;
// 加锁
OSSpinLockLock(&spinLock);
// 解锁
OSSpinLockUnlock(&spinLock);

然而，YYKit 作者 @ibireme 的文章也有说这个自旋锁存在优先级反转问题，具体文章可以戳 不再安全的 OSSpinLock。
os_unfair_lock

自旋锁已经不在安全，然后苹果又整出来个 os_unfair_lock_t (╯‵□′)╯︵┻━┻
这个锁解决了优先级反转问题。

    os_unfair_lock_t unfairLock;
    unfairLock = &(OS_UNFAIR_LOCK_INIT);
    os_unfair_lock_lock(unfairLock);
    os_unfair_lock_unlock(unfairLock);

### dispatch_semaphore

信号量机制实现锁，等待信号，和发送信号，正如前边所说的看门人一样，当有多个线程进行访问的时候，只要有一个获得了信号，其他线程的就必须等待该信号释放。

- (void)semphone:(NSInteger)tag {

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW);
    // do your stuff
    dispatch_semaphore_signal(semaphore);
}

### @synchronized

一个便捷的创建互斥锁的方式，它做了其他互斥锁所做的所有的事情。

- (void)myMethod:(id)anObj
{
    @synchronized(anObj)
    {
        // Everything between the braces is protected by the @synchronized directive.
    }
}

如果你在不同的线程中传过去的是一样的标识符，先获得锁的会锁定代码块，另一个线程将被阻塞，如果传递的是不同的标识符，则不会造成线程阻塞。
总结

应当针对不同的操作使用不同的锁，而不能一概而论那种锁的加锁解锁速度快。

    当进行文件读写的时候，使用 pthread_rwlock 较好，文件读写通常会消耗大量资源，而使用互斥锁同时读文件的时候会阻塞其他读文件线程，而 pthread_rwlock 不会。
    当性能要求较高时候，可以使用 pthread_mutex 或者 dispath_semaphore，由于 OSSpinLock 不能很好的保证线程安全，而在只有在 iOS10 中才有 os_unfair_lock ，所以，前两个是比较好的选择。既可以保证速度，又可以保证线程安全。
    对于 NSLock 及其子类，速度来说 NSLock < NSCondition < NSRecursiveLock < NSConditionLock 。

文／XcodeMen（简书作者）
原文链接：http://www.jianshu.com/p/6c8bf19eb10d
著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
