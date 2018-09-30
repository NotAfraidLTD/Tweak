//
//  WeChatReceiveRedEnvelopOperation.m
//  
//
//  Created by 任义春 on 2018/9/25.
//

#import "WeChatReceiveRedEnvelopOperation.h"
#import "WeChatRedEnvelopParam.h"
#import "TweakMakeHeader.h"
#import <objc/objc-runtime.h>

@interface WeChatReceiveRedEnvelopOperation()

@property (nonatomic, assign ,getter=isExecuting) BOOL executing;

@property (nonatomic, assign ,getter=isFinished) BOOL finished;

/** 红包参数 */
@property (nonatomic, strong) WeChatRedEnvelopParam * redEnvelopParam;

/** 延时参数 */
@property (nonatomic, assign) unsigned int delaySeconds;

@end


@implementation WeChatReceiveRedEnvelopOperation

@synthesize executing = _executing;

@synthesize finished = _finished;

- (instancetype)initWithRedEnvelopParam:(WeChatRedEnvelopParam *)param delay:(unsigned int)delaySeconds{

    if (self = [super init]){
        _redEnvelopParam = param;
        _delaySeconds = delaySeconds;
        [self setQueuePriority:NSOperationQueuePriorityHigh];
    }

    return self;
}

- (void)start{
    if (self.isCancelled){
        self.finished = YES;
        self.executing = NO;
        return;
    }

    [self main];

    self.executing = YES;
    self.finished = NO;

}

- (NSString *)timeString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间
    NSString * currentDate = [formatter stringFromDate:datenow];
    return currentDate;
}

- (void)main{

    NSLog(@"Operation main delaySeconds = %u start time = %@",self.delaySeconds,[self timeString]);
    sleep(self.delaySeconds);
    NSLog(@" Operation main delaySeconds time = %@ ",[self timeString]);
    WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
    NSLog(@"Operation main OpenRedEnvelopesRequest = %@",self.redEnvelopParam);
    [logicMgr OpenRedEnvelopesRequest:[self.redEnvelopParam toParams]];
}

- (void)cancel{
    self.finished = YES;
    self.executing = NO;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isAsynchronous {
    return YES;
}

@end
