//
//  SVMemoryMonitor.h
//  Utility
//
//  Created by ZK on 2017/6/21.
//
//

#import <Foundation/Foundation.h>
#import "SVMonitorActionProtocol.h"

@interface SVMemoryMonitor : NSObject <SVMonitorActionProtocol>

+ (instancetype)sharedInstance;

@end
