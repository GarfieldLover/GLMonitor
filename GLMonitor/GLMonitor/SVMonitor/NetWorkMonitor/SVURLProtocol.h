//
//  SVURLProtocol.h
//  Utility
//
//  Created by ZK on 2017/6/14.
//
//

#import <Foundation/Foundation.h>

@interface SVURLProtocol : NSURLProtocol

+ (void)registerProtocolClass;

+ (void)unregisterProtocolClass;

@end
