//
//  SVUIFPSMonitor.m
//  Utility
//
//  Created by ZK on 2017/6/12.
//
//

#import "SVUIFPSMonitor.h"
#import "SVWeakCycleObject.h"

@interface SVUIFPSMonitor()

@property (nonatomic, strong) CADisplayLink* displayLink;

@property (nonatomic, assign) NSInteger displayCount;

@property (nonatomic, assign) CFTimeInterval lastTime;

@property (nonatomic, strong) UILabel* fpsLabel;

@end


static SVUIFPSMonitor* UIFPSMonitor = nil;

@implementation SVUIFPSMonitor

+ (instancetype)sharedUIFPSMonitor {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        UIFPSMonitor = [[SVUIFPSMonitor alloc] init];
    });
    return UIFPSMonitor;
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)startMonitor {
    [[UIApplication sharedApplication].keyWindow addSubview:self.fpsLabel];
    self.fpsLabel.frame = CGRectMake([UIApplication sharedApplication].keyWindow.bounds.size.width-60, [UIApplication sharedApplication].keyWindow.bounds.size.height-100, 60, 40);
    self.displayLink.paused = NO;
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
        _fpsLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _fpsLabel.textColor = [UIColor whiteColor];
        _fpsLabel.textAlignment = NSTextAlignmentCenter;
        _fpsLabel.font = [UIFont systemFontOfSize:22];
    }
    return _fpsLabel;
}

- (void)displayLinkHandler {
    self.displayCount += self.displayLink.frameInterval;
    CFTimeInterval interval = self.displayLink.timestamp - self.lastTime;
    
    if (interval < 1.0f) {
        return;
    }
    
    CGFloat fps = (double)self.displayCount / interval;
    self.lastTime = self.displayLink.timestamp;
    self.displayCount = 0;
    
    self.fpsLabel.text = [NSString stringWithFormat:@"%.1f",fps];
    
}

@end