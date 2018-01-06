//
//  ThreadHelper.m
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#import "ThreadHelper.h"
#import <objc/runtime.h>
#import <objc/message.h>
typedef void(*tpthread_entry_point)(id, SEL,...);

typedef struct tpthread_impInfo{
    void *target;
    void *object;
    char const *selector;
    tpthread_entry_point the_imp;
}_tpthread_impInfo;

@implementation TPThread

- (void)main{
    [super main];
    NSLog(@"do som work");
}

@end

@implementation ThreadHelper

static ThreadHelper *local_helper;
pthread_cond_t cond_t;

+ (void)CocoaThread:(BOOL)detached withTarget:(id)target selector:(SEL)aSelector object:(id)aObject block:(void(^)(void))aBlock{
    TPThread *cocoa_thread = [CocoaThread newThreadForDetached:detached withTarget:target selector:aSelector object:aObject block:aBlock];
    if (cocoa_thread) {
        
        [cocoa_thread start];
    }
}
/**
 * 1.使用实例变量，在pthread_create的参数里面传递这个实例变量
 * 2.结合runtime，不实例化变量，在pthread_create的参数里传递一个结构指针
 */
#define __posixthread_completion_version 1
+ (pthread_t)PosixThread:(id)target selector:(SEL)aSelector object:(id)aObject{
    tpthread_entry_point sel_imp = (tpthread_entry_point)class_getMethodImplementation([target class], aSelector);
    _tpthread_impInfo _impInfo = {
        .target   = (__bridge void*)target,
        .object   = (__bridge void*)aObject,
        .selector = [NSStringFromSelector(aSelector) UTF8String],
        .the_imp  = sel_imp
    };
    
    id obj = ((id(*)(id,SEL))objc_msgSend)(((id(*)(id,SEL))objc_msgSend)([self class],@selector(alloc)),@selector(init));
    ((id(*)(id,SEL))objc_msgSend)(obj,NSSelectorFromString(@"release"));
    
    int result = pthread_cond_init(&cond_t, NULL);
    if (result != 0) {
        assert(result);
    }
    pthread_t thread_id = tp_pthread_create(the_main_entry_point, &_impInfo, &cond_t);
    return thread_id;
}
- (void)xxxxx{

}

+ (pthread_t)PosixThread:(void(^)(void))main_entry{
    ThreadHelper *helper = [[ThreadHelper alloc] init];
    
    local_helper = helper;
    if (main_entry) {
        helper.main_entry_point = main_entry;
    }
    int result = pthread_cond_init(&cond_t, NULL);
    if (result != 0) {
        assert(result);
    }
    pthread_t thread_id = tp_pthread_create(the_main_entry_point, (__bridge void *)(helper), &cond_t);
    return thread_id;
}

void *the_main_entry_point(void *data){
    /** 如果创建的是detached类型的thread，由于任务太过于简单会导致线程马上退出，在获取data的时候，会触发偶然性的数据错误（这个偶然性取决于线程什么时候销毁），所以解决办法就是使用一个static的全局静态变量。但是如果是创建的joinable的thread就不用担心这个问题 **/
    /**
     但是在使用detached的时候，可以使用pthread_cond_t来解决，具体看代码
     **/
    if (local_helper) {
        if (data == NULL) {
            assert("null");
        }
        pthread_cond_signal(&cond_t);
        ThreadHelper *_self = (__bridge ThreadHelper*)data;
        if (_self) {
            _self.main_entry_point();
        }
    }else{
        _tpthread_impInfo *_impInfo = (_tpthread_impInfo *)data;
        if (_impInfo == NULL) {
            assert("null");
        }
        SEL aSelector = NSSelectorFromString([NSString stringWithUTF8String:_impInfo->selector]);
        id object = (__bridge id)_impInfo->object;
        id target = (__bridge id)(_impInfo->target);
        tpthread_entry_point sel_imp = _impInfo->the_imp;
        if (sel_imp == NULL ||
            target == NULL ||
            object == NULL ||
            _impInfo->selector == NULL) {
            assert("null");
        }
        pthread_cond_signal(&cond_t);
        sel_imp(target, aSelector, object);
    }
    pthread_cond_destroy(&cond_t);
    return data;
}
#pragma mark - Thread Info -
/**
 * specific并不是针对特定的线程，意思是在同一进程中的线程都可以访问该数据
 * 使用pthread_self()来获取当前线程
 **/
- (id)posix_getThreadInfor:(NSString *)key{
    pthread_key_t p_key = [key hash];
    id data = (__bridge id)pthread_getspecific(p_key);
    return data;
}
void pkey_create(void *data){
    ///pthread_self();
    
}
- (void)posix_setTheadInfor:(NSString *)key andValue:(id)value{
    pthread_key_t p_key = [key hash];
    pthread_key_create(&p_key, pkey_create);
    pthread_setspecific(p_key, (__bridge void *)value);
}

- (BOOL)posix_threadInfo_removeKey:(NSString *)key{
    return pthread_key_delete([key hash]) == 0 ? YES : NO;
}

@end

@implementation CocoaThread

+ (TPThread *)newThreadForDetached:(BOOL)detached withTarget:(id)target selector:(SEL)aSelector object:(id)aObject block:(void(^)(void))aBlock{
    TPThread *the_thread;
    if (detached == YES) {
        if (aBlock) {
            [TPThread detachNewThreadWithBlock:aBlock];
        }else{
            [TPThread detachNewThreadSelector:aSelector toTarget:target withObject:aObject];
        }
    }else{
        if (aBlock) {
            the_thread = [[TPThread alloc] initWithBlock:aBlock];
        }else{
            the_thread = [[TPThread alloc] initWithTarget:target selector:aSelector object:aObject];
        }
        // 同样设置无效
        //[the_thread setStackSize:1024];
    }
    [the_thread threadDictionary];
    return the_thread;
}

@end
