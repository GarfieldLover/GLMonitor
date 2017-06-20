//
//  SVMonitorActionProtocol.h
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import <Foundation/Foundation.h>

@protocol SVMonitorActionProtocol <NSObject>

/**
 开始监控
 */
- (void)startMonitor;

/**
 结束监控
 */
- (void)stopMonitor;

@end
