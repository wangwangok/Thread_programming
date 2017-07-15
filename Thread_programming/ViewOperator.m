//
//  ViewOperator.m
//  Thread_programming
//
//  Created by 王望 on 2017/7/15.
//  Copyright © 2017年 Will. All rights reserved.
//

#import "ViewOperator.h"

@interface ViewOperator ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityer;


@end

@implementation ViewOperator

- (void)StartLoading{
    [self.loadingView setHidden:NO];
    [self.activityer startAnimating];
}

- (void)updateResult:(NSString *)result{
    [self.activityer stopAnimating];
    [self.loadingView setHidden:YES];
    self.result_label.text = result;
}

@end
