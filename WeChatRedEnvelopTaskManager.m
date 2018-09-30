//
//  WeChatRedEnvelopTaskManager.m
//  
//
//  Created by 任义春 on 2018/9/25.
//

#import "WeChatRedEnvelopTaskManager.h"
#import "WeChatReceiveRedEnvelopOperation.h"

@interface WeChatRedEnvelopTaskManager()

@property (nonatomic, strong) NSOperationQueue *normalTaskQueue;

@property (nonatomic, strong) NSOperationQueue *serialTaskQueue;

@end

@implementation WeChatRedEnvelopTaskManager

+ (instancetype)sharedManager{
    static WeChatRedEnvelopTaskManager * taskManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        taskManager = [[WeChatRedEnvelopTaskManager alloc] init];
    });
    return taskManager;
}

- (instancetype)init{
    if(self =[super init]){
        _normalTaskQueue = [[NSOperationQueue alloc] init];
        _normalTaskQueue.maxConcurrentOperationCount = 5;

        _serialTaskQueue = [[NSOperationQueue alloc] init];
        _serialTaskQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)addNormalTask:(WeChatReceiveRedEnvelopOperation *)task {
    NSLog(@"WeChatRedEnvelopTaskManager addNormalTask");
    [self.normalTaskQueue addOperation:task];
}

- (void)addSerialTask:(WeChatReceiveRedEnvelopOperation *)task {
    NSLog(@"WeChatRedEnvelopTaskManager addSerialTask");
    [self.serialTaskQueue addOperation:task];
}

- (BOOL)serialQueueIsEmpty {
    return [self.serialTaskQueue operations].count == 0;
}

@end
