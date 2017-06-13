//
//  SVBacktraceLogger.h
//  Utility
//
//  Created by ZK on 2017/6/9.
//
//

#import <Foundation/Foundation.h>

@interface SVBacktraceLogger : NSObject

+ (NSString *)sv_backtraceOfAllThread;
+ (NSString *)sv_backtraceOfCurrentThread;
+ (NSString *)sv_backtraceOfMainThread;
+ (NSString *)sv_backtraceOfNSThread:(NSThread *)thread;

@end
