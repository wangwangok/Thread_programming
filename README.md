# Thread Programming Case
![](https://img.shields.io/badge/posix%20block-success-brightgreen.svg)  ![](https://img.shields.io/badge/posix%20selector-success-brightgreen.svg)

这是我在复习多线程时，配合我对官方文档翻译的[《多线程编程指南》](https://www.gitbook.com/book/wangwangok/threading-programming-guide-will/details)做的一个小练习，也是一次加深学习。
## 创建方式
- 1、使用``NSThread``的方式，包括了``initWithTarget``和``detachNewThread``两种方式；
这两种方式的相同点在于：它们都是创建的独立线程，并非可连接线程
这两种方式的区别在于：使用``initWithTarget``的方式，我们需要手动调用``start``方法。
同时，基于``NSThread``我们可以子类话它，并重写``main``方法来作为主入口点函数。

- 2、使用``posix``的方式，自己实现了基于___block、selector___两种方式类cocoa``NSThread``的线程方案。
这里主要需要注意的便是：用``posix``的方式可以创建___DETACHED___和___JOINABLE___两种类型的线程，在实现detached类型的线程时，如果在主入口点函数内容较少可能会发生在``create``函数之前，线程就已经退出。这是便需要使用``pthread_cond_t``的相关操作来解决。具体的操作在代码中实现。

## 关于Runloop
无论是在创建``CFRunLoopObserverRef、CFRunLoopTimerRef、CFRunLoopSourceRef``，在传递相关信息的时候，都是在它们对应的context结构中的``info``。由于是``void *``类型，我们同样可以再包一层结构作为该参数，也可以只传入一个self指针。
#### CFRunLoopObserverRef
该部分的代码中``ViewController``的``posix_main_entry``函数中。其主要的相关代码如下：
```
CFRunLoopObserverContext context = {
        .version = 0,
        .info = (__bridge void *)(self),/// 用于在回调函数中需要使用的参数
        .retain = runloop_retain,
        .release = runloop_release,
        .copyDescription = NULL
    };
CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, _runLoop_observer_handle, &context);
if (observer) {
    CFRunLoopAddObserver(loopRef, observer, kCFRunLoopDefaultMode);
}
```

#### CFRunloopTimerSourceRef
```
CFRunLoopTimerContext timerctx = {
        .version = 0,
        .info = (__bridge void *)self,/// 用于在回调函数中需要使用的参数
        .retain = NULL,
        .release = NULL,
        .copyDescription = NULL
};
CFRunLoopTimerRef timer_ref = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + 2.0, 2.0, 0, 0, _runLoop_timer_handle, &timerctx);
if (timer_ref) {
    CFRunLoopAddTimer(loopRef, timer_ref, kCFRunLoopDefaultMode);
}
```
对于Timer的事件处理是放在``timerctx``函数中执行。

#### CFRunLoopSourceRef
关于输入源的操作主要有三个，分别在代码中已经列出，它相对于定时器源要复杂一点。主要的代码中文件``RunloopSource.m``中。
