//
//  SVNetWorkMonitor.m
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import "SVNetWorkMonitor.h"

static SVNetWorkMonitor* netWorkMonitor = nil;

@implementation SVNetWorkMonitor

+ (instancetype)sharedNetWorkMonitor {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        netWorkMonitor = [[SVNetWorkMonitor alloc] init];
    });
    return netWorkMonitor;
}

//- (void)startMonitor {
//    [[UIApplication sharedApplication].keyWindow addSubview:self.fpsLabel];
//    self.fpsLabel.frame = CGRectMake([UIApplication sharedApplication].keyWindow.bounds.size.width-60, [UIApplication sharedApplication].keyWindow.bounds.size.height-100, 60, 40);
//    self.displayLink.paused = NO;
//}
//
//- (void)stopMonitor {
//    [self.fpsLabel removeFromSuperview];
//    self.displayLink.paused = YES;
//}


@end

