//
//  SVUIFPSMonitor.m
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import "SVUIFPSMonitor.h"
#import "SVWeakCycleObject.h"
#import "SVMonitorStatusBarView.h"

@interface SVUIFPSMonitor()

@property (nonatomic, strong) CADisplayLink* displayLink;

@property (nonatomic, assign) NSInteger displayCount;

@property (nonatomic, assign) CFTimeInterval lastTime;

@property (nonatomic, strong) UILabel* fpsLabel;

@end


static SVUIFPSMonitor* UIFPSMonitor = nil;

@implementation SVUIFPSMonitor

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UIFPSMonitor = [[SVUIFPSMonitor alloc] init];
    });
    return UIFPSMonitor;
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)startMonitor {
    self.displayLink.paused = NO;
    
    self.fpsLabel.frame = CGRectMake(5, 0, 60, [SVMonitorStatusBarView sharedInstance].bounds.size.height);
    [[SVMonitorStatusBarView sharedInstance] addSubview:self.fpsLabel];
}

- (void)stopMonitor {
    [self.fpsLabel removeFromSuperview];
    self.displayLink.paused = YES;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        //循环引用
        _displayLink = [CADisplayLink displayLinkWithTarget:[SVWeakCycleObject weakCycleWithTarget:self] selector:@selector(displayLinkHandler)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    return _displayLink;
}

- (UILabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[UILabel alloc] init];
        _fpsLabel.textColor = [UIColor whiteColor];
        _fpsLabel.font = [UIFont boldSystemFontOfSize:10];
    }
    return _fpsLabel;
}

- (void)displayLinkHandler {
    self.displayCount += self.displayLink.frameInterval;
    CFTimeInterval interval = self.displayLink.timestamp - self.lastTime;
    
    if (interval < 1.0f) {
        return;
    }
    
    NSInteger fps = (NSInteger)self.displayCount / interval;
    self.lastTime = self.displayLink.timestamp;
    self.displayCount = 0;
    
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %ld",(long)fps];
}

@end
