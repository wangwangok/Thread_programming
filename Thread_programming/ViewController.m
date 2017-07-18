//
//  ViewController.m
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#import "ViewController.h"
#import "ThreadHelper.h"
#import "ViewOperator.h"
@interface ViewController ()

@property (strong, nonatomic) IBOutlet ViewOperator *_viewoperator;

@end

@implementation ViewController

- (IBAction)request:(UIButton *)sender {
    [self._viewoperator StartLoading];
#pragma mark - cocoa thread -
    /// cocoa thread
    //[ThreadHelper CocoaThread:NO withTarget:self selector:@selector(cocoathread_mainentrypoint:) object:@(926400) block:nil];
#pragma mark - posix thread -
    /// posix thread for block
    //[ThreadHelper PosixThread:^{
    //    [self cocoathread_mainentrypoint:@(926400)];
    //}];
    /// posix thread for selector
    [ThreadHelper PosixThread:self selector:@selector(posix_main_entry:) object:@(926400)];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self._viewoperator.loadingView setHidden:YES];
    
}
#pragma mark - Cocoa Thread Entry -
- (void)cocoathread_mainentrypoint:(NSNumber *)number{
    NSLog(@"1.Current Thread:%@",[NSThread currentThread]);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterLongStyle;
    NSString *object = [NSString stringWithFormat:@"Today is %@",[formatter stringFromDate:[NSDate date]]];
    sleep(3);
    [self performSelector:@selector(mainThread_callback:) onThread:[NSThread mainThread] withObject:object waitUntilDone:YES];
}


- (void)mainThread_callback:(id)object{
    NSLog(@"2.Current Thread:%@",[NSThread currentThread]);
    [self._viewoperator updateResult:object];
}

#pragma mark - Posix Entry -
- (void)posix_main_entry:(id)object{
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    CFRunLoopRef loopRef = [loop getCFRunLoop];
    ///CFRunLoopActivity
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
    int loop_count = 10;
    do {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES);
        /**
        if (result == kCFRunLoopRunStopped || result == kCFRunLoopRunFinished || result == kCFRunLoopRunTimedOut) {
        }
         */
        loop_count--;
        
    } while (loop_count);
}

#pragma mark - Runloop -
void _runLoop_observer_handle(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    NSLog(@"CFRunLoopActivity: %zd",activity);
}
const void *runloop_retain(const void *info){
    return info;
}

void runloop_release(const void *info){
    
}

void _runLoop_timer_handle(CFRunLoopTimerRef timer, void *info){
    ViewController *_self = (__bridge ViewController *)info;
    [_self cocoathread_mainentrypoint:@926400];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
