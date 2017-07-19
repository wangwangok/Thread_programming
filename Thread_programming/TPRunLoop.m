//
//  TPRunLoop.m
//  Thread_programming
//
//  Created by 王望 on 2017/7/18.
//  Copyright © 2017年 Will. All rights reserved.
//

#import "TPRunLoop.h"

@implementation RunloopSource

- (instancetype)init{
    self = [super init];
    if (self) {
        CFRunLoopSourceContext src_context = {
            .version = 0,
            .info = (__bridge void *)(self),
            .retain = NULL,
            .release = NULL,
            .copyDescription = NULL,
            .equal = src_equal,
            NULL,
            .schedule = schedule_sourceRoutine,
            .perform = perform_sourceRoutine,
            .cancel = cancel_sourceRoutine
        };
        CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &src_context);
        commands = [NSMutableArray array];
    }
    return self;
}
- (void)addToRunloop{
    CFRunLoopRef c_loop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(c_loop, runloopRef, kCFRunLoopDefaultMode);
}

- (void)sourceFired{
    
}

void schedule_sourceRoutine(void *info, CFRunLoopRef rl, CFRunLoopMode mode){
    
}

void perform_sourceRoutine(void *info){/// RunloopSource发出了信号
    RunloopSource *src = (__bridge RunloopSource *)(info);
    [src sourceFired];
}

void cancel_sourceRoutine(void *info, CFRunLoopRef rl, CFRunLoopMode mode){

}

Boolean	src_equal(const void *info1, const void *info2){
    return info1 == info2;
}

@end

@implementation RunloopContext
@synthesize source,runloop;

- (instancetype)initWith:(RunloopSource *)src aRunloop:(CFRunLoopRef)rlp{
    self = [super init];
    if (self) {
        source = src;
        runloop = rlp;
    }
    return self;
}

@end
