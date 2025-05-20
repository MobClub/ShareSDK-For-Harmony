import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Utility, WBAPI, WeiboLogger } from 'core';
import mobShare from '@zztsdk/sharesdk';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    //设置授权需要的UIAbilityContext
    await mobShare.ShareSDK.getInstance().setUIAbilityContext(this.context)
    //接收三方平台回调方法
    mobShare.ShareSDK.getInstance().handlerWant(want, this.context)
    //微博日志开关
    WeiboLogger.logEnable = true; // 调试时可以打开log开关 默认是false;
    //微博签名方法
    new Utility().getSign().then(sign => {
      console.log("Weibo get sign: " + sign); // 获取debug和release包对应的签名，用于开放平台注册。获取完成可删除此代码。
    })
  }

  async onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    //接收三方平台回调方法
    mobShare.ShareSDK.getInstance().handlerWant(want, this.context)
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
