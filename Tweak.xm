#import "TweakMakeHeader.h"
#import "WeChatMessageWarp.h"
#import "WeChatTweakSetViewController.h"
#import "WeChatAutoOpenRedEnvelopConfig.h"
#import "WeChatReceiveRedEnvelopOperation.h"
#import "WeChatRedEnvelopParamQueue.h"
#import "WeChatRedEnvelopParam.h"
#import "WeChatRedEnvelopTaskManager.h"


%group group1



%hook NewSettingViewController

- (void)reloadTableData {
	%orig;
	MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];
	MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");
	MMTableViewCellInfo * settingCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(setting) target:self title:@"微信小助手" accessoryType:1];
	[sectionInfo addCell:settingCell];

	[tableViewInfo insertSection:sectionInfo At:0];
	MMTableView *tableView = [tableViewInfo getTableView];
	[tableView reloadData];
}

%new
- (void)setting {
	WeChatTweakSetViewController * settingViewController = [WeChatTweakSetViewController new];
	[self.navigationController pushViewController:settingViewController animated:YES];
}

%end

%hook WCRedEnvelopesLogicMgr

- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2 {

	%orig;
	
	NSLog(@"TW OnWCToHongbaoCommonResponse");

	// 非参数查询请求
	if (arg1.cgiCmdid != 3) { return; }

	NSString *(^parseRequestSign)() = ^NSString *() {
        
		NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
		NSDictionary *requestDictionary = [%c(WCBizUtil) dictionaryWithDecodedComponets:requestString separator:@"&"];
		NSString *nativeUrl = [[requestDictionary objectForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
		NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];

		return [nativeUrlDict objectForKey:@"sign"];
	};

	NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:arg1.retText.buffer
                                               options:0
                                                 error:nil];

	WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParamQueue sharedQueue] dequeue];

	BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {

		// 手动抢红包
		if (!mgrParams) { return NO; }

		// 自己已经抢过
		if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }

		// 红包被抢完
		if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }		

		// 没有这个字段会被判定为使用外挂
		if (!responseDict[@"timingIdentifier"]) { return NO; }		

		if (mgrParams.isGroupSender) { // 自己发红包的时候没有 sign 字段
			return [WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable;
		} else {
			return [parseRequestSign() isEqualToString:mgrParams.sign] && [WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable;
		}
	};

	if (shouldReceiveRedEnvelop()) {

		NSLog(@"TW 可抢的红包");

		mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];

		unsigned int delaySeconds = [self calculateDelaySeconds];
		WeChatReceiveRedEnvelopOperation * operation = [[WeChatReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:delaySeconds];

		if ([WeChatAutoOpenRedEnvelopConfig sharedConfig].serialReceive) {
			NSLog(@"TW addSerialTask");
			[[WeChatRedEnvelopTaskManager sharedManager] addSerialTask:operation];
		} else {
			NSLog(@"TW addNormalTask");
			[[WeChatRedEnvelopTaskManager sharedManager] addNormalTask:operation];
		}
	}
}

%new
- (unsigned int)calculateDelaySeconds {
	NSInteger configDelaySeconds = [WeChatAutoOpenRedEnvelopConfig sharedConfig].delaySeconds;

	if ([WeChatAutoOpenRedEnvelopConfig sharedConfig].serialReceive) {
		unsigned int serialDelaySeconds;
		if ([WeChatRedEnvelopTaskManager sharedManager].serialQueueIsEmpty) {
			serialDelaySeconds = configDelaySeconds;
		} else {

			NSLog(@"红包队列不为空 设置延时15s");
			serialDelaySeconds = 15;
		}
		NSLog(@"serialDelaySeconds == %u",(unsigned int)serialDelaySeconds);
		return serialDelaySeconds;
	} else {
		NSLog(@"configDelaySeconds == %u",(unsigned int)configDelaySeconds);
		return (unsigned int)configDelaySeconds;
	}
}

%end


%hook CMessageMgr

-(void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
	%orig;
	NSLog(@"LWeChaat m_uiMessageType == %@",wrap);
	switch(wrap.m_uiMessageType){
	case 49:{

		/** 是否为红包消息 */
		BOOL (^isRedEnvelopMessage)() = ^BOOL() {
			return [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
		};

		if (isRedEnvelopMessage()) { // 红包
			NSLog(@"是红包消息");
			CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
			CContact *selfContact = [contactManager getSelfContact];

			BOOL (^isSender)() = ^BOOL() {
				NSLog(@"isSender = %@", [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName] == YES ? @"Yes" : @"NO");
				return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
			};

			/** 是否别人在群聊中发消息 */
			BOOL (^isGroupReceiver)() = ^BOOL() {
				NSLog(@"是否别人在群聊中发消息 = %@",[wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound ? @"Yes" : @"NO");
				return [wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound;
			};

			/** 是否自己在群聊中发消息 */
			BOOL (^isGroupSender)() = ^BOOL() {
				NSLog(@"是否自己在群聊中发消息 = %@",[wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound ? @"Yes" : @"NO");
				return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
			};

			/** 是否抢自己发的红包 */
			BOOL (^isReceiveSelfRedEnvelop)() = ^BOOL() {
				NSLog(@"是否抢自己发的红包 == %@",[WeChatAutoOpenRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop == YES ? @"自动抢" : @"不自动");
				return [WeChatAutoOpenRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop;
			};

			/** 是否可自动抢红包判断 */
			BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
				NSLog(@"是否可自动抢红包判断 == %@",[WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable == YES ? @"自动抢" : @"不自动");
				if (![WeChatAutoOpenRedEnvelopConfig sharedConfig].autoReceiveEnable) { return NO; }
				return isGroupReceiver() || (isGroupSender() && isReceiveSelfRedEnvelop());
			};

			NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
				nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
				return [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
			};

			/** 获取服务端验证参数 */
			void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
				
				NSMutableDictionary *params = [@{} mutableCopy];
				params[@"agreeDuty"] = @"0";
				params[@"channelId"] = [nativeUrlDict objectForKey:@"channelid"];
				params[@"inWay"] = @"0";
				params[@"msgType"] = [nativeUrlDict objectForKey:@"msgtype"];
				params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
				params[@"sendId"] = [nativeUrlDict objectForKey:@"sendid"];

				WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
				NSLog(@"LWeChaat 服务端验证参数 params == %@",params);
				[logicMgr ReceiverQueryRedEnvelopesRequest:params];
			};

			/** 储存参数 */
			void (^enqueueParam)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
					WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
					mgrParams.msgType = [nativeUrlDict objectForKey:@"msgtype"];
					mgrParams.sendId = [nativeUrlDict objectForKey:@"sendid"];
					mgrParams.channelId = [nativeUrlDict objectForKey:@"channelid"];
					mgrParams.nickName = [selfContact getContactDisplayName];
					mgrParams.headImg = [selfContact m_nsHeadImgUrl];
					mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
					mgrParams.sessionUserName = isGroupSender() ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
					mgrParams.sign = [nativeUrlDict objectForKey:@"sign"];

					mgrParams.isGroupSender = isGroupSender();
					NSLog(@"mgrParams 储存参数 ===  %@",mgrParams);
					[[WeChatRedEnvelopParamQueue sharedQueue] enqueue:mgrParams];
			};
			if (shouldReceiveRedEnvelop()) {
				NSLog(@"shouldReceiveRedEnvelop");
				NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];			
				NSDictionary *nativeUrlDict = parseNativeUrl(nativeUrl);

				queryRedEnvelopesReqeust(nativeUrlDict);
				enqueueParam(nativeUrlDict);
			}
		}
	}
	default:
		break;
	}	

}

%end


%end

%ctor{

%init(group1)

}

