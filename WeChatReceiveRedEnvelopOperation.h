//
//  WeChatReceiveRedEnvelopOperation.h
//  
//
//  Created by 任义春 on 2018/9/25.
//

#import <UIKit/UIKit.h>
@class WeChatRedEnvelopParam;

@interface WeChatReceiveRedEnvelopOperation : NSOperation

- (instancetype)initWithRedEnvelopParam:(WeChatRedEnvelopParam *)param delay:(unsigned int)delaySeconds;

@end
