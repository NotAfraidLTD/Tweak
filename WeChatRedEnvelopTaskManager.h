//
//  WeChatRedEnvelopTaskManager.h
//  
//
//  Created by 任义春 on 2018/9/25.
//

#import <Foundation/Foundation.h>
#import "WeChatReceiveRedEnvelopOperation.h"
//class WeChatReceiveRedEnvelopOperation;

@interface WeChatRedEnvelopTaskManager : NSObject

+ (instancetype)sharedManager;

- (void)addNormalTask:(WeChatReceiveRedEnvelopOperation *)task;
- (void)addSerialTask:(WeChatReceiveRedEnvelopOperation *)task;

- (BOOL)serialQueueIsEmpty;

@end
