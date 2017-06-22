//
//  SVMonitorManager.m
//  Utility
//
//  Created by ZK on 2017/6/21.
//
//

#import "SVMonitorManager.h"
#import "SVUIPerformanceMonitor.h"
#import "SVUIFPSMonitor.h"
#import "SVNetWorkMonitor.h"
#import "SVCPUMonitor.h"
#import "SVMemoryMonitor.h"

@implementation SVMonitorManager

+ (void)startMonitor {
    [[SVUIPerformanceMonitor sharedInstance] startMonitor];
    [[SVUIFPSMonitor sharedInstance] startMonitor];
    [[SVNetWorkMonitor sharedInstance] startMonitor];
    [[SVCPUMonitor sharedInstance] startMonitor];
    [[SVMemoryMonitor sharedInstance] startMonitor];
}

@end
