//
//  ViewController.h
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#import <UIKit/UIKit.h>
#define _RunloopSource_Version 2

#if _RunloopSource_Version == 2
#import "RunloopSource.h"
#endif
@interface ViewController : UIViewController

- (void)registerSuccess:(RunloopContext *)ctx;
- (void)removeSuccess:(RunloopContext *)ctx;

@end

