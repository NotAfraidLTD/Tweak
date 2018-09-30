//
//  WeChatAutoOpenRedEnvelopConfig.h
//  TweakDylib
//
//  Created by 任义春 on 2018/9/20.
//  Copyright © 2018年 Zhuxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeChatAutoOpenRedEnvelopConfig : NSObject

+ (instancetype)sharedConfig;

/** 延时秒数 */
@property (nonatomic, assign) NSInteger delaySeconds;

/** 开启自动抢红包 */
@property (nonatomic, assign) BOOL autoReceiveEnable;

/** 抢自己的红包 */
@property (nonatomic, assign) BOOL receiveSelfRedEnvelop;

/** 同时抢多个红包 */
@property (nonatomic, assign) BOOL serialReceive;

@end
