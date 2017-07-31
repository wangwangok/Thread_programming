//
//  RunloopSource.h
//  Thread_programming
//
//  Created by 王望 on 2017/7/19.
//  Copyright © 2017年 Will. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ViewController;
@interface RunloopSource : NSObject

@property (copy)void(^sourceFire_handle)(NSMutableArray *);

- (instancetype)initWith:(SEL)schedule andCancel:(SEL)cancel;

- (void)addToRunloopWith:(id)target;

-(void)addCommad:(NSInteger)commad withData:(id)data;
- (void)fireAllCommandsOnRunloop:(CFRunLoopRef)runloop;

Boolean	_equal(const void *info1, const void *info2);

/**
 *
 * 外部线程与输入源的交互，当外部线程注册到RunloopSource之后，由这个接口将外部数据拿回到输入源中。
 *
 */
void	runloopsrc_schedule(void *info, CFRunLoopRef rl, CFRunLoopMode mode);
/**
 *
 * 在schedule中获取到外部传进来的数据之后，在perform中来处理耗时的数据
 *
 */
void	runloopsrc_perform(void *info);

/**
 *
 * 当取消了Runloopsource之后，从这个接口通知外部情况
 *
 */
void	runloopsrc_cancel(void *info, CFRunLoopRef rl, CFRunLoopMode mode);

@end

@interface RunloopContext : NSObject

- (instancetype)initWith:(RunloopSource *)src aRunloop:(CFRunLoopRef)rlp;
@property (readonly)RunloopSource *runloop_source;
@property (readonly)CFRunLoopRef runloop;

@end
