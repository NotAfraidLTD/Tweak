//
//  WeChatRedEnvelopParamQueue.h
//  
//
//  Created by 任义春 on 2018/9/25.
//

#import <Foundation/Foundation.h>

@class WeChatRedEnvelopParam;
@interface WeChatRedEnvelopParamQueue : NSObject

+ (instancetype)sharedQueue;

- (void)enqueue:(WeChatRedEnvelopParam *)param;
- (WeChatRedEnvelopParam *)dequeue;
- (WeChatRedEnvelopParam *)peek;
- (BOOL)isEmpty;

@end
