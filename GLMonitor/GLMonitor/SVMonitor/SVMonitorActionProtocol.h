//
//  SVMonitorActionProtocol.h
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@protocol SVMonitorActionProtocol <NSObject>

- (void)startMonitor;

- (void)stopMonitor;

@end
