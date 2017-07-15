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
    ///[ThreadHelper CocoaThread:NO withTarget:self selector:@selector(cocoathread_mainentrypoint:) object:@(926400) block:nil];
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
    NSLog(@"~~~In cocoathread_mainentrypoint Mehtod Current Thread:%@ and is MainThread :%@~~~",[NSThread currentThread],[NSThread isMainThread] == YES ? @"YES" : @"NO");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterLongStyle;
    NSString *object = [NSString stringWithFormat:@"Today is %@",[formatter stringFromDate:[NSDate date]]];
    sleep(3);
    [self performSelector:@selector(mainThread_callback:) onThread:[NSThread mainThread] withObject:object waitUntilDone:YES];
}


- (void)mainThread_callback:(id)object{
    NSLog(@"~~~In mainThread_callback Mehtod Current Thread is:%@ and is MainThread :%@~~~",[NSThread currentThread],[NSThread isMainThread] == YES ? @"YES" : @"NO");
    [self._viewoperator updateResult:object];
}

#pragma mark - Posix Entry -
- (void)posix_main_entry:(id)object{
    NSLog(@"%@",object);
    [self cocoathread_mainentrypoint:@(926400)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
