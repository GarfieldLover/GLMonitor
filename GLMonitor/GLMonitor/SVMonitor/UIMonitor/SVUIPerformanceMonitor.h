//
//  SVUIPerformanceMonitor.h
//  Utility
//
//  Created by ZK on 2017/6/9.
//
//

#import <Foundation/Foundation.h>
#import "SVMonitorActionProtocol.h"

@interface SVUIPerformanceMonitor : NSObject <SVMonitorActionProtocol>

@property (nonatomic, assign) BOOL LaunchViewControllerRealDismiss;

+ (instancetype)sharedInstance;

@end
