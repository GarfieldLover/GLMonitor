//
//  SVURLSessionConfiguration.h
//  Utility
//
//  Created by ZK on 2017/6/14.
//
//

#import <Foundation/Foundation.h>

@interface SVURLSessionConfiguration : NSObject

/**
 设置URLSessionConfiguration

 @return 单例
 */
+ (SVURLSessionConfiguration *)sharedConfiguration;

- (void)swizzleProtocolClasses;
- (void)unSwizzleProtocolClasses;

@end
