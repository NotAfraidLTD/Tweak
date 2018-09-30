//
//  WeChatAutoOpenRedEnvelopConfig.m
//  TweakDylib
//
//  Created by 任义春 on 2018/9/20.
//  Copyright © 2018年 Zhuxin. All rights reserved.
//

#import "WeChatAutoOpenRedEnvelopConfig.h"

static NSString * const kDelaySecondsKey                = @"XGDelaySecondsKey";
static NSString * const kAutoReceiveRedEnvelopKey       = @"XGWeChatRedEnvelopSwitchKey";
static NSString * const kReceiveSelfRedEnvelopKey       = @"WBReceiveSelfRedEnvelopKey";
static NSString * const kSerialReceiveKey               = @"WBSerialReceiveKey";

@implementation WeChatAutoOpenRedEnvelopConfig

+ (instancetype)sharedConfig{
    static WeChatAutoOpenRedEnvelopConfig * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [WeChatAutoOpenRedEnvelopConfig new];
    });
    return config;
}

- (instancetype)init{
    if(self = [super init]){
        _delaySeconds =  [[NSUserDefaults standardUserDefaults] integerForKey:kDelaySecondsKey];
        _autoReceiveEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoReceiveRedEnvelopKey];
        _receiveSelfRedEnvelop = [[NSUserDefaults standardUserDefaults] boolForKey:kReceiveSelfRedEnvelopKey];
        _serialReceive = [[NSUserDefaults standardUserDefaults] boolForKey:kSerialReceiveKey];
    }

    return self;
}

- (void)setDelaySeconds:(NSInteger)delaySeconds {
    _delaySeconds = delaySeconds;

    [[NSUserDefaults standardUserDefaults] setInteger:delaySeconds forKey:kDelaySecondsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReceiveEnable:(BOOL)autoReceiveEnable {
    _autoReceiveEnable = autoReceiveEnable;

    [[NSUserDefaults standardUserDefaults] setBool:autoReceiveEnable forKey:kAutoReceiveRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReceiveSelfRedEnvelop:(BOOL)receiveSelfRedEnvelop {
    _receiveSelfRedEnvelop = receiveSelfRedEnvelop;

    [[NSUserDefaults standardUserDefaults] setBool:receiveSelfRedEnvelop forKey:kReceiveSelfRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSerialReceive:(BOOL)serialReceive {
    _serialReceive = serialReceive;

    [[NSUserDefaults standardUserDefaults] setBool:serialReceive forKey:kSerialReceiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
