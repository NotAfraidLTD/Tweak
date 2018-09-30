# 越狱iPhone的ip地址
# 需要添加到环境变量中才能生效
THEOS_DEVICE_IP = 172.1.1.242

# 指定支持的处理器架构
ARCHS = armv7 arm64

# 程序发布在iOS8.0以上
export TARGET = iphone:latest:8.0

include /opt/theos/makefiles/common.mk

TWEAK_NAME = LWeChat

# 新建的类需要添加.m(空格隔开)
LWeChat_FILES = Tweak.xm WeChatMessageWarp.m WeChatTweakSetViewController.m WeChatAutoOpenRedEnvelopConfig.m WeChatRedEnvelopParam.m WeChatRedEnvelopParamQueue.m WeChatReceiveRedEnvelopOperation.m WeChatRedEnvelopTaskManager.m

include $(THEOS_MAKE_PATH)/tweak.mk

# 导入框架 (空格隔开)
LWeChat_FRAMEWORKS = UIKit Foundation
# LWeChat_PRIVATE_FRAMEWORKS = AppSupport


# make clean
clean::
	rm -rf ./packages/*


