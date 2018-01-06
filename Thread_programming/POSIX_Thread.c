//
//  POSIX_Thread.c
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#include "POSIX_Thread.h"

pthread_t tp_pthread_create(void*(*main_entry_point)(void *),void *res,pthread_cond_t *condition){
    
    int result;
    pthread_t thread_id;
    pthread_attr_t thread_attr;
    result = pthread_attr_init(&thread_attr);
    if (result != 0) {
        assert(result);
    }
    /// PTHREAD_CREATE_JOINABLE
    /// PTHREAD_CREATE_DETACHED
    result = pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
    if (result != 0) {
        assert(result);
    }
    // 尝试更改线程栈大小无效，我选择死亡😂
    ///pthread_attr_setstacksize(&thread_attr, 524304);
    
    pthread_mutex_t mutex_t;
    result = pthread_mutex_init(&mutex_t, NULL);
    if (result != 0) {
        assert(result);
    }
    int thread_error = pthread_create(&thread_id, &thread_attr, main_entry_point, res);
    /**
     * 解释一下为什么在使用条件变量时需要传入一个mutex，首先得知道mutex互斥的特性，而且条件变量在多次使用时，是可以broadcast的。所以为了保证condition的唯一性，需要使用mutex实现。即：
     “条件本身是由互斥量来保护的”！！！
     */
    pthread_mutex_lock(&mutex_t);
    /// 防止过早返回，导致主入口点函数出错
    result = pthread_cond_timedwait(condition, &mutex_t, NULL);
    pthread_mutex_unlock(&mutex_t);
    if (result != 0) {
        assert(result);
    }
    if (thread_error != 0) {
        /// error
        assert(thread_error);
    }
    ///size_t stack_size;
    ///pthread_attr_getstacksize(&thread_attr, &stack_size);
    ///printf("%zd",stack_size);
    pthread_attr_destroy(&thread_attr);
    pthread_mutex_destroy(&mutex_t);
    return thread_id;
}
