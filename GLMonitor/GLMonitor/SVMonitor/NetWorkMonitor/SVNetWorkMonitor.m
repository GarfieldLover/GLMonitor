//
//  SVNetWorkMonitor.m
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import "SVNetWorkMonitor.h"
#import "SVURLProtocol.h"

static SVNetWorkMonitor* netWorkMonitor = nil;

@implementation SVNetWorkMonitor

+ (instancetype)sharedNetWorkMonitor {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        netWorkMonitor = [[SVNetWorkMonitor alloc] init];
    });
    return netWorkMonitor;
}

- (void)startMonitor {
    [SVURLProtocol registerProtocolClass];
}

- (void)stopMonitor {
    [SVURLProtocol unregisterProtocolClass];

}


@end

