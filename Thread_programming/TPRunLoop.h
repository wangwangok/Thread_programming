//
//  TPRunLoop.h
//  Thread_programming
//
//  Created by 王望 on 2017/7/18.
//  Copyright © 2017年 Will. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunloopSource : NSObject{
    @public
    CFRunLoopSourceRef runloopRef;
    NSMutableArray *commands;
}

- (instancetype)init;
- (void)addToRunloop;

/**
 * 处理perform_sourceRoutine函数中的事务，也就是当输入源发出信号之后，我们需要在这个函数中进行处理
 */
- (void)sourceFired;
/**
 *
 */
Boolean	src_equal(const void *info1, const void *info2);
/**
 * 三个回调函数，需要明确的操作是，交互，处理请求，取消
 */
void schedule_sourceRoutine(void *info, CFRunLoopRef rl, CFRunLoopMode mode);
void perform_sourceRoutine(void *info);
void cancel_sourceRoutine(void *info, CFRunLoopRef rl, CFRunLoopMode mode);

@end

/**
 *
 *
 * 重点不在这个类，主要在上面那个类
 *
 *
 */
/// 对于大部分的context来说，大多是在C函数中充当一个传值得作用，void *中传递多个数据的结构。由于是用OC对C函数的一次封装，所以使用的是类而不是结构体
@interface RunloopContext : NSObject{
    @public
    RunloopSource *source;
    CFRunLoopRef runloop;
}

@property (readonly)RunloopSource *source;
@property (readonly)CFRunLoopRef runloop;

- (instancetype)initWith:(RunloopSource *)src aRunloop:(CFRunLoopRef)rlp;

@end
