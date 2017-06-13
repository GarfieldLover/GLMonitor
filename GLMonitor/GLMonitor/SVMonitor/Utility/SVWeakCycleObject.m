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


@end
