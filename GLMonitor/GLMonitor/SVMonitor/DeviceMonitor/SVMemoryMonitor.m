//
//  SVMemoryMonitor.m
//  Utility
//
//  Created by ZK on 2017/6/21.
//
//

#import "SVMemoryMonitor.h"
#import <mach/mach.h>
#import <mach/task_info.h>
#import "SVMonitorStatusBarView.h"

typedef struct LXDSystemMemoryUsage
{
    double free;    ///< 自由内存(MB)
    double wired;   ///< 固定内存(MB)
    double active;  ///< 正在使用的内存(MB)
    double inactive;    ///< 缓存、后台内存(MB)
    double compressed;  ///< 压缩内存(MB)
    double total;   ///< 总内存(MB)
} LXDSystemMemoryUsage;

typedef struct LXDApplicationMemoryUsage
{
    double usage;   ///< 已用内存(MB)
    double total;   ///< 总内存(MB)
    double ratio;   ///< 占用比率
} LXDApplicationMemoryUsage;

#ifndef NBYTE_PER_MB
#define NBYTE_PER_MB (1024.0 * 1024.0)
#endif

@interface SVMemoryMonitor () {
    dispatch_source_t _timer;
}

@property (nonatomic, strong) UILabel* appMemoryLabel;

@end

@implementation SVMemoryMonitor

+ (instancetype)sharedInstance {
    static SVMemoryMonitor* MemoryMonitor = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        MemoryMonitor = [[SVMemoryMonitor alloc] init];
    });
    return MemoryMonitor;
}

- (void)startMonitor {
    self.appMemoryLabel.frame = CGRectMake([SVMonitorStatusBarView sharedInstance].bounds.size.width-70, 0, 70, [SVMonitorStatusBarView sharedInstance].bounds.size.height);
    [[SVMonitorStatusBarView sharedInstance] addSubview:self.appMemoryLabel];
    
    NSTimeInterval period = 0.5; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL,0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        //在这里执行事件
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIScreen mainScreen].bounds.size.width == 320) {
                self.appMemoryLabel.text = [NSString stringWithFormat:@"M:%ldM", (long)[self currentUsage].usage];
            } else {
                self.appMemoryLabel.text = [NSString stringWithFormat:@"RAM: %ldM", (long)[self currentUsage].usage];
            }
        });
    });
    dispatch_resume(_timer);
}

- (void)stopMonitor {
    [self.appMemoryLabel removeFromSuperview];
    
    dispatch_source_cancel(_timer);
}

- (UILabel *)appMemoryLabel {
    if (!_appMemoryLabel) {
        _appMemoryLabel = [[UILabel alloc] init];
        _appMemoryLabel.textColor = [UIColor whiteColor];
        _appMemoryLabel.font = [UIFont boldSystemFontOfSize:10];
    }
    return _appMemoryLabel;
}

- (LXDApplicationMemoryUsage)currentUsage {
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = sizeof(info) / sizeof(integer_t);
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS) {
        return (LXDApplicationMemoryUsage){
            .usage = info.resident_size / NBYTE_PER_MB,
            .total = [NSProcessInfo processInfo].physicalMemory / NBYTE_PER_MB,
            .ratio = info.virtual_size / [NSProcessInfo processInfo].physicalMemory,
        };
    }
    return (LXDApplicationMemoryUsage){ 0 };
}

- (LXDSystemMemoryUsage)currentSystemMemoryUsage {
    vm_statistics64_data_t vmstat;
    natural_t size = HOST_VM_INFO64_COUNT;
    if (host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vmstat, &size) == KERN_SUCCESS) {
        return (LXDSystemMemoryUsage){
            .free = vmstat.free_count * PAGE_SIZE / NBYTE_PER_MB,
            .wired = vmstat.wire_count * PAGE_SIZE / NBYTE_PER_MB,
            .active = vmstat.active_count * PAGE_SIZE / NBYTE_PER_MB,
            .inactive = vmstat.inactive_count * PAGE_SIZE / NBYTE_PER_MB,
            .compressed = vmstat.compressor_page_count * PAGE_SIZE / NBYTE_PER_MB,
            .total = [NSProcessInfo processInfo].physicalMemory / NBYTE_PER_MB,
        };
    }
    return (LXDSystemMemoryUsage){ 0 };
}

@end
