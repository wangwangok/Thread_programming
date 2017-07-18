//
//  ThreadHelper.h
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POSIX_Thread.h"

@interface TPThread : NSThread

@end

@interface ThreadHelper : NSObject
//- (ThreadHelper*(^)(NSString *))chain;

+ (void)CocoaThread:(BOOL)detached withTarget:(id)target selector:(SEL)aSelector object:(id)aObject block:(void(^)(void))aBlock;

+ (pthread_t)PosixThread:(void(^)(void))main_entry;
+ (pthread_t)PosixThread:(id)target selector:(SEL)aSelector object:(id)aObject;

@property (copy, nonatomic) void(^main_entry_point)(void);

- (id)posix_getThreadInfor:(NSString *)key;

- (void)posix_setTheadInfor:(NSString *)key andValue:(id)value;

- (BOOL)posix_threadInfo_removeKey:(NSString *)key;

@end

@interface CocoaThread : NSObject

/**
 * 是否通过detached的那个类方法创建
 */
+ (TPThread *)newThreadForDetached:(BOOL)detached withTarget:(id)target selector:(SEL)aSelector object:(id)aObject block:(void(^)(void))aBlock;

@end
