//
//  SVCPUMonitor.m
//  Utility
//
//  Created by ZK on 2017/6/20.
//
//

#import "SVCPUMonitor.h"
#import <mach/task.h>
#import <mach/task_info.h>
#import <mach/thread_act.h>
#import <mach/thread_info.h>
#import <mach/mach_init.h>
#import <mach/vm_map.h>
#import <mach/mach_host.h>
#import "SVMonitorStatusBarView.h"

typedef struct LXDSystemCPUUsage {
    double system;  ///< 系统占用率
    double user;    ///< user占用率
    double nice;    ///< 加权user占用率
    double idle;    ///< 空闲率
} LXDSystemCPUUsage;

/// processor_info_array_t结构数据偏移位
typedef NS_ENUM(NSInteger, LXDCPUInfoOffsetState)
{
    LXDCPUInfoOffsetStateSystem = 0,
    LXDCPUInfoOffsetStateUser = 1,
    LXDCPUInfoOffsetStateNice = 2,
    LXDCPUInfoOffsetStateIdle = 3,
    LXDCPUInfoOffsetStateMask = 4,
};

/// cpu信息结构体
static NSUInteger LXDSystemCPUInfoCount = 4;
typedef struct LXDSystemCPUInfo {
    NSUInteger system;  ///< 系统态占用。
    NSUInteger user;    ///< 用户态占用。
    NSUInteger nice;    ///< nice加权的用户态占用。
    NSUInteger idle;    ///< 空闲占用
} LXDSystemCPUInfo;

/// 结构体构造转换
static inline LXDSystemCPUInfo __LXDSystemCPUInfoMake(NSUInteger system, NSUInteger user, NSUInteger nice, NSUInteger idle) {
    return (LXDSystemCPUInfo){ system, user, nice, idle };
}

static inline NSString * LXDStringFromSystemCPUInfo(LXDSystemCPUInfo systemCPUInfo) {
    return [NSString stringWithFormat: @"%lu-%lu-%lu-%lu", systemCPUInfo.system, systemCPUInfo.user, systemCPUInfo.nice, systemCPUInfo.idle];
}
static inline LXDSystemCPUInfo LXDSystemCPUInfoFromString(NSString * string) {
    NSArray * infos = [string componentsSeparatedByString: @"-"];
    if (infos.count == LXDSystemCPUInfoCount) {
        return __LXDSystemCPUInfoMake(
                                      [infos[LXDCPUInfoOffsetStateSystem] integerValue],
                                      [infos[LXDCPUInfoOffsetStateUser] integerValue],
                                      [infos[LXDCPUInfoOffsetStateNice] integerValue],
                                      [infos[LXDCPUInfoOffsetStateIdle] integerValue]);
    }
    return (LXDSystemCPUInfo){ 0 };
}



@interface SVCPUMonitor () {
    dispatch_source_t _timer;
}

@property (nonatomic, strong) UILabel* appCPULabel;

@end


@implementation SVCPUMonitor

+ (instancetype)sharedInstance {
    static SVCPUMonitor* CPUMonitor = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CPUMonitor = [[SVCPUMonitor alloc] init];
    });
    return CPUMonitor;
}

- (void)startMonitor {
    self.appCPULabel.frame = CGRectMake(60, 0, 70, [SVMonitorStatusBarView sharedInstance].bounds.size.height);
    [[SVMonitorStatusBarView sharedInstance] addSubview:self.appCPULabel];
    
    NSTimeInterval period = 0.5; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL,0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        //在这里执行事件
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIScreen mainScreen].bounds.size.width == 320) {
                self.appCPULabel.text = [NSString stringWithFormat:@"C:%.1f%s", [self appUsage], "%"];
            } else {
                self.appCPULabel.text = [NSString stringWithFormat:@"CPU: %.1f%s", [self appUsage], "%"];
            }
        });
    });
    dispatch_resume(_timer);
}

- (void)stopMonitor {
    [self.appCPULabel removeFromSuperview];

    dispatch_source_cancel(_timer);
}

- (UILabel *)appCPULabel {
    if (!_appCPULabel) {
        _appCPULabel = [[UILabel alloc] init];
        _appCPULabel.textColor = [UIColor whiteColor];
        _appCPULabel.font = [UIFont boldSystemFontOfSize:10];
    }
    return _appCPULabel;
}

- (double)appUsage {
    double usageRatio = 0;
    thread_info_data_t thinfo;
    thread_act_array_t threads;
    thread_basic_info_t basic_info_t;
    mach_msg_type_number_t count = 0;
    mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
    
    if (task_threads(mach_task_self(), &threads, &count) == KERN_SUCCESS) {
        for (int idx = 0; idx < count; idx++) {
            if (thread_info(threads[idx], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count) == KERN_SUCCESS) {
                basic_info_t = (thread_basic_info_t)thinfo;
                if (!(basic_info_t->flags & TH_FLAGS_IDLE)) {
                    usageRatio += basic_info_t->cpu_usage / (double)TH_USAGE_SCALE;
                }
            }
        }
        assert(vm_deallocate(mach_task_self(), (vm_address_t)threads, count * sizeof(thread_t)) == KERN_SUCCESS);
    }
    return usageRatio * 100.0;
}

- (LXDSystemCPUUsage)currentUsage {
    return [self generateSystemCpuUsageWithCpuInfos: [self generateCpuInfos]];
}

- (NSArray<NSString *> *)generateCpuInfos {
    natural_t cpu_processor_count = 0;
    natural_t cpu_processor_info_count = 0;
    processor_info_array_t cpu_processor_infos = NULL;
    
    kern_return_t result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpu_processor_count, &cpu_processor_infos, &cpu_processor_info_count);
    if ( result == KERN_SUCCESS && cpu_processor_infos != NULL ) {
        NSMutableArray * infos = [NSMutableArray arrayWithCapacity: cpu_processor_count];
        for (int idx = 0; idx < cpu_processor_count; idx++) {
            NSInteger offset = LXDCPUInfoOffsetStateMask * idx;
            
            double system, user, nice, idle;
            system = cpu_processor_infos[offset + LXDCPUInfoOffsetStateSystem];
            user = cpu_processor_infos[offset + LXDCPUInfoOffsetStateUser];
            nice = cpu_processor_infos[offset + LXDCPUInfoOffsetStateNice];
            idle = cpu_processor_infos[offset + LXDCPUInfoOffsetStateIdle];
            LXDSystemCPUInfo info = __LXDSystemCPUInfoMake( system, user, nice, idle );
            [infos addObject: LXDStringFromSystemCPUInfo(info)];
        }
        
        vm_size_t cpuInfoSize = sizeof(int32_t) * cpu_processor_count;
        vm_deallocate(mach_task_self_, (vm_address_t)cpu_processor_infos, cpuInfoSize);
        return infos;
    }
    return nil;
}

- (LXDSystemCPUUsage)generateSystemCpuUsageWithCpuInfos: (NSArray<NSString *> *)cpuInfos {
    if (cpuInfos.count == 0) { return (LXDSystemCPUUsage){ 0 }; }
    double system = 0, user = 0, nice = 0, idle = 0;
    for (NSString * cpuInfoString in cpuInfos) {
        LXDSystemCPUInfo cpuInfo = LXDSystemCPUInfoFromString(cpuInfoString);
        system += cpuInfo.system;
        user += cpuInfo.user;
        nice += cpuInfo.nice;
        idle += cpuInfo.idle;
    }
    system /= cpuInfos.count;
    user /= cpuInfos.count;
    nice /= cpuInfos.count;
    idle /= cpuInfos.count;
    
    double total = system + user + nice + idle;
    return (LXDSystemCPUUsage){
        .system = system / total,
        .user = user / total,
        .nice = nice / total,
        .idle = idle / total,
    };
}


@end
