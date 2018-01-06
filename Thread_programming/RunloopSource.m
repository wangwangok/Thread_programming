//
//  RunloopSource.m
//  Thread_programming
//
//  Created by 王望 on 2017/7/19.
//  Copyright © 2017年 Will. All rights reserved.
//

#import "RunloopSource.h"
#import "ViewController.h"

typedef struct rls_temp_ctx{
    void *target;
    const char *schedule;
    const char *cancel;
} rls_temp_context;

@implementation RunloopSource{
    CFRunLoopSourceRef runloop_src;
    NSMutableArray *command_data;
    @private
    id _target;
    
}
rls_temp_context tmp_ctx;

- (instancetype)initWith:(SEL)schedule andCancel:(SEL)cancel{
    self = [super init];
    if (self) {
        tmp_ctx.target = (__bridge void *)(self),tmp_ctx.schedule = [NSStringFromSelector(schedule) UTF8String],tmp_ctx.cancel = [NSStringFromSelector(cancel) UTF8String];
        CFRunLoopSourceContext ctx = {
            .info = &tmp_ctx,
            .retain = NULL,
            .release = NULL,
            .copyDescription = NULL,
            .equal = _equal,
            .schedule = runloopsrc_schedule,
            .perform = runloopsrc_perform,
            .cancel = runloopsrc_cancel
        };
        runloop_src = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &ctx);
        command_data = [NSMutableArray array];
    }
    return self;
}

- (void)addToRunloopWith:(id)target{
    CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
    if (runloop_src == NULL) {
        return;
    }
    _target = target;
    CFRunLoopAddSource(runloopRef, runloop_src, kCFRunLoopDefaultMode);
}

- (void)addCommad:(NSInteger)commad withData:(id)data{
    [command_data addObject:data];
}

- (void)fireAllCommandsOnRunloop:(CFRunLoopRef)runloop{
    CFRunLoopSourceSignal(runloop_src);
    CFRunLoopWakeUp(runloop);
}

- (void)sourceFire{
    if (self.sourceFire_handle) {
        @synchronized (command_data) {
            self.sourceFire_handle(command_data);
        }
        
//        NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:NO_DATA];
        /// 这里需要注意一下的是：如果在处理事件完成之后没有调用该方法，会在cancle方法中访问到已经释放掉的内存。官方文档也提到了，根据我自己的理解，将该函数放在这里
        CFRunLoopSourceInvalidate(runloop_src);
    }
}

void    runloopsrc_schedule(void *info, CFRunLoopRef rl, CFRunLoopMode mode){
    rls_temp_context *tmp_ctx = info;
    if (tmp_ctx == NULL) {
        return;
    }
    RunloopSource *src = (__bridge RunloopSource *)tmp_ctx->target;/// RunloopSource类的self
    ViewController *target = (ViewController *)(src->_target);/// 真正的外部控制器
    SEL selector = NSSelectorFromString([NSString stringWithUTF8String:tmp_ctx->schedule]);
    if ([target respondsToSelector:selector]) {
        [target performSelectorOnMainThread:selector withObject:[[RunloopContext alloc] initWith:src aRunloop:rl] waitUntilDone:NO];
    }
}

void    runloopsrc_perform(void *info){
    rls_temp_context *tmp_ctx = info;
    if (tmp_ctx == NULL) {
        return;
    }
    RunloopSource *src = (__bridge RunloopSource *)tmp_ctx->target;/// RunloopSource类的self
    [src sourceFire];/// 接口用c，但是处理数据，看习惯，习惯用OC
}

void runloopsrc_cancel(void *info, CFRunLoopRef rl, CFRunLoopMode mode){
    printf("%p", info);
    rls_temp_context *tmp_ctx = info;
    if (tmp_ctx == NULL) {
        return;
    }
    RunloopSource *src = (__bridge RunloopSource *)tmp_ctx->target;/// RunloopSource类的self
    ViewController *target = (ViewController *)(src->_target);/// 真正的外部控制器
    SEL selector = NSSelectorFromString([NSString stringWithUTF8String:tmp_ctx->cancel]);
    if ([target respondsToSelector:selector]) {
        [target performSelectorOnMainThread:selector withObject:[[RunloopContext alloc] initWith:src aRunloop:rl] waitUntilDone:NO];
    }
}

Boolean    _equal(const void *info1, const void *info2){
    return info1 == info2;
}

@end

@implementation RunloopContext{
    RunloopSource *runloop_source;
    CFRunLoopRef runloop;
}
@synthesize runloop,runloop_source;

- (instancetype)initWith:(RunloopSource *)src aRunloop:(CFRunLoopRef)rlp{
    self = [super init];
    if (self) {
        runloop_source = src;
        runloop = rlp;
    }
    return self;
}

@end
