//
//  WeChatRedEnvelopParamQueue.m
//  
//
//  Created by 任义春 on 2018/9/25.
//

#import "WeChatRedEnvelopParamQueue.h"

@interface WeChatRedEnvelopParamQueue()

@property (strong, nonatomic) NSMutableArray *queue;

@end

@implementation WeChatRedEnvelopParamQueue

+ (instancetype)sharedQueue{

    static WeChatRedEnvelopParamQueue * paramQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paramQueue = [[WeChatRedEnvelopParamQueue alloc] init];
    });
    return paramQueue;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)enqueue:(WeChatRedEnvelopParam *)param {
    [self.queue addObject:param];
}

- (WeChatRedEnvelopParam *)dequeue {
    if (self.queue.count == 0 && !self.queue.firstObject) {
        return nil;
    }

    WeChatRedEnvelopParam *first = self.queue.firstObject;

    [self.queue removeObjectAtIndex:0];

    return first;
}

- (WeChatRedEnvelopParam *)peek {
    if (self.queue.count == 0) {
        return nil;
    }

    return self.queue.firstObject;
}

- (BOOL)isEmpty {
    return self.queue.count == 0;
}



@end
