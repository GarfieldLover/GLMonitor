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
        self.backgroundColor = [UIColor blackColor];
        self.windowLevel = UIWindowLevelStatusBar + 1.0;
        
        self.rootViewController = [[SVMonitorStatusBarRootController alloc] init];
        self.hidden = NO;
                
        UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
        self.frame = CGRectMake(keyWindow.bounds.size.width/4, 2, keyWindow.bounds.size.width/2, 16);
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        
        
//        [[UIApplication sharedApplication] addObserver:self forKeyPath:@"statusBarStyle" options:NSKeyValueObservingOptionNew context:nil];
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
