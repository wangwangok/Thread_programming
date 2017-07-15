//
//  POSIX_Thread.h
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#ifndef POSIX_Thread_h
#define POSIX_Thread_h

#include <stdio.h>
#include <pthread.h>
#include <assert.h>
pthread_t tp_pthread_create(void*(*main_entry_point)(void *),void *res,pthread_cond_t *condition);

#endif /* POSIX_Thread_h */
