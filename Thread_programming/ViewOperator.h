//
//  ViewOperator.h
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ViewOperator : NSObject

@property (weak, nonatomic) IBOutlet UILabel *result_label;

@property (weak, nonatomic) IBOutlet UIView *loadingView;


- (void)StartLoading;

- (void)updateResult:(NSString *)result;
@end
