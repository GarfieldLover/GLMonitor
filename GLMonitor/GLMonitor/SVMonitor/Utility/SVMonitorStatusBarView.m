//
//  SVMonitorStatusBarView.m
//  Utility
//
//  Created by ZK on 2017/6/20.
//
//

#import "SVMonitorStatusBarView.h"
#import "SVMonitorStatusBarRootController.h"

@implementation SVMonitorStatusBarView

+ (instancetype)sharedInstance {
    static SVMonitorStatusBarView* statusBarView = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        statusBarView = [[SVMonitorStatusBarView alloc] init];
    });
    return statusBarView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 1.0;
        
        self.rootViewController = [[SVMonitorStatusBarRootController alloc] init];
        self.hidden = NO;
                
        UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
        self.frame = CGRectMake(0, 0, keyWindow.bounds.size.width, 20);
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
        [keyWindow addSubview:self];
        
        [[UIApplication sharedApplication] addObserver:self forKeyPath:@"statusBarStyle" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    UIStatusBarStyle style =  [change[NSKeyValueChangeNewKey] integerValue];
    
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)view;
            label.textColor = (style == UIStatusBarStyleDefault ? [UIColor blackColor] : [UIColor whiteColor]);
        }
    }
}


@end
