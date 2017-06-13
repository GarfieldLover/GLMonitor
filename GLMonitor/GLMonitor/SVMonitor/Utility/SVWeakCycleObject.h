//
//  SVWeakCycleObject.h
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import <Foundation/Foundation.h>

@interface SVWeakCycleObject : NSObject

@property (nonatomic, weak, readonly) id target;

+ (instancetype)weakCycleWithTarget:(id)target;

- (instancetype)initWithTarget:(id)target;

@end
