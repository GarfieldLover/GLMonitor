//
//  SVUIFPSMonitor.h
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import <Foundation/Foundation.h>
#import "SVMonitorActionProtocol.h"

@interface SVUIFPSMonitor : NSObject <SVMonitorActionProtocol>

+ (instancetype)sharedInstance;

@end
