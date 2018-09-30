//
//  WeChatTweakSetViewController.m
//  TweakDylib
//
//  Created by 任义春 on 2018/9/20.
//  Copyright © 2018年 Zhuxin. All rights reserved.
//

#import "WeChatTweakSetViewController.h"
#import "WeChatAutoOpenRedEnvelopConfig.h"
#import "TweakMakeHeader.h"
#import <objc/objc-runtime.h>


@interface WeChatTweakSetViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@property (strong, nonatomic) MMLoadingView *loadingView;

@end

@implementation WeChatTweakSetViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTitle];
    [self reloadTableData];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopLoading];
}

- (void)initTitle{
    self.title = @"微信小助手";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    NSLog(@"reloadTableData ");
    [self.tableViewInfo clearAllSection];
    [self addBasicSettingSection];
    [self addAdvanceSettingSection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - BasicSetting

- (void)addBasicSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];

    [sectionInfo addCell:[self createAutoReceiveRedEnvelopCell]];
    [sectionInfo addCell:[self createDelaySettingCell]];

    [self.tableViewInfo addSection:sectionInfo];
}

#pragma mark - ProSetting
- (void)addAdvanceSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"高级功能"];

    [sectionInfo addCell:[self createReceiveSelfRedEnvelopCell]];
    [sectionInfo addCell:[self createQueueCell]];

    [self.tableViewInfo addSection:sectionInfo];

}

- (MMTableViewCellInfo *)createReceiveSelfRedEnvelopCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingReceiveSelfRedEnvelop:) target:self title:@"抢自己发的红包" on:[WeChatAutoOpenRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop];
}

- (MMTableViewCellInfo *)createQueueCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingReceiveByQueue:) target:self title:@"防止同时抢多个红包" on:[WeChatAutoOpenRedEnvelopConfig sharedConfig].serialReceive];
}

- (MMTableViewCellInfo *)createAutoReceiveRedEnvelopCell{
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (MMTableViewCellInfo *)createDelaySettingCell {
    NSInteger delaySeconds = [WeChatAutoOpenRedEnvelopConfig sharedConfig].delaySeconds;
    NSLog(@"delaySeconds %ld",(long)delaySeconds);

    NSString *delayString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];

    MMTableViewCellInfo *cellInfo;
    if ([WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue: delayString accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"延迟抢红包" rightValue: @"抢红包已关闭"];
    }
    return cellInfo;
}

- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    [WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable = envelopSwitch.on;
    NSLog(@"switchRedEnvelop %d",[WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable);
    [self reloadTableData];
}

- (void)settingReceiveSelfRedEnvelop:(UISwitch *)receiveSwitch {
    [WeChatAutoOpenRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop = receiveSwitch.on;
}

- (void)settingReceiveByQueue:(UISwitch *)queueSwitch {
    [WeChatAutoOpenRedEnvelopConfig sharedConfig].serialReceive = queueSwitch.on;
}

- (void)settingDelay{
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"延迟抢红包(秒)";

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];

    [alert textFieldAtIndex:0].placeholder = @"延迟时长";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString * delaySecondsString = [alertView textFieldAtIndex:0].text;
        NSInteger delaySeconds = [delaySecondsString integerValue];

        [WeChatAutoOpenRedEnvelopConfig sharedConfig].delaySeconds = delaySeconds;

        [self reloadTableData];
    }
}



- (void)stopLoading {
    [self.loadingView stopLoading];
}

@end
