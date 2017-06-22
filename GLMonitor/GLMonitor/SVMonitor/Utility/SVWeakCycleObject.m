//
//  SVWeakCycleObject.m
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import "SVWeakCycleObject.h"

@implementation SVWeakCycleObject

+ (instancetype)weakCycleWithTarget:(id)target {
    return [[SVWeakCycleObject alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}


#pragma mark - private

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)isProxy {
    return YES;
}

- (Class)class {
    return [_target class];
}

- (Class)superclass {
    return [_target superclass];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

- (BOOL)isEqual: (id)object {
    return [_target isEqual: object];
}

- (BOOL)isKindOfClass: (Class)aClass {
    return [_target isKindOfClass: aClass];
}

- (BOOL)isMemberOfClass: (Class)aClass {
    return [_target isMemberOfClass: aClass];
}

- (BOOL)respondsToSelector: (SEL)aSelector {
    return [_target respondsToSelector: aSelector];
}

- (BOOL)conformsToProtocol: (Protocol *)aProtocol {
    return [_target conformsToProtocol: aProtocol];
}



@end
