//
//  RunloopSource.m
//  Thread_programming
//
//  Created by 王望 on 2017/7/19.
//  Copyright © 2017年 Will. All rights reserved.
//

#import "RunloopSource.h"
#import "ViewController.h"

@implementation RunloopSource{
    CFRunLoopSourceRef runloop_src;
    NSMutableArray *command_data;
    @private
    id _target;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        CFRunLoopSourceContext ctx = {
            .info = (__bridge void *)(self),
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
        self.sourceFire_handle(command_data);
        /// 这里需要注意一下的是：如果在处理事件完成之后没有调用该方法，会在cancle方法中访问到已经释放掉的内存。官方文档也提到了，根据我自己的理解，将该函数放在这里
        CFRunLoopSourceInvalidate(runloop_src);
    }
}

void	runloopsrc_schedule(void *info, CFRunLoopRef rl, CFRunLoopMode mode){
    RunloopSource *src = (__bridge RunloopSource *)info;
    RunloopContext *ctx = [[RunloopContext alloc] initWith:src aRunloop:rl];
    ViewController *controller = (ViewController *)(src->_target);
    [controller performSelectorOnMainThread:@selector(registerSuccess:) withObject:ctx waitUntilDone:NO];
}

void	runloopsrc_perform(void *info){
    RunloopSource *src = (__bridge RunloopSource *)info;
//    sleep(2);
    [src sourceFire];/// 接口用c，但是处理数据，看习惯，习惯用OC
}

void	runloopsrc_cancel(void *info, CFRunLoopRef rl, CFRunLoopMode mode){
    printf("%p", info);
    RunloopSource *src = (__bridge RunloopSource *)info;
    RunloopContext *ctx = [[RunloopContext alloc] initWith:src aRunloop:rl];
    ViewController *controller = (ViewController *)(src->_target);
    [controller performSelectorOnMainThread:@selector(removeSuccess:) withObject:ctx waitUntilDone:NO];
}

Boolean	_equal(const void *info1, const void *info2){
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
