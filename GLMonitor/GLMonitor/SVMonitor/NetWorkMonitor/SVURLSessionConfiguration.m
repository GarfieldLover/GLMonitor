//
//  SVURLSessionConfiguration.m
//  Utility
//
//  Created by ZK on 2017/6/14.
//
//

#import "SVURLSessionConfiguration.h"
#import <objc/runtime.h>
#import "SVURLProtocol.h"


@implementation SVURLSessionConfiguration

+ (SVURLSessionConfiguration *)sharedConfiguration {
    static SVURLSessionConfiguration *sessionConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionConfiguration = [[SVURLSessionConfiguration alloc] init];
    });
    return sessionConfiguration;
}

- (void)swizzleProtocolClasses {
    Class class = NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:class toClass:[self class]];
}

- (void)unSwizzleProtocolClasses {
    Class class = NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:[self class] toClass:class];
}

- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
    
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);

    method_exchangeImplementations(originalMethod, stubMethod);
}

- (NSArray *)protocolClasses {
    
    return @[[SVURLProtocol class]];
}


@end
