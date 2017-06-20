//
//  SVCPUMonitor.h
//  Utility
//
//  Created by ZK on 2017/6/20.
//
//

#import <Foundation/Foundation.h>
#import "SVMonitorActionProtocol.h"

@interface SVCPUMonitor : NSObject <SVMonitorActionProtocol>


+ (instancetype)sharedUIFPSMonitor;

@end
